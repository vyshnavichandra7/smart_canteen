import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';

class CanteenApp extends StatelessWidget {
  const CanteenApp({super.key, required this.storage});

  final LocalStorageService storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MGIT Smart Canteen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: storage.hasSeenOnboarding
          ? const AppShell()
          : OnboardingScreen(storage: storage),
    );
  }
}
