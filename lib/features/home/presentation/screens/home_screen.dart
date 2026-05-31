import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/chat/presentation/screens/chat_screen.dart';
import 'package:blood_donation/features/home/presentation/screens/home_tab.dart';
import 'package:blood_donation/features/profile/presentation/screens/profile_screen.dart';
import 'package:blood_donation/features/requests/presentation/screens/requests_screen.dart';
import 'package:blood_donation/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _goToRequests() => setState(() => _currentIndex = 1);

  @override
  Widget build(BuildContext context) {
    // Built here (not const) so HomeTab can receive the callback
    final screens = [
      HomeTab(onViewAllRequests: _goToRequests),
      const RequestsScreen(),
      const RewardsScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            activeIcon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}