import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/widgets/tiles.dart';
import 'package:shared/widgets/conversation_screen.dart';
import 'package:shared/models.dart';
import 'package:shared/providers/auth_provider.dart';
import 'package:trainer_app/requests_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trainer Dashboard',
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
              'Trainer: Aarav',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0), // 8pt spacing
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          buildTile(context, 'Members', Icons.people, () {}),
          buildTile(context, 'Chats', Icons.chat, () {
            final currentUser = ref.read(authProvider);
            if (currentUser != null) {
              // Generate dummy member profile for DK (pre-seeded profile)
              final dummyMember = User(
                id: 'member_dk_001',
                role: UserRole.member,
                name: 'DK',
                email: 'dk@example.com',
                assignedTrainerId: currentUser.id,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConversationScreen(
                    peerUser: dummyMember,
                    // MUST match the Guru App chatId format so both apps read/write to the same Hive conversation!
                    chatId: 'chat_${dummyMember.id}_${currentUser.id}',
                  ),
                ),
              );
            }
          }),
          buildTile(context, 'Requests', Icons.calendar_today, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RequestsScreen()),
            );
          }),
          // buildTile(context, 'Requests', Icons.calendar_today, () {}),
          buildTile(context, 'Sessions', Icons.video_library, () {}),
        ],
      ),
    );
  }
}
