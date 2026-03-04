import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/theme_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';

class AppearanceTab extends ConsumerWidget {
  const AppearanceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final currentMode = ref.watch(themeModeProvider);
    final currentAccent = ref.watch(accentColorProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme mode
          Text(l.settingsThemeMode, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final mode in ThemeMode.values) ...[
                if (mode != ThemeMode.values.first) const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FilterChip(
                      label: SizedBox(
                        width: double.infinity,
                        child: Text(
                          _themeModeLabel(l, mode),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      selected: currentMode == mode,
                      onSelected: (_) {
                        ref.read(themeModeProvider.notifier).setMode(mode);
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
          // Accent color
          const SizedBox(height: 24),
          Text(l.settingsAccentColor, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final preset in kAccentPresets)
                GestureDetector(
                  onTap: () => ref.read(accentColorProvider.notifier).setColor(preset),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(preset),
                      shape: BoxShape.circle,
                      border: currentAccent == preset
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(AppLocalizations l, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l.settingsThemeSystem;
      case ThemeMode.light:
        return l.settingsThemeLight;
      case ThemeMode.dark:
        return l.settingsThemeDark;
    }
  }
}
