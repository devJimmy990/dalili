import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/localization/generated/l10n.dart';
import 'package:dalili/core/services/book_link_service.dart';
import 'package:dalili/core/theme/app_theme.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_state.dart';
import 'package:dalili/features/library/presentation/screens/book_detail/book_detail_screen.dart';
import 'package:dalili/features/library/presentation/screens/main_layout.dart';
import 'package:dalili/features/library/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );
  await initDependencies();
  runApp(const DaliliApp());
}

class DaliliApp extends StatefulWidget {
  const DaliliApp({super.key});

  @override
  State<DaliliApp> createState() => _DaliliAppState();
}

class _DaliliAppState extends State<DaliliApp> {
  /// Lets a shared link open a book from outside the widget tree.
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final BookLinkService _links;

  @override
  void initState() {
    super.initState();
    _links = BookLinkService(
      navigatorKey: _navigatorKey,
      repository: sl<LibraryRepository>(),
      bookPage: (book) => BookDetailScreen(book: book),
    )..start();
  }

  @override
  void dispose() {
    _links.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppSettingsCubit, AppSettingsState>(
        bloc: sl<AppSettingsCubit>(),
        builder: (context, settings) => MaterialApp(
          key: ValueKey(settings.locale),
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: settings.themeMode == AppThemeMode.light
              ? AppTheme.light
              : AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode == AppThemeMode.light
              ? ThemeMode.light
              : settings.themeMode == AppThemeMode.dark
              ? ThemeMode.dark
              : ThemeMode.system,
          locale: Locale(settings.locale),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: Directionality(
              textDirection: settings.locale == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            ),
          ),
          home: settings.hasSeenOnboarding
              ? const MainLayout()
              : const OnboardingScreen(),
        ),
      );
}
