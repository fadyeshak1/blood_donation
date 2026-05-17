import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/widgets/error_view.dart';
import 'package:blood_donation/core/widgets/loading_indicator.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_provider.dart';
import 'package:blood_donation/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:blood_donation/features/profile/presentation/widgets/donation_history_section.dart';
import 'package:blood_donation/features/profile/presentation/widgets/info_section.dart';
import 'package:blood_donation/features/profile/presentation/widgets/profile_header.dart';
import 'package:blood_donation/features/profile/presentation/widgets/qr_code_section.dart';
import 'package:blood_donation/features/profile/presentation/widgets/request_history_section.dart';
import 'package:blood_donation/features/profile/presentation/widgets/settings_section.dart';
import 'package:blood_donation/features/profile/presentation/widgets/stats_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUserProfile('user_123');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          final state = provider.state;

          if (state.isLoading) {
            return const LoadingIndicator();
          }

          if (state.isError || !state.hasUser) {
            return ErrorView(
              message: state.errorMessage ?? 'Failed to load profile',
              onRetry: () => provider.loadUserProfile('user_123'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadUserProfile('user_123'),
            color: AppTheme.red,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  ProfileHeader(user: state.user!),
                  const SizedBox(height: 16),
                  StatsSection(user: state.user!),
                  const SizedBox(height: 16),
                  QrCodeSection(donorId: state.user!.donorId),
                  const SizedBox(height: 16),
                  InfoSection(user: state.user!),
                  const SizedBox(height: 16),
                  const DonationHistorySection(),
                  const SizedBox(height: 16),
                  const RequestHistorySection(),
                  const SizedBox(height: 16),
                  const SettingsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Profile'),
      actions: [
        Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            if (!provider.state.hasUser) return const SizedBox.shrink();
            return IconButton(
              onPressed: () =>
                  _navigateToEditProfile(context, provider.state.user!),
              icon: const Icon(Icons.edit_outlined),
            );
          },
        ),
      ],
    );
  }

  void _navigateToEditProfile(BuildContext context, user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<ProfileProvider>(),
          child: EditProfileScreen(user: user),
        ),
      ),
    );
  }
}