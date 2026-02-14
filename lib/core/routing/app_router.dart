import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/screen_login.dart';
import '../../features/bills/screens/screen_bills.dart';
import '../../features/catalog/screens/screen_catalog.dart';
import '../../features/inventory/screens/screen_inventory.dart';
import '../../features/onboarding/screens/screen_display_code.dart';
import '../../features/orders/screens/screen_kds.dart';
import '../../features/sell/screens/screen_customer_display.dart';
import '../../features/orders/screens/screen_orders.dart';
import '../../features/vouchers/screens/screen_vouchers.dart';
import '../../features/onboarding/screens/screen_connect_company.dart';
import '../../features/onboarding/screens/screen_onboarding.dart';
import '../../features/sell/screens/screen_sell.dart';
import '../../features/settings/screens/screen_register_settings.dart';
import '../../features/settings/screens/screen_settings.dart';
import '../../features/settings/screens/screen_venue_settings.dart';
import '../data/providers/auth_providers.dart';
import '../data/providers/permission_providers.dart';

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

      final initState = initAsync is AsyncData<AppInitState> ? initAsync.value : null;
      final needsOnboarding = initState == AppInitState.needsOnboarding;
      final isDisplayMode = initState == AppInitState.displayMode;
      final isAuthenticated = session.isAuthenticated;

      // Display mode — route to customer display (no auth required)
      if (isDisplayMode && path != '/customer-display' && path != '/display-code') {
        return '/customer-display';
      }

      // Allow display-code without auth
      if (path == '/display-code') return null;

      // Needs onboarding — allow both /onboarding and /connect-company
      if (needsOnboarding && path != '/onboarding' && path != '/connect-company') {
        return '/onboarding';
      }

      // Not authenticated (but has company)
      if (!needsOnboarding && !isDisplayMode && !isAuthenticated &&
          path != '/login' && path != '/onboarding' && path != '/connect-company') {
        return '/login';
      }

      // Authenticated but on login/onboarding — go to bills
      if (isAuthenticated &&
          (path == '/login' || path == '/onboarding' || path == '/loading' || path == '/connect-company')) {
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
        path: '/connect-company',
        builder: (context, state) => const ScreenConnectCompany(),
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
        path: '/sell',
        builder: (context, state) => const ScreenSell(),
      ),
      GoRoute(
        path: '/sell/:billId',
        builder: (context, state) => ScreenSell(billId: state.pathParameters['billId']),
      ),
      GoRoute(
        path: '/display-code',
        builder: (context, state) => ScreenDisplayCode(
          type: state.uri.queryParameters['type'] ?? 'customer_display',
        ),
      ),
      GoRoute(
        path: '/customer-display',
        builder: (context, state) => ScreenCustomerDisplay(
          code: state.uri.queryParameters['code'],
        ),
      ),
      GoRoute(
        path: '/settings/company',
        redirect: (context, state) {
          final hasPermission = ref.read(hasPermissionProvider('settings.manage'));
          if (!hasPermission) return '/bills';
          return null;
        },
        builder: (context, state) => const ScreenCompanySettings(),
      ),
      GoRoute(
        path: '/settings/venue',
        redirect: (context, state) {
          final hasPermission = ref.read(hasPermissionProvider('settings.manage'));
          if (!hasPermission) return '/bills';
          return null;
        },
        builder: (context, state) => const ScreenVenueSettings(),
      ),
      GoRoute(
        path: '/settings/register',
        redirect: (context, state) {
          final hasPermission = ref.read(hasPermissionProvider('settings.manage'));
          if (!hasPermission) return '/bills';
          return null;
        },
        builder: (context, state) => const ScreenRegisterSettings(),
      ),
      GoRoute(
        path: '/catalog',
        redirect: (context, state) {
          final hasPermission = ref.read(hasPermissionProvider('settings.manage'));
          if (!hasPermission) return '/bills';
          return null;
        },
        builder: (context, state) => const ScreenCatalog(),
      ),
      GoRoute(
        path: '/inventory',
        redirect: (context, state) {
          final hasPermission = ref.read(hasPermissionProvider('settings.manage'));
          if (!hasPermission) return '/bills';
          return null;
        },
        builder: (context, state) => const ScreenInventory(),
      ),
      GoRoute(
        path: '/orders',
        redirect: (context, state) {
          final hasPermission = ref.read(hasPermissionProvider('orders.view'));
          if (!hasPermission) return '/bills';
          return null;
        },
        builder: (context, state) => const ScreenOrders(),
      ),
      GoRoute(
        path: '/kds',
        redirect: (context, state) {
          final hasPermission = ref.read(hasPermissionProvider('orders.view'));
          if (!hasPermission) return '/bills';
          return null;
        },
        builder: (context, state) => const ScreenKds(),
      ),
      GoRoute(
        path: '/vouchers',
        redirect: (context, state) {
          final hasPermission = ref.read(hasPermissionProvider('settings.manage'));
          if (!hasPermission) return '/bills';
          return null;
        },
        builder: (context, state) => const ScreenVouchers(),
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
