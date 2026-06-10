import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/chat/data/models/chat_message_model.dart';
import 'package:blood_donation/features/chat/presentation/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Quick suggestion chips — shown before first user message
  static const List<String> _suggestions = [
    'When can I donate again?',
    'Am I eligible to donate?',
    'كم مرة يمكنني التبرع في السنة؟',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    FocusScope.of(context).unfocus();
    await context.read<ChatProvider>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Color(0xFF5B6CF6), size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Blood Donation Assistant',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFF22C55E),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF888888)),
            tooltip: 'Clear chat',
            onPressed: () {
              context.read<ChatProvider>().clearChat();
              _scrollToBottom();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Message list ─────────────────────────────────────────────
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (_, provider, __) {
                _scrollToBottom();
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  itemCount: provider.messages.length,
                  itemBuilder: (_, index) {
                    final msg = provider.messages[index];
                    if (msg.isLoading) return const _TypingBubble();
                    return _MessageBubble(message: msg);
                  },
                );
              },
            ),
          ),

          // ── Quick suggestion chips ────────────────────────────────────
          Consumer<ChatProvider>(
            builder: (_, provider, __) {
              // Hide chips after first user message
              final hasUserMessage =
                  provider.messages.any((m) => m.isUser);
              if (hasUserMessage) return const SizedBox.shrink();

              return Container(
                color: AppTheme.white,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      onTap: () => _send(_suggestions[index]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: const Color(0xFF5B6CF6),
                              width: 1.5),
                        ),
                        child: Text(
                          _suggestions[index],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5B6CF6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // ── Input bar ─────────────────────────────────────────────────
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
            child: Consumer<ChatProvider>(
              builder: (_, provider, __) {
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focusNode,
                          maxLines: 4,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _send,
                          enabled: !provider.isSending,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: provider.isSending
                          ? null
                          : () => _send(_ctrl.text),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: provider.isSending
                              ? Colors.grey[400]
                              : const Color(0xFF3B5BDB),
                          shape: BoxShape.circle,
                        ),
                        child: provider.isSending
                            ? const Padding(
                                padding: EdgeInsets.all(13),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.white),
                              )
                            : const Icon(Icons.send_rounded,
                                color: AppTheme.white, size: 22),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ─────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const _MessageBubble({required this.message});

  /// Detects if text contains Arabic characters
  bool _isArabic(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isArabic = _isArabic(message.message);
    final textDir =
        isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot avatar
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Color(0xFF5B6CF6), size: 20),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF3B5BDB)
                        : AppTheme.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft:
                          Radius.circular(isUser ? 20 : 4),
                      bottomRight:
                          Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Directionality(
                    textDirection: textDir,
                    child: Text(
                      message.message,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: isUser
                            ? AppTheme.white
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                ),

                // Recommendations chips (bot only)
                if (!isUser &&
                    message.recommendations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: message.recommendations
                        .map((rec) => Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(
                                        0xFF4CAF50),
                                    width: 0.8),
                              ),
                              child: Text(
                                rec,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Typing indicator ───────────────────────────────────────────────────────

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..repeat(
          reverse: true,
          period: Duration(milliseconds: 500 + i * 150),
        ),
    );
    _animations = _controllers
        .map((c) => Tween(begin: 0.3, end: 1.0).animate(c))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Color(0xFF5B6CF6), size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (_, __) => Container(
                    width: 8,
                    height: 8,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        const Color(0xFFBBBBBB),
                        const Color(0xFF5B6CF6),
                        _animations[i].value,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}