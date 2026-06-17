import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../utils/app_colors.dart';
import '../services/chat_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add initial greeting
    _messages.add(ChatMessage(text: ChatService.greeting, isUser: false));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();

    // Compile history for the backend (chronological order)
    // We skip the initial greeting since it's just local UI flair, 
    // or we can include it. Let's include everything except the greeting to save tokens.
    final history = _messages.reversed
        .where((m) => m.text != ChatService.greeting)
        .map((m) => ChatMessageData(
              role: m.isUser ? 'user' : 'model',
              content: m.text,
            ))
        .toList();

    final reply = await ChatService.getReply(history);
    
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.insert(0, ChatMessage(text: reply, isUser: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryLight,
              child: Icon(Icons.support_agent, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Healix Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textMain)),
                const Text('Online • Always Secure', style: TextStyle(fontSize: 11, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // Newest messages at the bottom
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == 0) {
                    return _TypingIndicator(colors: colors);
                  }
                  final msg = _messages[index - (_isTyping ? 1 : 0)];
                  return _ChatBubble(message: msg, colors: colors);
                },
              ),
            ),
            _ChatInput(
              controller: _controller,
              onSend: _sendMessage,
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final AppColors colors;

  const _ChatBubble({required this.message, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? colors.primary : colors.background,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: !message.isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: message.isUser ? null : Border.all(color: colors.border),
        ),
        child: message.isUser
            ? Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              )
            : MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: colors.textMain, fontSize: 15, height: 1.4),
                  strong: TextStyle(color: colors.textMain, fontWeight: FontWeight.bold),
                  listBullet: TextStyle(color: colors.textMain),
                ),
              ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final AppColors colors;
  const _TypingIndicator({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(0)),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(colors: colors),
            const SizedBox(width: 4),
            _Dot(colors: colors),
            const SizedBox(width: 4),
            _Dot(colors: colors),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final AppColors colors;
  const _Dot({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: colors.textMuted, shape: BoxShape.circle),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final AppColors colors;

  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: colors.textMain),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: colors.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSend,
            child: CircleAvatar(
              backgroundColor: colors.primary,
              radius: 24,
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
