import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models.dart';
import 'chat_service.dart';

// 10.0.2.2 is the localhost loopback for Android Emulators.
// If testing on iOS simulator, use localhost. If real device, use your computer's local IP.
const String tokenServerUrl = 'http://10.0.2.2:3000';

final scheduleServiceProvider = NotifierProvider(() {
  return ScheduleService();
});

class ScheduleService extends Notifier {
  late Box _requestsBox;
  late Box roomMetaBox;
  final _uuid = const Uuid();

  @override
  List build() {
    _requestsBox = Hive.box('call_requests');
    roomMetaBox = Hive.box('users'); // Reuse or open 'room_meta' box if created
    return _requestsBox.values.cast().toList();
  }

  /// Member requests a call
  Future requestCall(
    String memberId,
    String trainerId,
    DateTime scheduledFor,
    String note,
  ) async {
    if (scheduledFor.isBefore(DateTime.now())) {
      throw Exception('Cannot schedule a call in the past.');
    }
    if (note.length > 140) {
      throw Exception('Note must be 140 characters or less.');
    }

    final request = CallRequest(
      id: _uuid.v4(),
      memberId: memberId,
      trainerId: trainerId,
      requestedAt: DateTime.now(),
      scheduledFor: scheduledFor,
      note: note,
      status: CallRequestStatus.pending,
    );

    state = [...state, request];
    await _requestsBox.put(request.id, request);
  }

  /// Trainer approves a call -> Creates Room -> Sends Chat Message
  Future approveCall(String requestId) async {
    final request = state.firstWhere((r) => r.id == requestId);

    // Conflict Check: Is this slot already approved for another member?
    final hasConflict = state.any(
      (r) =>
          r.status == CallRequestStatus.approved &&
          r.trainerId == request.trainerId &&
          r.scheduledFor == request.scheduledFor,
    );

    if (hasConflict) {
      throw Exception('Slot already approved for another session.');
    }

    // 1. Hit local Node server to create 100ms room
    final response = await http.post(Uri.parse('$tokenServerUrl/create-room'));
    if (response.statusCode != 200) {
      throw Exception('Failed to create 100ms room');
    }

    final roomId = jsonDecode(response.body)['roomId'];

    // 2. Create RoomMeta locally
    final roomMeta = RoomMeta(
      id: _uuid.v4(),
      callRequestId: request.id,
      hmsRoomId: roomId,
      hmsRoleMember: 'guest', // Using default 100ms roles
      hmsRoleTrainer: 'host',
    );
    // Assuming you opened 'room_meta' in main.dart: Hive.openBox('room_meta')
    await Hive.box('room_meta').put(roomMeta.id, roomMeta);

    // 3. Update Request Status
    final updatedReq = CallRequest(
      id: request.id,
      memberId: request.memberId,
      trainerId: request.trainerId,
      requestedAt: request.requestedAt,
      scheduledFor: request.scheduledFor,
      note: request.note,
      status: CallRequestStatus.approved,
    );

    state = [
      for (final r in state)
        if (r.id == requestId) updatedReq else r,
    ];
    await _requestsBox.put(updatedReq.id, updatedReq);

    // 4. Send System Message to Chat
    final dateStr = DateFormat('MMM d').format(request.scheduledFor);
    final timeStr = DateFormat('h:mm a').format(request.scheduledFor);

    // Exact copy from assessment constraints
    final sysMessage = "Call approved for $dateStr $timeStr.";

    final chatId = 'chat_${request.memberId}_${request.trainerId}';
    await ref
        .read(chatServiceProvider.notifier)
        .sendMessage(
          chatId: chatId,
          senderId: request.trainerId, // Trainer sent it
          receiverId: request.memberId,
          text: sysMessage,
        );
  }

  /// Trainer declines a call
  Future declineCall(String requestId, String reason) async {
    final request = state.firstWhere((r) => r.id == requestId);
    final updatedReq = CallRequest(
      id: request.id,
      memberId: request.memberId,
      trainerId: request.trainerId,
      requestedAt: request.requestedAt,
      scheduledFor: request.scheduledFor,
      note: request.note,
      status: CallRequestStatus.declined,
    );

    state = [
      for (final r in state)
        if (r.id == requestId) updatedReq else r,
    ];
    await _requestsBox.put(updatedReq.id, updatedReq);

    // Optional: Send decline message to chat
    final chatId = 'chat_${request.memberId}_${request.trainerId}';
    await ref
        .read(chatServiceProvider.notifier)
        .sendMessage(
          chatId: chatId,
          senderId: request.trainerId,
          receiverId: request.memberId,
          text: "Call request declined. Reason: $reason.", // Exact copy
        );
  }
}
