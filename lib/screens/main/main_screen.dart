import 'package:flutter/material.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/sunlight_overlay.dart';
import '../../theme/app_theme.dart';
import 'home_screen.dart';
import '../account/history_screen.dart';
import '../account/favorites_screen.dart';
import '../account/settings_screen.dart';
import '../production/upload_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // 0
    const SizedBox(), // 1 (Placeholder for Create action)
    const HistoryScreen(), // 2
    const FavoritesScreen(), // 3
    const SettingsScreen(), // 4
  ];

  void _onTabTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen()));
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background with sunlight
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.warmSand,
            ),
          ),
          const Positioned.fill(child: SunlightOverlay()),
          
          // Main Content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          // Custom Navigation Bar
          CustomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ],
      ),
    );
  }
}
