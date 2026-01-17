import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;

  const LoadingIndicator({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: CircularProgressIndicator(
          color: color ?? AppTheme.red,
          strokeWidth: 3,
        ),
      ),
    );
  }
}