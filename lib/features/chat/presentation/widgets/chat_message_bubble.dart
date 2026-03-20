import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/chat/data/models/chat_message_model.dart';
import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildBotAvatar(),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.blue
                    : AppTheme.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: message.isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color: message.isUser ? AppTheme.white : AppTheme.black,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppTheme.blue.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.smart_toy,
        color: AppTheme.blue,
        size: 20,
      ),
    );
  }
}
