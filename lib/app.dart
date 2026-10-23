/// MaterialApp shell: theme, l10n, routes. Locale changes rebuild in place so
/// the navigator stack survives a live language switch.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_scope.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'config/tokens.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/how_to_play_screen.dart';
import 'screens/match_setup_screen.dart';
import 'screens/settings_screen.dart';
import 'services/ad_service.dart';
import 'services/settings_service.dart';
import 'services/stats_service.dart';

class ReactionDuelApp extends StatelessWidget {
  const ReactionDuelApp({required this.services, this.home, super.key});

  final AppServices services;

  /// Overrides the home route (screenshots / tests).
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: services.settings,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: AppTheme.current,
        locale: services.settings.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        localeResolutionCallback: _resolveLocale,
        builder: (context, child) =>
            AppScope(services: services, child: child ?? const SizedBox.shrink()),
        home: home ?? const HomeScreen(),
        routes: {
          AppRoutes.setup: (_) => const MatchSetupScreen(),
          AppRoutes.settings: (_) => const SettingsScreen(),
          AppRoutes.howTo: (_) => const HowToPlayScreen(),
        },
      ),
    );
  }

  /// Device language → en.
  static Locale _resolveLocale(Locale? device, Iterable<Locale> supported) {
    if (device != null) {
      for (final l in supported) {
        if (l.languageCode == device.languageCode) return l;
      }
    }
    return const Locale('en');
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      systemNavigationBarColor: AppColors.background,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final settings = await SettingsService.create();
  final stats = StatsService(settings.prefs);
  final ads = AdService.instance..initialize(firstSession: stats.firstSession);
  runApp(
    ReactionDuelApp(
      services: AppServices(settings: settings, stats: stats, ads: ads),
    ),
  );
}
