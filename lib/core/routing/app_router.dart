import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/screen_login.dart';
import '../../features/bills/screens/screen_bills.dart';
import '../../features/onboarding/screens/screen_onboarding.dart';
import '../../features/sell/screens/screen_sell.dart';
import '../../features/settings/screens/screen_settings.dart';
import '../data/providers/auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/loading',
    refreshListenable: _RouterNotifier(ref),
    redirect: (context, state) {
      final initAsync = ref.read(appInitProvider);
      final session = ref.read(sessionManagerProvider);
      final path = state.uri.path;

      // Still loading
      if (initAsync is AsyncLoading) return '/loading';

      final needsOnboarding = initAsync is AsyncData<AppInitState> &&
          initAsync.value == AppInitState.needsOnboarding;
      final isAuthenticated = session.isAuthenticated;

      // Needs onboarding
      if (needsOnboarding && path != '/onboarding') return '/onboarding';

      // Not authenticated (but has company)
      if (!needsOnboarding && !isAuthenticated && path != '/login' && path != '/onboarding') {
        return '/login';
      }

      // Authenticated but on login/onboarding — go to bills
      if (isAuthenticated && (path == '/login' || path == '/onboarding' || path == '/loading')) {
        return '/bills';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const _LoadingScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const ScreenOnboarding(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const ScreenLogin(),
      ),
      GoRoute(
        path: '/bills',
        builder: (context, state) => const ScreenBills(),
      ),
      GoRoute(
        path: '/sell/:billId',
        builder: (context, state) => ScreenSell(billId: state.pathParameters['billId']!),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const ScreenSettings(),
      ),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(appInitProvider, (_, _) => notifyListeners());
    _ref.listen(activeUserProvider, (_, _) => notifyListeners());
  }
  final Ref _ref;
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
