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

/// O(1) permission check: hasPermissionProvider('orders.void_item')
final hasPermissionProvider = Provider.family<bool, String>((ref, code) {
  final permsAsync = ref.watch(userPermissionCodesProvider);
  return permsAsync.whenOrNull(data: (codes) => codes.contains(code)) ?? false;
});

/// True if user has at least one permission in the given group:
/// hasAnyPermissionInGroupProvider('products') → any 'products.*' code
final hasAnyPermissionInGroupProvider = Provider.family<bool, String>((ref, group) {
  final permsAsync = ref.watch(userPermissionCodesProvider);
  final prefix = '$group.';
  return permsAsync.whenOrNull(
    data: (codes) => codes.any((c) => c.startsWith(prefix)),
  ) ?? false;
});

/// Reactive set of permission IDs for a role (for comparison with user permissions)
final rolePermissionIdsProvider = StreamProvider.family<Set<String>, String>((ref, roleId) {
  return ref.watch(permissionRepositoryProvider).watchRolePermissionIds(roleId);
});

/// Reactive set of permission IDs for a specific user
final userPermissionIdsProvider =
    StreamProvider.family<Set<String>, ({String companyId, String userId})>((ref, params) {
  return ref
      .watch(permissionRepositoryProvider)
      .watchUserPermissionIds(params.companyId, params.userId);
});

/// Whether user's permissions differ from their role template
final isCustomPermissionsProvider =
    Provider.family<bool, ({String companyId, String userId, String roleId})>((ref, params) {
  final rolePerms = ref.watch(rolePermissionIdsProvider(params.roleId));
  final userPerms = ref.watch(
    userPermissionIdsProvider((companyId: params.companyId, userId: params.userId)),
  );

  final roleIds = rolePerms.whenOrNull(data: (s) => s);
  final userIds = userPerms.whenOrNull(data: (s) => s);
  if (roleIds == null || userIds == null) return false;

  if (roleIds.length != userIds.length) return true;
  return !roleIds.containsAll(userIds);
});
