import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models.dart';

// Explicitly provide both <SessionService, List<SessionLog>>
final sessionServiceProvider = NotifierProvider<SessionService, List<SessionLog>>(() {
  return SessionService();
});

// Extend Notifier with <List<SessionLog>>
class SessionService extends Notifier<List<SessionLog>> {
  late Box _sessionBox;
  final _uuid = const Uuid();

  @override
  List<SessionLog> build() {
    _sessionBox = Hive.box('session_logs');
    return _sessionBox.values.cast<SessionLog>().toList();
  }

  Future<SessionLog> createLog({
    required String memberId,
    required String trainerId,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    final durationSec = endedAt.difference(startedAt).inSeconds;
    final log = SessionLog(
      id: _uuid.v4(),
      memberId: memberId,
      trainerId: trainerId,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSec: durationSec < 1 ? 1 : durationSec,
    );

    state = [...state, log];
    await _sessionBox.put(log.id, log);
    return log;
  }

  Future<void> updateMemberFeedback(String logId, int rating, String note) async {
    final log = state.firstWhere((l) => l.id == logId);
    final updated = SessionLog(
      id: log.id, memberId: log.memberId, trainerId: log.trainerId,
      startedAt: log.startedAt, endedAt: log.endedAt, durationSec: log.durationSec,
      rating: rating, memberNotes: note, trainerNotes: log.trainerNotes,
    );
    state = [for (final l in state) if (l.id == logId) updated else l];
    await _sessionBox.put(updated.id, updated);
  }

  Future<void> updateTrainerNotes(String logId, String notes) async {
    final log = state.firstWhere((l) => l.id == logId);
    final updated = SessionLog(
      id: log.id, memberId: log.memberId, trainerId: log.trainerId,
      startedAt: log.startedAt, endedAt: log.endedAt, durationSec: log.durationSec,
      rating: log.rating, memberNotes: log.memberNotes, trainerNotes: notes,
    );
    state = [for (final l in state) if (l.id == logId) updated else l];
    await _sessionBox.put(updated.id, updated);
  }
}