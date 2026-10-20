/// Hands services down the tree. Rebuilds dependents when settings change.
library;

import 'package:flutter/widgets.dart';

import 'services/ad_service.dart';
import 'services/settings_service.dart';
import 'services/stats_service.dart';

class AppServices {
  AppServices({required this.settings, required this.stats, AdService? ads})
    : ads = ads ?? AdService.instance;

  final SettingsService settings;
  final StatsService stats;
  final AdService ads;
}

class AppScope extends InheritedNotifier<SettingsService> {
  AppScope({required this.services, required super.child, super.key})
    : super(notifier: services.settings);

  final AppServices services;

  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.services;

  /// No rebuild subscription — for callbacks.
  static AppServices read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.services;
}
