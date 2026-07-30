import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/widgets/card.dart';

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
          buildCard(context, 'Chat with Trainer', Icons.chat, () {}),
          const SizedBox(height: 16),
          buildCard(context, 'Schedule Call', Icons.calendar_month, () {}),
          const SizedBox(height: 16),
          buildCard(context, 'My Sessions', Icons.video_call, () {}),
        ],
      ),
    );
  }
}
