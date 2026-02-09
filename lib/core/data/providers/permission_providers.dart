import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';
import 'repository_providers.dart';

/// Reactive set of permission codes for the active user
final userPermissionCodesProvider = StreamProvider<Set<String>>((ref) {
  final user = ref.watch(activeUserProvider);
  final company = ref.watch(currentCompanyProvider);
  if (user == null || company == null) return Stream.value({});

  return ref.watch(permissionRepositoryProvider).watchUserPermissionCodes(
        company.id,
        user.id,
      );
});

/// O(1) permission check: hasPermissionProvider('orders.void')
final hasPermissionProvider = Provider.family<bool, String>((ref, code) {
  final permsAsync = ref.watch(userPermissionCodesProvider);
  return permsAsync.whenOrNull(data: (codes) => codes.contains(code)) ?? false;
});
