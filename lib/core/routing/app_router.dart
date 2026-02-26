import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/screen_login.dart';
import '../../features/bills/screens/screen_bills.dart';
import '../../features/bills/screens/screen_reservations.dart';
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
import '../../features/data/screens/screen_data.dart';
import '../../features/statistics/screens/screen_statistics.dart';
import '../../features/settings/screens/screen_register_settings.dart';
import '../../features/settings/screens/screen_settings.dart';
import '../../features/settings/screens/screen_settings_unified.dart';
import '../../features/settings/screens/screen_venue_settings.dart';
import '../data/enums/sell_mode.dart';
import '../data/providers/auth_providers.dart';
import '../data/providers/permission_providers.dart';

String _homeRoute(Ref ref) {
  final register = ref.read(activeRegisterProvider).valueOrNull;
  return register?.sellMode == SellMode.retail ? '/sell' : '/bills';
}

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

      // Customer display mode — no auth required
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

      // Authenticated but on login/onboarding — go to home
      if (isAuthenticated &&
          (path == '/login' || path == '/onboarding' || path == '/loading' || path == '/connect-company')) {
        return _homeRoute(ref);
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
        path: '/settings',
        redirect: (context, state) {
          final canCompany = ref.read(hasAnyPermissionInGroupProvider('settings_company'));
          final canVenue = ref.read(hasAnyPermissionInGroupProvider('settings_venue'));
          final canRegister = ref.read(hasAnyPermissionInGroupProvider('settings_register'));
          if (!canCompany && !canVenue && !canRegister) return _homeRoute(ref);
          return null;
        },
        builder: (context, state) => const ScreenSettingsUnified(),
      ),
      GoRoute(
        path: '/settings/company',
        redirect: (context, state) {
          final hasPermission = ref.read(hasAnyPermissionInGroupProvider('settings_company'));
          if (!hasPermission) return _homeRoute(ref);
          return null;
        },
        builder: (context, state) => const ScreenCompanySettings(),
      ),
      GoRoute(
        path: '/settings/venue',
        redirect: (context, state) {
          final hasPermission = ref.read(hasAnyPermissionInGroupProvider('settings_venue'));
          if (!hasPermission) return _homeRoute(ref);
          return null;
        },
        builder: (context, state) => const ScreenVenueSettings(),
      ),
      GoRoute(
        path: '/settings/register',
        redirect: (context, state) {
          final hasPermission = ref.read(hasAnyPermissionInGroupProvider('settings_register'));
          if (!hasPermission) return _homeRoute(ref);
          return null;
        },
        builder: (context, state) => const ScreenRegisterSettings(),
      ),
      GoRoute(
        path: '/catalog',
        redirect: (context, state) {
          final hasPermission = ref.read(hasAnyPermissionInGroupProvider('products'));
          if (!hasPermission) return _homeRoute(ref);
          return null;
        },
        builder: (context, state) => const ScreenCatalog(),
      ),
      GoRoute(
        path: '/inventory',
        redirect: (context, state) {
          final hasPermission = ref.read(hasAnyPermissionInGroupProvider('stock'));
          if (!hasPermission) return _homeRoute(ref);
          return null;
        },
        builder: (context, state) => const ScreenInventory(),
      ),
      GoRoute(
        path: '/orders',
        redirect: (context, state) {
          final hasPermission = ref.read(hasPermissionProvider('orders.view'));
          if (!hasPermission) return _homeRoute(ref);
          return null;
        },
        builder: (context, state) => const ScreenOrders(),
      ),
      GoRoute(
        path: '/kds',
        builder: (context, state) => const ScreenKds(),
      ),
      GoRoute(
        path: '/vouchers',
        redirect: (context, state) {
          final hasPermission = ref.read(hasAnyPermissionInGroupProvider('vouchers'));
          if (!hasPermission) return _homeRoute(ref);
          return null;
        },
        builder: (context, state) => const ScreenVouchers(),
      ),
      GoRoute(
        path: '/data',
        redirect: (context, state) {
          final hasPermission = ref.read(hasAnyPermissionInGroupProvider('data'));
          if (!hasPermission) return _homeRoute(ref);
          return null;
        },
        builder: (context, state) => const ScreenData(),
      ),
      GoRoute(
        path: '/statistics',
        redirect: (context, state) {
          final hasPermission = ref.read(hasAnyPermissionInGroupProvider('stats'));
          if (!hasPermission) return _homeRoute(ref);
          return null;
        },
        builder: (context, state) => const ScreenStatistics(),
      ),
      GoRoute(
        path: '/reservations',
        redirect: (context, state) {
          final hasPermission = ref.read(hasPermissionProvider('venue.reservations_view'));
          if (!hasPermission) return _homeRoute(ref);
          return null;
        },
        builder: (context, state) => const ScreenReservations(),
      ),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(appInitProvider, (_, __) => notifyListeners());
    _ref.listen(activeUserProvider, (_, __) => notifyListeners());
    _ref.listen(activeRegisterProvider, (_, __) => notifyListeners());
    _ref.listen(userPermissionCodesProvider, (_, __) => notifyListeners());
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
