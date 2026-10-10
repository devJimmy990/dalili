import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/presentation/cubits/department/department_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:dalili/features/library/presentation/screens/favorites/favorites_screen.dart';
import 'package:dalili/features/library/presentation/screens/home/home_screen.dart';
import 'package:dalili/features/library/presentation/screens/navigation/navigation_screen.dart';
import 'package:dalili/features/library/presentation/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  static const homeTab = 0;

  /// Closes every screen above the main layout and shows the Home tab.
  /// For flows that end a whole trip (stopping navigation), where going back
  /// one step would land on a book or a half-finished route picker.
  static void goHome(BuildContext context) {
    _requests.request(homeTab);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static final _requests = _TabRequests();

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

/// A listenable that fires on every request, even for the tab already shown
/// (a ValueNotifier would stay silent when the value does not change).
class _TabRequests extends ChangeNotifier {
  int tab = MainLayout.homeTab;

  void request(int index) {
    tab = index;
    notifyListeners();
  }
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = MainLayout.homeTab;

  @override
  void initState() {
    super.initState();
    MainLayout._requests.addListener(_onTabRequested);
  }

  @override
  void dispose() {
    MainLayout._requests.removeListener(_onTabRequested);
    super.dispose();
  }

  void _onTabRequested() {
    final tab = MainLayout._requests.tab;
    if (tab != _selectedIndex) setState(() => _selectedIndex = tab);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _selectedIndex,
      children: [
        BlocProvider<DepartmentCubit>(
          create: (_) => sl<DepartmentCubit>(),
          child: const HomeScreen(),
        ),
        const NavigationScreen(),
        BlocProvider<FavoritesCubit>.value(
          value: sl<FavoritesCubit>(),
          child: const FavoritesScreen(),
        ),
        const SettingsScreen(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      backgroundColor: context.colors.surface,
      indicatorColor: context.appTheme.secondaryContainer.withValues(
        alpha: 0.2,
      ),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: context.colors.secondary),
          label: AppLocalizations.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore, color: context.colors.secondary),
          label: AppLocalizations.navigation,
        ),
        NavigationDestination(
          icon: const Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite, color: context.colors.secondary),
          label: AppLocalizations.favorites,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings, color: context.colors.secondary),
          label: AppLocalizations.settings,
        ),
      ],
    ),
  );
}
