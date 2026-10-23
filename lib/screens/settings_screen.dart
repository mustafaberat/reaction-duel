/// Settings: language (live), color-blind, reduce motion,
/// How to Play, tips reset, privacy, version.
library;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../components/form_rows.dart';
import '../components/screen_header.dart';
import '../components/segmented_choice.dart';
import '../config/app_config.dart';
import '../config/tokens.dart';
import '../l10n/app_localizations.dart';
import '../services/settings_service.dart';
import '../theme/decor.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final lang = settings.language;

    return ThemedScaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.settings),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.page,
                      0,
                      AppDimens.page,
                      AppDimens.gapXxl,
                    ),
                    children: [
                      SectionLabel(l10n.settingsGeneral),
                      GroupCard(
                        children: [
                          NavRow(
                            icon: Icons.translate_rounded,
                            title: l10n.settingsLanguage,
                            value: lang == null
                                ? l10n.settingsLanguageSystem
                                : SettingsService.languageNames[lang],
                            onTap: () => _pickLanguage(context),
                          ),
                        ],
                      ),
                      SectionLabel(l10n.settingsAccessibility),
                      GroupCard(
                        children: [
                          ToggleRow(
                            icon: Icons.contrast_rounded,
                            title: l10n.settingsColorBlind,
                            subtitle: l10n.settingsColorBlindHint,
                            value: settings.colorBlind,
                            onChanged: settings.setColorBlind,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppDimens.gapL,
                              AppDimens.gapM,
                              AppDimens.gapL,
                              AppDimens.gapL,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.motion_photos_off_outlined,
                                      size: AppDimens.icon,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(width: AppDimens.gapM),
                                    Text(l10n.settingsReduceMotion, style: theme.titleMedium),
                                  ],
                                ),
                                const SizedBox(height: AppDimens.gapM),
                                SegmentedChoice<ReduceMotionPref>(
                                  value: settings.reduceMotion,
                                  onChanged: settings.setReduceMotion,
                                  options: [
                                    SegmentOption(ReduceMotionPref.system, l10n.motionSystem),
                                    SegmentOption(ReduceMotionPref.on, l10n.motionOn),
                                    SegmentOption(ReduceMotionPref.off, l10n.motionOff),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SectionLabel(l10n.settingsGame),
                      GroupCard(
                        children: [
                          NavRow(
                            icon: Icons.help_outline_rounded,
                            title: l10n.howToPlay,
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.howTo),
                          ),
                          NavRow(
                            icon: Icons.lightbulb_outline_rounded,
                            title: l10n.settingsShowTips,
                            trailingIcon: null,
                            onTap: () {
                              settings.setOnboardingDone(false);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(l10n.settingsTipsReset)));
                            },
                          ),
                        ],
                      ),
                      SectionLabel(l10n.settingsAbout),
                      GroupCard(
                        children: [
                          NavRow(
                            icon: Icons.shield_outlined,
                            title: l10n.settingsPrivacy,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => launchUrl(
                              Uri.parse(AppIdentity.privacyUrl),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                          const _VersionRow(),
                        ],
                      ),
                      const SizedBox(height: AppDimens.gapXl),
                      Center(
                        child: Text(
                          '${AppIdentity.appName}${AppGlyphs.separator}${AppIdentity.developer}',
                          style: theme.bodySmall!.copyWith(color: AppColors.textFaint),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickLanguage(BuildContext context) {
    final settings = AppScope.read(context).settings;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        Widget option(String? code, String label) {
          final selected = settings.language == code;
          return ListTile(
            title: Text(label, style: Theme.of(sheetContext).textTheme.titleMedium),
            trailing: selected ? Icon(Icons.check_rounded, color: AppColors.accent) : null,
            onTap: () {
              settings.setLanguage(code);
              Navigator.of(sheetContext).pop();
            },
          );
        }

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8),
            child: ListView(
              shrinkWrap: true,
              children: [
                option(null, l10n.settingsLanguageSystem),
                for (final code in SettingsService.supportedLanguages)
                  option(code, SettingsService.languageNames[code]!),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VersionRow extends StatefulWidget {
  const _VersionRow();

  @override
  State<_VersionRow> createState() => _VersionRowState();
}

class _VersionRowState extends State<_VersionRow> {
  String? _version;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform()
        .then((info) {
          if (mounted) setState(() => _version = '${info.version} (${info.buildNumber})');
        })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavRow(
      icon: Icons.info_outline_rounded,
      title: l10n.settingsVersion,
      value: _version ?? '',
      trailingIcon: null,
      onTap: null,
    );
  }
}
