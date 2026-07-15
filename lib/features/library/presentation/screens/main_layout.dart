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

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

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
          onDestinationSelected: (i) =>
              setState(() => _selectedIndex = i),
          backgroundColor: context.colors.surface,
          indicatorColor: context.appTheme.secondaryContainer
              .withValues(alpha: 0.2),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home,
                  color: context.colors.secondary),
              label: AppLocalizations.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore,
                  color: context.colors.secondary),
              label: AppLocalizations.navigation,
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite,
                  color: context.colors.secondary),
              label: AppLocalizations.favorites,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings,
                  color: context.colors.secondary),
              label: AppLocalizations.settings,
            ),
          ],
        ),
      );
}
