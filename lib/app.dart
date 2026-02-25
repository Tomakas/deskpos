import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/data/providers/app_version_provider.dart';
import 'core/data/providers/auth_providers.dart';
import 'core/data/providers/sync_providers.dart';
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

    return MaterialApp.router(
      title: version != null ? 'Maty v$version' : 'Maty',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('cs'), Locale('en')],
      locale: Locale(ref.watch(pendingLocaleProvider) ?? ref.watch(appLocaleProvider).value ?? 'cs'),
      routerConfig: router,
      builder: (context, child) => InactivityDetector(
        child: PairingConfirmationListener(child: child!),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      extensions: const [lightAppColors],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(60, 52),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: const ChipThemeData(
        padding: EdgeInsets.symmetric(horizontal: 6),
        labelPadding: EdgeInsets.zero,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(60, 52),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
