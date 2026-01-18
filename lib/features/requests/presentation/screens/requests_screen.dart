import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/constants.dart';
import 'package:blood_donation/core/widgets/empty_state.dart';
import 'package:blood_donation/core/widgets/error_view.dart';
import 'package:blood_donation/core/widgets/loading_indicator.dart';
import 'package:blood_donation/features/requests/presentation/providers/requests_provider.dart';
import 'package:blood_donation/features/requests/presentation/screens/create_request_screen.dart';
import 'package:blood_donation/features/requests/presentation/screens/request_details_screen.dart';
import 'package:blood_donation/features/requests/presentation/widgets/filter_section.dart';
import 'package:blood_donation/features/requests/presentation/widgets/request_card.dart';
import 'package:blood_donation/features/requests/presentation/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final List<String> urgencyOptions = ['All', 'Urgent', 'Normal'];
  final List<String> bloodTypeOptions = ['All', ...AppConstants.bloodTypes];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestsProvider>().loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<RequestsProvider>(
        builder: (context, provider, _) {
          final state = provider.state;

          return Column(
            children: [
              SearchBarWidget(
                onChanged: provider.updateSearchQuery,
              ),
              FilterSection(
                title: 'Urgency',
                options: urgencyOptions,
                selectedOption: state.selectedUrgency,
                onFilterChanged: provider.updateUrgencyFilter,
              ),
              const SizedBox(height: 8),
              FilterSection(
                title: 'Blood Type',
                options: bloodTypeOptions,
                selectedOption: state.selectedBloodType,
                onFilterChanged: provider.updateBloodTypeFilter,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Consumer<RequestsProvider>(
        builder: (context, provider, _) {
          final count = provider.state.requests.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Blood Requests'),
              Text(
                '$count ${count == 1 ? 'Request' : 'Requests'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: ElevatedButton.icon(
            onPressed: () => _navigateToCreateRequest(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToCreateRequest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<RequestsProvider>(),
          child: const CreateRequestScreen(),
        ),
      ),
    );
  }

  Widget _buildContent(RequestsProvider provider) {
    final state = provider.state;

    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.isError) {
      return ErrorView(
        message: state.errorMessage ?? 'Failed to load requests',
        onRetry: provider.loadRequests,
      );
    }

    if (!state.hasRequests) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No requests found',
        subtitle: 'Try adjusting your filters',
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadRequests,
      color: AppTheme.red,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.requests.length,
        itemBuilder: (context, index) {
          final request = state.requests[index];
          return RequestCard(
            request: request,
            onTap: () => _navigateToDetails(context, request.id),
          );
        },
      ),
    );
  }

  void _navigateToDetails(BuildContext context, String requestId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<RequestsProvider>(),
          child: RequestDetailsScreen(requestId: requestId),
        ),
      ),
    );
  }
}