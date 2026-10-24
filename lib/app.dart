/// MaterialApp shell: theme, l10n, routes. Locale changes rebuild in place so
/// the navigator stack survives a live language switch.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        builder: (context, child) {
          final locale =
              Localizations.maybeLocaleOf(context) ?? const Locale('en');
          return Theme(
            data: AppTheme.forLocale(locale),
            child: AppScope(
              services: services,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
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
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      systemNavigationBarColor: AppColors.background,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // No startup failure or hang may block runApp — otherwise the app sits on
  // the splash screen forever. On error it opens with default settings.
  await _guarded('orientation', () {
    return SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  });

  SettingsService? settings;
  await _guarded('settings.create', () async {
    settings = await SettingsService.create();
  });
  settings ??= await _inMemorySettings();

  final stats = StatsService(settings!.prefs);
  final ads = AdService.instance;
  try {
    ads.initialize(firstSession: stats.firstSession);
  } catch (error, stack) {
    debugPrint('startup ads.initialize failed: $error\n$stack');
  }
  runApp(
    ReactionDuelApp(
      services: AppServices(settings: settings!, stats: stats, ads: ads),
    ),
  );
}

Future<void> _guarded(String label, Future<void> Function() step) async {
  try {
    await step().timeout(AppMotion.startupStepTimeout);
  } catch (error, stack) {
    debugPrint('startup $label failed: $error\n$stack');
  }
}

/// Fallback when the platform prefs store is unavailable: an in-memory store
/// so the app still opens (nothing persists for this session).
Future<SettingsService> _inMemorySettings() async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return SettingsService(await SharedPreferences.getInstance());
}
