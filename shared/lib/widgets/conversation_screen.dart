import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/models.dart';
import 'package:shared/services/chat_service.dart';
import 'package:shared/providers/auth_provider.dart';
import 'chat_bubble.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final User peerUser;
  final String chatId;

  const ConversationScreen({
    super.key, 
    required this.peerUser, 
    required this.chatId,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark messages as read when screen opens -> note the `widget.chatId`
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(authProvider);
      if (currentUser != null) {
        ref.read(chatServiceProvider.notifier).markAllAsRead(widget.chatId, currentUser.id);
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final currentUser = ref.read(authProvider)!;
    
    // Note: widget.chatId and widget.peerUser.id
    ref.read(chatServiceProvider.notifier).sendMessage(
      chatId: widget.chatId,
      senderId: currentUser.id,
      receiverId: widget.peerUser.id,
      text: text.trim(),
    );
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accessing widget.chatId
    final messages = ref.watch(chatServiceProvider).where((m) => m.chatId == widget.chatId).toList();
    final isTyping = ref.watch(typingStateProvider);
    final currentUser = ref.watch(authProvider);

    // Auto-mark as read on new messages
    ref.listen(chatServiceProvider, (previous, next) {
      if (currentUser != null) {
        ref.read(chatServiceProvider.notifier).markAllAsRead(widget.chatId, currentUser.id);
      }
      _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerUser.name), // Accessing widget.peerUser
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          "No messages yet. Start the conversation.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUser?.id;
                      return ChatBubble(
                        message: msg,
                        isMe: isMe,
                        senderRole: isMe ? currentUser!.role : widget.peerUser.role,
                      );
                    },
                  ),
          ),
          if (isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 24, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "typing...",
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          // Quick replies
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ["Got it 👍", "Can we talk at 6?", "Share plan?"]
                  .map((chip) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(chip),
                          onPressed: () => _sendMessage(chip),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Sticky Input Bar
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: currentUser?.role == UserRole.member
                        ? const Color(0xFF1769E0)
                        : const Color(0xFFE50914),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}