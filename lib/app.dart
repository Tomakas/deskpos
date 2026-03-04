import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/data/providers/app_version_provider.dart';
import 'core/data/providers/auth_providers.dart';
import 'core/data/providers/sync_providers.dart';
import 'core/data/providers/theme_providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/inactivity_detector.dart';
import 'core/widgets/pairing_confirmation_listener.dart';
import 'l10n/app_localizations.dart';

class MatyApp extends ConsumerWidget {
  const MatyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Activate sync lifecycle: auto-starts/stops based on Supabase auth state
    ref.watch(syncLifecycleWatcherProvider);
    // Activate pairing listener: shows confirmation dialog on main register
    ref.watch(pairingListenerProvider);

    final version = ref.watch(appVersionProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final seedColor = Color(accentColor);

    return MaterialApp.router(
      title: version != null ? 'Maty v$version' : 'Maty',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light, lightAppColors, seedColor),
      darkTheme: _buildTheme(Brightness.dark, darkAppColors, seedColor),
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('cs'), Locale('en')],
      locale: Locale(ref.watch(pendingLocaleProvider) ?? ref.watch(appLocaleProvider).value ?? 'cs'),
      routerConfig: router,
      builder: (context, child) => InactivityDetector(
        child: PairingConfirmationListener(child: child!),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness, AppColorsExtension colors, Color seedColor) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      extensions: [colors],
      appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDark ? BorderSide(color: scheme.outlineVariant, width: 0.5) : BorderSide.none,
        ),
        elevation: isDark ? 0 : 1,
      ),
      dialogTheme: DialogThemeData(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        labelPadding: EdgeInsets.zero,
        selectedColor: scheme.secondaryContainer,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(60, 52),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(60, 52),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          side: isDark ? BorderSide(color: scheme.outline, width: 1.5) : null,
        ),
      ),
      inputDecorationTheme: isDark
          ? InputDecorationTheme(
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
            )
          : null,
    );
  }
}
