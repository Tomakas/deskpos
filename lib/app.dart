import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/data/providers/auth_providers.dart';
import 'core/data/providers/sync_providers.dart';
import 'core/routing/app_router.dart';
import 'core/widgets/inactivity_detector.dart';
import 'l10n/app_localizations.dart';

class EposApp extends ConsumerWidget {
  const EposApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Activate sync lifecycle: auto-starts/stops based on Supabase auth state
    ref.watch(syncLifecycleWatcherProvider);

    return MaterialApp.router(
      title: 'EPOS',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('cs'), Locale('en')],
      locale: Locale(ref.watch(appLocaleProvider).value ?? 'cs'),
      routerConfig: router,
      builder: (context, child) => InactivityDetector(child: child!),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(160, 52),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(160, 52),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
