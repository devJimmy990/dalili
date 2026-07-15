import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/localization/generated/l10n.dart';
import 'package:dalili/core/theme/app_theme.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_state.dart';
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

class DaliliApp extends StatelessWidget {
  const DaliliApp({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppSettingsCubit, AppSettingsState>(
        bloc: sl<AppSettingsCubit>(),
        builder: (context, settings) => MaterialApp(
          key: ValueKey(settings.locale.languageCode),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: settings.locale,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: Directionality(
              textDirection: settings.locale.languageCode == 'ar'
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
