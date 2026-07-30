import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models.dart';

// Provider for the ChatService
final chatServiceProvider = NotifierProvider<ChatService, List<Message>>(() {
  return ChatService();
});

// Provider for the simulated typing state
final typingStateProvider = StateProvider<bool>((ref) => false);

class ChatService extends Notifier<List<Message>> {
  late Box _messagesBox;
  final _uuid = const Uuid();

  @override
  List<Message> build() {
    _messagesBox = Hive.box('messages');
    return _loadMessages();
  }

  /// Loads all messages from Hive, sorted by creation time
  List<Message> _loadMessages() {
    final messages = _messagesBox.values.cast<Message>().toList();
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  /// Sends a message and simulates network status transitions & peer typing
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    // 1. Create message with 'sending' status
    final newMessage = Message(
      id: _uuid.v4(),
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
    );

    // Save to Hive and update state immediately (optimistic UI)
    state = [...state, newMessage];
    await _messagesBox.put(newMessage.id, newMessage);

    // 2. Simulate short transmission delay -> 'sent'
    await Future.delayed(const Duration(milliseconds: 300));
    final sentMessage = Message(
      id: newMessage.id,
      chatId: newMessage.chatId,
      senderId: newMessage.senderId,
      receiverId: newMessage.receiverId,
      text: newMessage.text,
      createdAt: newMessage.createdAt,
      status: MessageStatus.sent,
    );

    state = [
      for (final msg in state)
        if (msg.id == sentMessage.id) sentMessage else msg,
    ];
    await _messagesBox.put(sentMessage.id, sentMessage);

    // 3. Simulate peer typing indicator (400–800ms) as required by assessment
    ref.read(typingStateProvider.notifier).state = true;
    await Future.delayed(const Duration(milliseconds: 700));
    ref.read(typingStateProvider.notifier).state = false;

    // 4. Simulate peer reading the message -> 'read'
    final readMessage = Message(
      id: sentMessage.id,
      chatId: sentMessage.chatId,
      senderId: sentMessage.senderId,
      receiverId: sentMessage.receiverId,
      text: sentMessage.text,
      createdAt: sentMessage.createdAt,
      status: MessageStatus.read,
    );

    state = [
      for (final msg in state)
        if (msg.id == readMessage.id) readMessage else msg,
    ];
    await _messagesBox.put(readMessage.id, readMessage);
  }

  /// Marks all messages in a specific chat as read
  Future<void> markAllAsRead(String chatId, String currentUserId) async {
    bool updated = false;
    final updatedMessages = state.map((msg) {
      if (msg.chatId == chatId &&
          msg.receiverId == currentUserId &&
          msg.status != MessageStatus.read) {
        updated = true;
        final readMsg = Message(
          id: msg.id,
          chatId: msg.chatId,
          senderId: msg.senderId,
          receiverId: msg.receiverId,
          text: msg.text,
          createdAt: msg.createdAt,
          status: MessageStatus.read,
        );
        _messagesBox.put(readMsg.id, readMsg);
        return readMsg;
      }
      return msg;
    }).toList();

    if (updated) {
      state = updatedMessages;
    }
  }
}
