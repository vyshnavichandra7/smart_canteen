import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/canteen_logo.dart';
import 'app_shell.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.storage});

  final LocalStorageService storage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final heroSize = (constraints.maxHeight * 0.4).clamp(170.0, 250.0);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 18, 26, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CanteenLogo(size: 44),
                        const SizedBox(width: 11),
                        const Expanded(
                          child: Text(
                            'MGIT Smart Canteen',
                            style: TextStyle(
                              color: AppTheme.navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _start(context),
                          child: const Text('Skip'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        height: heroSize,
                        width: heroSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFE6D0), Color(0xFFFFF6ED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: CanteenLogo(size: heroSize * 0.52),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E6),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'MADE FOR YOUR CAMPUS BREAK',
                        style: TextStyle(
                          color: AppTheme.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Skip the Queue.\nEnjoy Your Break.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 34, height: 1.17),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'Browse the sample menu, order ahead, and follow your order from placed to ready — all in one place.',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.muted, fontSize: 15),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _start(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Get Started'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 19),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    await storage.setOnboardingSeen();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AppShell()),
    );
  }
}
