import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuickReplyChips extends StatelessWidget {
  final List<String> replies;
  final ValueChanged<String> onReplyTap;

  const QuickReplyChips({
    super.key,
    required this.replies,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: replies.length,
        itemBuilder: (context, index) {
          final reply = replies[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton(
              onPressed: () => onReplyTap(reply),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                reply,
                style: const TextStyle(
                  color: AppTheme.blue,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}