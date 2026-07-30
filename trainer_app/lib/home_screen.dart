import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/widgets/tiles.dart';

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
          buildTile(context, 'Chats', Icons.chat, () {}),
          buildTile(context, 'Requests', Icons.calendar_today, () {}),
          buildTile(context, 'Sessions', Icons.video_library, () {}),
        ],
      ),
    );
  }
}
