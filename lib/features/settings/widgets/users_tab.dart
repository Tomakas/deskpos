import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/pin_helper.dart';
import '../../../core/data/enums/role_name.dart';
import '../../../core/data/models/permission_model.dart';
import '../../../core/data/models/role_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/permission_l10n.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';

class UsersTab extends ConsumerStatefulWidget {
  const UsersTab({super.key});

  @override
  ConsumerState<UsersTab> createState() => _UsersTabState();
}

bool _isLastAdmin(List<UserModel> users, List<RoleModel> roles, UserModel user) {
  final adminRole = roles.where((r) => r.name == RoleName.admin).firstOrNull;
  if (adminRole == null || user.roleId != adminRole.id) return false;
  return users.where((u) => u.roleId == adminRole.id && u.isActive).length <= 1;
}

class _UsersTabState extends ConsumerState<UsersTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final usersStream = ref.watch(userRepositoryProvider).watchAll(company.id);
    final rolesStream = ref.watch(roleRepositoryProvider).watchAll();

    return StreamBuilder(
      stream: usersStream,
      builder: (context, usersSnap) {
        return StreamBuilder(
          stream: rolesStream,
          builder: (context, rolesSnap) {
            final users = usersSnap.data ?? [];
            final roles = rolesSnap.data ?? [];

            final filtered = users.where((u) {
              if (_query.isEmpty) return true;
              final q = _query;
              return normalizeSearch(u.fullName).contains(q)
                  || normalizeSearch(u.username).contains(q);
            }).toList();

            return Column(
              children: [
                PosTableToolbar(
                  searchController: _searchCtrl,
                  searchHint: l.searchHint,
                  onSearchChanged: (v) => setState(() => _query = normalizeSearch(v)),
                  trailing: [
                    FilledButton.icon(
                      onPressed: () => _showEditDialog(context, ref, roles, users, null),
                      icon: const Icon(Icons.add),
                      label: Text(l.actionAdd),
                    ),
                  ],
                ),
                Expanded(
                  child: PosTable<UserModel>(
                    columns: [
                      PosColumn(label: l.fieldName, flex: 3, cellBuilder: (user) => Text(user.fullName, overflow: TextOverflow.ellipsis)),
                      PosColumn(label: l.fieldUsername, flex: 2, cellBuilder: (user) => Text(user.username, overflow: TextOverflow.ellipsis)),
                      PosColumn(
                        label: l.fieldRole,
                        flex: 2,
                        cellBuilder: (user) => Consumer(
                          builder: (context, ref, _) {
                            final isCustom = ref.watch(isCustomPermissionsProvider((
                              companyId: company.id,
                              userId: user.id,
                              roleId: user.roleId,
                            )));
                            final roleName = _roleLabel(l, roles, user.roleId);
                            return Text(
                              isCustom ? '$roleName ${l.permissionsCustomized}' : roleName,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                      PosColumn(
                        label: l.fieldActive,
                        flex: 1,
                        cellBuilder: (user) => Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            user.isActive ? Icons.check_circle : Icons.cancel,
                            color: boolIndicatorColor(user.isActive, context),
                            size: 20,
                          ),
                        ),
                      ),
                      PosColumn(
                        label: l.fieldActions,
                        flex: 2,
                        cellBuilder: (user) {
                          final isLast = _isLastAdmin(users, roles, user);
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditDialog(context, ref, roles, users, user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.security, size: 20),
                                onPressed: () => _showEditDialog(context, ref, roles, users, user, initialTabIndex: 1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: isLast ? null : () => _delete(context, ref, user),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                    items: filtered,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _roleLabel(AppLocalizations l, List<RoleModel> roles, String roleId) {
    final role = roles.where((r) => r.id == roleId).firstOrNull;
    if (role == null) return '-';
    return switch (role.name) {
      RoleName.helper => l.roleHelper,
      RoleName.operator => l.roleOperator,
      RoleName.manager => l.roleManager,
      RoleName.admin => l.roleAdmin,
    };
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    List<RoleModel> roles,
    List<UserModel> users,
    UserModel? existing, {
    int initialTabIndex = 0,
  }) async {
    final isLast = existing != null ? _isLastAdmin(users, roles, existing) : false;
    final result = await showDialog<_UserFormResult>(
      context: context,
      builder: (_) => _UserEditDialog(
        roles: roles,
        existing: existing,
        isLastAdmin: isLast,
        initialTabIndex: initialTabIndex,
      ),
    );
    if (result == null || !mounted) return;

    final company = ref.read(currentCompanyProvider)!;
    final userRepo = ref.read(userRepositoryProvider);
    final permRepo = ref.read(permissionRepositoryProvider);
    final activeUser = ref.read(activeUserProvider)!;

    String userId;

    if (existing != null) {
      userId = existing.id;
      final updated = existing.copyWith(
        fullName: result.fullName,
        username: result.username,
        roleId: result.roleId,
        isActive: result.isActive,
        pinHash: result.pin != null ? PinHelper.hashPin(result.pin!) : existing.pinHash,
      );
      await userRepo.update(updated);
    } else {
      userId = const Uuid().v7();
      final model = UserModel(
        id: userId,
        companyId: company.id,
        fullName: result.fullName,
        username: result.username,
        pinHash: PinHelper.hashPin(result.pin!),
        roleId: result.roleId,
        isActive: result.isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await userRepo.create(model);
    }

    // Apply role template as baseline
    await permRepo.applyRoleToUser(
      companyId: company.id,
      userId: userId,
      roleId: result.roleId,
      grantedBy: activeUser.id,
      generateId: () => const Uuid().v7(),
    );

    // If permissions were customized, apply diff on top of role template
    if (result.permissionIds != null) {
      final rolePermsResult = await permRepo.getRolePermissions(result.roleId);
      if (rolePermsResult case Success(value: final rolePerms)) {
        final rolePermIds = rolePerms.map((p) => p.permissionId).toSet();
        final desired = result.permissionIds!;

        for (final id in desired.difference(rolePermIds)) {
          await permRepo.grantPermission(
            companyId: company.id,
            userId: userId,
            permissionId: id,
            grantedBy: activeUser.id,
            generateId: () => const Uuid().v7(),
          );
        }
        for (final id in rolePermIds.difference(desired)) {
          await permRepo.revokePermission(
            companyId: company.id,
            userId: userId,
            permissionId: id,
          );
        }
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, UserModel user) async {
    if (!await confirmDelete(context, context.l10n) || !mounted) return;
    await ref.read(userRepositoryProvider).delete(user.id);
  }
}

class _UserFormResult {
  _UserFormResult({
    required this.fullName,
    required this.username,
    this.pin,
    required this.roleId,
    required this.isActive,
    this.permissionIds,
  });
  final String fullName;
  final String username;
  final String? pin;
  final String roleId;
  final bool isActive;

  /// Desired permission IDs. null = use role template (no customization).
  final Set<String>? permissionIds;
}

class _UserEditDialog extends ConsumerStatefulWidget {
  const _UserEditDialog({
    required this.roles,
    this.existing,
    this.isLastAdmin = false,
    this.initialTabIndex = 0,
  });
  final List<RoleModel> roles;
  final UserModel? existing;
  final bool isLastAdmin;
  final int initialTabIndex;

  @override
  ConsumerState<_UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends ConsumerState<_UserEditDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _usernameCtrl;
  final _pinCtrl = TextEditingController();
  final _pinConfirmCtrl = TextEditingController();
  late String _roleId;
  late bool _isActive;
  late final TabController _tabCtrl;

  // Permissions state
  List<PermissionModel> _allPermissions = [];
  Set<String> _grantedPermissionIds = {};
  Set<String> _roleTemplateIds = {};
  bool _permissionsLoaded = false;
  bool _permissionsManuallyEdited = false;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController(text: widget.existing?.fullName ?? '');
    _usernameCtrl = TextEditingController(text: widget.existing?.username ?? '');
    _roleId = widget.existing?.roleId ?? (widget.roles.isNotEmpty ? widget.roles.first.id : '');
    _isActive = widget.existing?.isActive ?? true;
    _tabCtrl = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final permRepo = ref.read(permissionRepositoryProvider);

    // Load all permissions
    final allResult = await permRepo.getAll();
    final allPerms = switch (allResult) {
      Success(value: final v) => v,
      Failure() => <PermissionModel>[],
    };

    // Load role template
    final roleResult = await permRepo.getRolePermissions(_roleId);
    final rolePermIds = switch (roleResult) {
      Success(value: final v) => v.map((p) => p.permissionId).toSet(),
      Failure() => <String>{},
    };

    // Load user's current permissions (or use role template for new users)
    Set<String> grantedIds;
    if (widget.existing != null) {
      final company = ref.read(currentCompanyProvider)!;
      final userResult = await permRepo.getUserPermissions(
        company.id,
        widget.existing!.id,
      );
      grantedIds = switch (userResult) {
        Success(value: final v) => v.map((p) => p.permissionId).toSet(),
        Failure() => Set<String>.from(rolePermIds),
      };
    } else {
      grantedIds = Set<String>.from(rolePermIds);
    }

    if (!mounted) return;
    setState(() {
      _allPermissions = allPerms;
      _roleTemplateIds = rolePermIds;
      _grantedPermissionIds = grantedIds;
      _permissionsLoaded = true;
    });
  }

  Future<void> _loadRoleTemplate(String roleId) async {
    final permRepo = ref.read(permissionRepositoryProvider);
    final roleResult = await permRepo.getRolePermissions(roleId);
    final rolePermIds = switch (roleResult) {
      Success(value: final v) => v.map((p) => p.permissionId).toSet(),
      Failure() => <String>{},
    };
    if (!mounted) return;
    setState(() {
      _roleTemplateIds = rolePermIds;
      _grantedPermissionIds = Set<String>.from(rolePermIds);
      _permissionsManuallyEdited = false;
    });
  }

  void _onRoleChanged(String newRoleId) {
    if (newRoleId == _roleId) return;
    setState(() => _roleId = newRoleId);
    if (_permissionsManuallyEdited) {
      _showResetConfirmation(newRoleId);
    } else {
      _loadRoleTemplate(newRoleId);
    }
  }

  Future<void> _showResetConfirmation(String newRoleId) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => PosDialogShell(
        title: l.permissionsResetConfirm,
        children: [
          PosDialogActions(
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.no),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.yes),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _loadRoleTemplate(newRoleId);
    }
  }

  bool get _isCustomized {
    if (_grantedPermissionIds.length != _roleTemplateIds.length) return true;
    return !_roleTemplateIds.containsAll(_grantedPermissionIds);
  }

  void _togglePermission(String permissionId, bool granted) {
    setState(() {
      if (granted) {
        _grantedPermissionIds.add(permissionId);
      } else {
        _grantedPermissionIds.remove(permissionId);
      }
      _permissionsManuallyEdited = true;
    });
  }

  void _toggleGroup(String category, bool granted) {
    final groupPerms = _allPermissions.where((p) => p.category == category);
    setState(() {
      for (final p in groupPerms) {
        if (granted) {
          _grantedPermissionIds.add(p.id);
        } else {
          _grantedPermissionIds.remove(p.id);
        }
      }
      _permissionsManuallyEdited = true;
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        _UserFormResult(
          fullName: _fullNameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
          pin: _pinCtrl.text.isEmpty ? null : _pinCtrl.text,
          roleId: _roleId,
          isActive: _isActive,
          permissionIds: _isCustomized ? Set<String>.from(_grantedPermissionIds) : null,
        ),
      );
    } else {
      // Switch to profile tab if validation failed
      _tabCtrl.animateTo(0);
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _pinCtrl.dispose();
    _pinConfirmCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isNew = widget.existing == null;

    return PosDialogShell(
      title: isNew ? l.actionAdd : l.actionEdit,
      maxWidth: 700,
      expandHeight: true,
      children: [
        TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: l.tabProfile),
            Tab(text: l.tabPermissions),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildProfileTab(l, isNew),
              _buildPermissionsTab(l),
            ],
          ),
        ),
        const SizedBox(height: 8),
        PosDialogActions(
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            FilledButton(onPressed: _save, child: Text(l.actionSave)),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileTab(AppLocalizations l, bool isNew) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _fullNameCtrl,
              decoration: InputDecoration(labelText: l.wizardFullName),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.wizardFullNameRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameCtrl,
              decoration: InputDecoration(labelText: l.wizardUsername),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.wizardUsernameRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pinCtrl,
              decoration: InputDecoration(
                labelText: isNew ? l.wizardPin : '${l.wizardPin} (${l.actionEdit})',
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) {
                if (isNew && (v == null || v.isEmpty)) return l.wizardPinRequired;
                if (v != null && v.isNotEmpty && !PinHelper.isValidPin(v)) {
                  return l.wizardPinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pinConfirmCtrl,
              decoration: InputDecoration(labelText: l.wizardPinConfirm),
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) {
                if (_pinCtrl.text.isNotEmpty && v != _pinCtrl.text) {
                  return l.wizardPinMismatch;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _roleId,
              decoration: InputDecoration(labelText: l.fieldRole),
              items: widget.roles.map((r) {
                final label = switch (r.name) {
                  RoleName.helper => l.roleHelper,
                  RoleName.operator => l.roleOperator,
                  RoleName.manager => l.roleManager,
                  RoleName.admin => l.roleAdmin,
                };
                return DropdownMenuItem(value: r.id, child: Text(label));
              }).toList(),
              onChanged: widget.isLastAdmin ? null : (v) => _onRoleChanged(v!),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(l.fieldActive),
              value: _isActive,
              onChanged: widget.isLastAdmin ? null : (v) => setState(() => _isActive = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsTab(AppLocalizations l) {
    if (!_permissionsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // Group permissions by category in display order
    final grouped = <String, List<PermissionModel>>{};
    for (final category in permissionGroupOrder) {
      final perms = _allPermissions.where((p) => p.category == category).toList();
      if (perms.isNotEmpty) grouped[category] = perms;
    }

    return Column(
      children: [
        // Header with reset button
        if (_isCustomized && !widget.isLastAdmin)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _loadRoleTemplate(_roleId),
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: Text(l.permissionsResetToRole),
                ),
              ],
            ),
          ),
        // Permission groups
        Expanded(
          child: ListView.builder(
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final category = grouped.keys.elementAt(index);
              final perms = grouped[category]!;
              final grantedCount =
                  perms.where((p) => _grantedPermissionIds.contains(p.id)).length;
              final allGranted = grantedCount == perms.length;
              final noneGranted = grantedCount == 0;

              return ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${localizedPermissionGroup(l, category)} ($grantedCount/${perms.length})',
                      ),
                    ),
                  ],
                ),
                leading: Checkbox(
                  value: allGranted
                      ? true
                      : noneGranted
                          ? false
                          : null,
                  tristate: true,
                  onChanged: widget.isLastAdmin ? null : (_) => _toggleGroup(category, !allGranted),
                ),
                children: [
                  for (final perm in perms)
                    CheckboxListTile(
                      title: Text(localizedPermissionName(l, perm.code)),
                      value: _grantedPermissionIds.contains(perm.id),
                      onChanged: widget.isLastAdmin ? null : (v) => _togglePermission(perm.id, v ?? false),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
