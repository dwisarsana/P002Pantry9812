import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  // For now we just create it, but in real app we might await some init

  runApp(const GardenAIApp());
}

class GardenAIApp extends StatelessWidget {
  const GardenAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<StorageService>(create: (_) => StorageService())],
      child: MaterialApp(
        title: 'Garden AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
