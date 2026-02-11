import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/pin_helper.dart';
import '../../../core/data/enums/role_name.dart';
import '../../../core/data/models/role_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/search_utils.dart';

class UsersTab extends ConsumerStatefulWidget {
  const UsersTab({super.key});

  @override
  ConsumerState<UsersTab> createState() => _UsersTabState();
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: l.searchHint,
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (v) => setState(() => _query = normalizeSearch(v)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: () => _showEditDialog(context, ref, roles, null),
                        icon: const Icon(Icons.add),
                        label: Text(l.actionAdd),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                      columns: [
                        DataColumn(label: Text(l.fieldName)),
                        DataColumn(label: Text(l.fieldUsername)),
                        DataColumn(label: Text(l.fieldRole)),
                        DataColumn(label: Text(l.fieldActive)),
                        DataColumn(label: Text(l.fieldActions)),
                      ],
                      rows: filtered
                          .map((user) => DataRow(cells: [
                                DataCell(Text(user.fullName)),
                                DataCell(Text(user.username)),
                                DataCell(Text(_roleLabel(l, roles, user.roleId))),
                                DataCell(Icon(
                                  user.isActive ? Icons.check_circle : Icons.cancel,
                                  color: user.isActive ? Colors.green : Colors.grey,
                                  size: 20,
                                )),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () =>
                                          _showEditDialog(context, ref, roles, user),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () => _delete(context, ref, user),
                                    ),
                                  ],
                                )),
                              ]))
                          .toList(),
                        ),
                      ),
                    );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _roleLabel(dynamic l, List<RoleModel> roles, String roleId) {
    final role = roles.where((r) => r.id == roleId).firstOrNull;
    if (role == null) return '-';
    return switch (role.name) {
      RoleName.helper => l.roleHelper,
      RoleName.operator => l.roleOperator,
      RoleName.admin => l.roleAdmin,
    };
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    List<RoleModel> roles,
    UserModel? existing,
  ) async {
    final result = await showDialog<_UserFormResult>(
      context: context,
      builder: (_) => _UserEditDialog(roles: roles, existing: existing),
    );
    if (result == null) return;

    final company = ref.read(currentCompanyProvider)!;
    final userRepo = ref.read(userRepositoryProvider);
    final permRepo = ref.read(permissionRepositoryProvider);
    final activeUser = ref.read(activeUserProvider)!;

    if (existing != null) {
      final updated = existing.copyWith(
        fullName: result.fullName,
        username: result.username,
        roleId: result.roleId,
        isActive: result.isActive,
        pinHash: result.pin != null ? PinHelper.hashPin(result.pin!) : existing.pinHash,
      );
      await userRepo.update(updated);
      // Re-apply role permissions
      await permRepo.applyRoleToUser(
        companyId: company.id,
        userId: existing.id,
        roleId: result.roleId,
        grantedBy: activeUser.id,
        generateId: () => const Uuid().v7(),
      );
    } else {
      final id = const Uuid().v7();
      final model = UserModel(
        id: id,
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
      await permRepo.applyRoleToUser(
        companyId: company.id,
        userId: id,
        roleId: result.roleId,
        grantedBy: activeUser.id,
        generateId: () => const Uuid().v7(),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, UserModel user) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(userRepositoryProvider).delete(user.id);
    }
  }
}

class _UserFormResult {
  _UserFormResult({
    required this.fullName,
    required this.username,
    this.pin,
    required this.roleId,
    required this.isActive,
  });
  final String fullName;
  final String username;
  final String? pin;
  final String roleId;
  final bool isActive;
}

class _UserEditDialog extends StatefulWidget {
  const _UserEditDialog({required this.roles, this.existing});
  final List<RoleModel> roles;
  final UserModel? existing;

  @override
  State<_UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<_UserEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _usernameCtrl;
  final _pinCtrl = TextEditingController();
  final _pinConfirmCtrl = TextEditingController();
  late String _roleId;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController(text: widget.existing?.fullName ?? '');
    _usernameCtrl = TextEditingController(text: widget.existing?.username ?? '');
    _roleId = widget.existing?.roleId ?? (widget.roles.isNotEmpty ? widget.roles.first.id : '');
    _isActive = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _pinCtrl.dispose();
    _pinConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isNew = widget.existing == null;

    return AlertDialog(
      title: Text(isNew ? l.actionAdd : l.actionEdit),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fullNameCtrl,
                  decoration: InputDecoration(labelText: l.wizardFullName),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l.wizardFullNameRequired : null,
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
                      RoleName.admin => l.roleAdmin,
                    };
                    return DropdownMenuItem(value: r.id, child: Text(label));
                  }).toList(),
                  onChanged: (v) => setState(() => _roleId = v!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(l.fieldActive),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.actionCancel)),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                _UserFormResult(
                  fullName: _fullNameCtrl.text.trim(),
                  username: _usernameCtrl.text.trim(),
                  pin: _pinCtrl.text.isEmpty ? null : _pinCtrl.text,
                  roleId: _roleId,
                  isActive: _isActive,
                ),
              );
            }
          },
          child: Text(l.actionSave),
        ),
      ],
    );
  }
}
