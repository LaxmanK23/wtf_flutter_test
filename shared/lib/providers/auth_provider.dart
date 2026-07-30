import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models.dart';

final authProvider = NotifierProvider(AuthNotifier.new);

class AuthNotifier extends Notifier {
  @override
  User? build() {
    final box = Hive.box('users');
    return box.get('member_dk_001') as User?;
  }

  Future loginAsTrainer() async {
    final box = Hive.box('users');
    final trainer = User(
      id: 'trainer_aarav_001',
      role: UserRole.trainer,
      name: 'Aarav (Lead Trainer)',
      email: 'aarav@trainer.com',
    );
    await box.put(trainer.id, trainer);
    state = trainer; // Updates the UI instantly
  }

  Future loginAsDK() async {
    final box = Hive.box('users');

    // 1. Seed the Trainer
    final trainer = User(
      id: 'trainer_aarav_001',
      role: UserRole.trainer,
      name: 'Aarav (Lead Trainer)',
      email: 'aarav@trainer.com',
    );
    await box.put(trainer.id, trainer);

    // 2. Create and login DK, assigned to Aarav
    final dk = User(
      id: 'member_dk_001',
      role: UserRole.member,
      name: 'DK',
      email: 'dk@example.com',
      assignedTrainerId: trainer.id,
    );
    await box.put(dk.id, dk);

    state = dk; // Updates the UI instantly
  }
}
