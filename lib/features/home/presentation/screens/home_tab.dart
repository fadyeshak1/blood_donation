import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/core/widgets/custom_app_bar.dart';
import 'package:blood_donation/core/widgets/error_view.dart';
import 'package:blood_donation/core/widgets/loading_indicator.dart';
import 'package:blood_donation/features/home/presentation/providers/home_provider.dart';
import 'package:blood_donation/features/home/presentation/widgets/donation_cta_card.dart';
import 'package:blood_donation/features/home/presentation/widgets/stats_grid.dart';
import 'package:blood_donation/features/home/presentation/widgets/urgent_requests_section.dart';
import 'package:blood_donation/features/home/presentation/widgets/welcome_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback? onViewAllRequests;

  const HomeTab({super.key, this.onViewAllRequests});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadDashboard('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home',
        subtitle: DateFormatter.formatDate(DateTime.now()),
        showNotification: true,
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          final state = provider.state;

          if (state.isLoading) return const LoadingIndicator();

          if (state.isError || !state.hasStats) {
            return ErrorView(
              message: state.errorMessage ?? 'Failed to load dashboard stats',
              onRetry: () => provider.loadDashboard(''),
            );
          }

          final fullName = state.stats?.fullName ?? '';
          final firstName = fullName.trim().split(' ').first;

          return RefreshIndicator(
            onRefresh: () => provider.loadDashboard(''),
            color: AppTheme.red,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  WelcomeBanner(userName: firstName),
                  const SizedBox(height: 16),
                  StatsGrid(stats: state.stats!),
                  const SizedBox(height: 16),
                  const DonationCtaCard(),
                  const SizedBox(height: 16),
                  UrgentRequestsSection(
                    requests: state.urgentRequests,
                    onViewAll: widget.onViewAllRequests,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}