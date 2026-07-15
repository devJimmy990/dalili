import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_cubit.dart';
import 'package:dalili/features/library/presentation/screens/main_layout.dart';
import 'package:dalili/features/library/presentation/screens/onboarding/language_page.dart';
import 'package:dalili/features/library/presentation/screens/onboarding/onboard_navigate_page.dart';
import 'package:dalili/features/library/presentation/screens/onboarding/onboard_scan_page.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finish() {
    sl<AppSettingsCubit>().markOnboardingComplete();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => const MainLayout()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colors.surface,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    LanguagePage(onLanguageSelected: _nextPage),
                    OnboardScanPage(onSkip: _finish, onContinue: _nextPage),
                    OnboardNavigatePage(onGetStarted: _finish),
                  ],
                ),
              ),
              _PageIndicator(
                  count: 3, current: _currentPage),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current
                  ? context.colors.secondary
                  : context.appTheme.outlineVariant,
              borderRadius:
                  BorderRadius.circular(context.appTheme.radiusFull),
            ),
          ),
        ),
      );
}
