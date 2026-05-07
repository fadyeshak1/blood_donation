import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.red, AppTheme.red.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Donor ID: ${user.donorId}',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.white, width: 4),
        color: AppTheme.white.withValues(alpha: 0.2),
      ),
      child: user.profileImage != null
          ? ClipOval(
              child: Image.network(
                user.profileImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _AvatarPlaceholder(),
              ),
            )
          : const _AvatarPlaceholder(),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.person, size: 50, color: AppTheme.white);
  }
}