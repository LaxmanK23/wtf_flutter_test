import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/models.dart';
import 'package:shared/providers/auth_provider.dart';
import 'package:shared/widgets/card.dart';
import 'package:shared/widgets/conversation_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guru App',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        // AppBar with role badge requirement
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            width: double.infinity,
            color: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: const Text(
              'Member: DK',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0), // 8pt spacing
        children: [
          buildCard(context, 'Chat with Trainer', Icons.chat, () {
            final currentUser = ref.read(authProvider);
            if (currentUser != null && currentUser.assignedTrainerId != null) {
              // Since we are mocking, we just generate a dummy trainer user to pass in
              final dummyTrainer = User(
                id: currentUser.assignedTrainerId!,
                role: UserRole.trainer,
                name: 'Aarav (Lead Trainer)',
                email: 'aarav@trainer.com',
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConversationScreen(
                    peerUser: dummyTrainer,
                    chatId: 'chat_${currentUser.id}_${dummyTrainer.id}',
                  ),
                ),
              );
            }
          }),
          const SizedBox(height: 16),
          buildCard(context, 'Schedule Call', Icons.calendar_month, () {}),
          const SizedBox(height: 16),
          buildCard(context, 'My Sessions', Icons.video_call, () {}),
        ],
      ),
    );
  }
}
