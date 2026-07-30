import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models.dart';

final sessionServiceProvider = NotifierProvider(() {
  return SessionService();
});

class SessionService extends Notifier {
  late Box _sessionBox;
  final _uuid = const Uuid();

  @override
  List build() {
    _sessionBox = Hive.box('session_logs'); // Ensure opened in main.dart
    return _sessionBox.values.cast().toList();
  }

  /// Auto-writes the session log when call ends
  Future createLog({
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
      durationSec: durationSec < 1 ? 1 : durationSec, // Fallback mock safeguard
    );

    state = [...state, log];
    await _sessionBox.put(log.id, log);
    return log;
  }

  /// Member adds rating and optional note
  Future updateMemberFeedback(String logId, int rating, String note) async {
    final log = state.firstWhere((l) => l.id == logId);
    final updated = SessionLog(
      id: log.id, memberId: log.memberId, trainerId: log.trainerId,
      startedAt: log.startedAt, endedAt: log.endedAt, durationSec: log.durationSec,
      rating: rating, memberNotes: note, trainerNotes: log.trainerNotes,
    );
    state = [for (final l in state) if (l.id == logId) updated else l];
    await _sessionBox.put(updated.id, updated);
  }

  /// Trainer adds notes and marks complete
  Future updateTrainerNotes(String logId, String notes) async {
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