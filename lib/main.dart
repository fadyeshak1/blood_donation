import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:blood_donation/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:blood_donation/features/chat/presentation/providers/chat_provider.dart';
import 'package:blood_donation/features/home/data/datasources/home_remote_datasource.dart';
import 'package:blood_donation/features/home/data/repositories/home_repository_impl.dart';
import 'package:blood_donation/features/home/presentation/providers/home_provider.dart';
import 'package:blood_donation/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:blood_donation/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_provider.dart';
import 'package:blood_donation/features/home/presentation/screens/home_screen.dart';
import 'package:blood_donation/features/requests/data/datasources/requests_remote_datasource.dart';
import 'package:blood_donation/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:blood_donation/features/requests/presentation/providers/requests_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blood_donation/features/rewards/data/datasources/rewards_remote_datasource.dart';
import 'package:blood_donation/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:blood_donation/features/rewards/presentation/providers/rewards_provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Profile Provider
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            ProfileRepositoryImpl(
              ProfileRemoteDataSourceImpl(
                const ApiClient(),
              ),
            ),
          ),
        ),
        
        // Home Provider
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            HomeRepositoryImpl(
              HomeRemoteDataSourceImpl(
                const ApiClient(),
              ),
            ),
          ),
        ),
         // Requests Provider - ADD THIS
    ChangeNotifierProvider(
      create: (_) => RequestsProvider(
        RequestsRepositoryImpl(
          RequestsRemoteDataSourceImpl(const ApiClient()),
        ),
      ),
    ),
     // Chat Provider - ADD THIS
    ChangeNotifierProvider(
      create: (_) => ChatProvider(
        ChatRepositoryImpl(
          ChatRemoteDataSourceImpl(const ApiClient()),
        ),
      ),
    ),

    ChangeNotifierProvider(
  create: (_) => RewardsProvider(
    RewardsRepositoryImpl(
      RewardsRemoteDataSourceImpl(const ApiClient()),
    ),
  ),
),
        
        // TODO: Add other providers here as you build features
        // ChangeNotifierProvider(create: (_) => RequestsProvider(...)),
        // ChangeNotifierProvider(create: (_) => RewardsProvider(...)),
      ],
      child: MaterialApp(
        title: 'Blood Donation',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}