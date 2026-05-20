import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:blood_donation/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blood_donation/features/auth/presentation/providers/auth_provider.dart';
import 'package:blood_donation/features/auth/presentation/screens/login_screen.dart';
import 'package:blood_donation/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:blood_donation/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:blood_donation/features/chat/presentation/providers/chat_provider.dart';
import 'package:blood_donation/features/home/data/datasources/home_remote_datasource.dart';
import 'package:blood_donation/features/home/data/repositories/home_repository_impl.dart';
import 'package:blood_donation/features/home/presentation/providers/home_provider.dart';
import 'package:blood_donation/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:blood_donation/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_provider.dart';
import 'package:blood_donation/features/requests/data/datasources/requests_remote_datasource.dart';
import 'package:blood_donation/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:blood_donation/features/requests/presentation/providers/requests_provider.dart';
import 'package:blood_donation/features/rewards/data/datasources/rewards_remote_datasource.dart';
import 'package:blood_donation/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:blood_donation/features/rewards/presentation/providers/rewards_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            AuthRepositoryImpl(
              AuthRemoteDataSourceImpl(const ApiClient()),
            ),
          ),
        ),

        // Profile Provider — must come before RequestsProvider
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            ProfileRepositoryImpl(
              ProfileRemoteDataSourceImpl(const ApiClient()),
            ),
          ),
        ),

        // Home Provider
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            HomeRepositoryImpl(
              HomeRemoteDataSourceImpl(const ApiClient()),
            ),
          ),
        ),

        // Requests Provider — wired to ProfileProvider
        ChangeNotifierProxyProvider<ProfileProvider, RequestsProvider>(
          create: (_) => RequestsProvider(
            RequestsRepositoryImpl(
              RequestsRemoteDataSourceImpl(const ApiClient()),
            ),
          ),
          update: (_, profileProvider, requestsProvider) {
            requestsProvider!.setProfileProvider(profileProvider);
            return requestsProvider;
          },
        ),

        // Chat Provider
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            ChatRepositoryImpl(
              ChatRemoteDataSourceImpl(const ApiClient()),
            ),
          ),
        ),

        // Rewards Provider
        ChangeNotifierProvider(
          create: (_) => RewardsProvider(
            RewardsRepositoryImpl(
              RewardsRemoteDataSourceImpl(const ApiClient()),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Blood Donation',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const LoginScreen(), // Start from Login
      ),
    );
  }
}