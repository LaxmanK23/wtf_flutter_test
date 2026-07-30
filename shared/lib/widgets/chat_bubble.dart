import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final UserRole senderRole;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.senderRole,
  });

  @override
  Widget build(BuildContext context) {
    // Strict role colors required by assessment
    final bgColor = senderRole == UserRole.member
        ? const Color(0xFF1769E0) // Guru Blue
        : const Color(0xFFE50914); // Trainer Red

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 16,
        ), // 8pt system
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        width: MediaQuery.of(context).size.width * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.createdAt),
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == MessageStatus.read
                        ? Icons.done_all
                        : Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
