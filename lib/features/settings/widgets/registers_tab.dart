import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/display_device_type.dart';
import '../../../core/data/enums/hardware_type.dart';
import '../../../core/data/models/display_device_model.dart';
import '../../../core/data/models/register_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/pos_table.dart';

// ---------------------------------------------------------------------------
// Unified entry for the combined register + display device table.
// ---------------------------------------------------------------------------

sealed class _DeviceEntry {
  String get id;
}

class _RegisterEntry implements _DeviceEntry {
  _RegisterEntry(this.register);
  final RegisterModel register;
  @override
  String get id => register.id;
}

class _DisplayEntry implements _DeviceEntry {
  _DisplayEntry(this.device, {this.parentRegisterName});
  final DisplayDeviceModel device;
  final String? parentRegisterName;
  @override
  String get id => device.id;
}

// ---------------------------------------------------------------------------
// RegistersTab — registers + display devices in one table.
// Three creation buttons: Pokladna, Zákaznický displej, KDS.
// Type is immutable after creation.
// ---------------------------------------------------------------------------

class RegistersTab extends ConsumerWidget {
  const RegistersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final deviceRegAsync = ref.watch(deviceRegistrationProvider);
    final sessionAsync = ref.watch(activeRegisterSessionProvider);
    final hasActiveSession = sessionAsync.valueOrNull != null;
    final myDeviceId = ref.watch(deviceIdProvider).valueOrNull;

    return StreamBuilder<List<RegisterModel>>(
      stream: ref.watch(registerRepositoryProvider).watchAll(company.id),
      builder: (context, regSnap) {
        final registers = regSnap.data ?? [];
        final deviceReg = deviceRegAsync.valueOrNull;

        return StreamBuilder<List<DisplayDeviceModel>>(
          stream:
              ref.watch(displayDeviceRepositoryProvider).watchAll(company.id),
          builder: (context, dispSnap) {
            final displayDevices = dispSnap.data ?? [];

            // Combined list: registers first, then display devices
            final entries = <_DeviceEntry>[
              for (final r in registers) _RegisterEntry(r),
              for (final d in displayDevices)
                _DisplayEntry(
                  d,
                  parentRegisterName: registers
                      .where((r) => r.id == d.parentRegisterId)
                      .map((r) => r.name.isEmpty ? r.code : r.name)
                      .firstOrNull,
                ),
            ];

            return Column(
              children: [
                if (hasActiveSession)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: theme.colorScheme.errorContainer,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 18,
                            color: theme.colorScheme.onErrorContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.registerSessionActiveCannotChange,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                PosTableToolbar(
                  trailing: [
                    FilledButton.icon(
                      onPressed: () =>
                          _showRegisterDialog(context, ref, null, registers),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l.modePOS),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: registers.isEmpty
                          ? null
                          : () => _showCreateDisplayDialog(
                                context,
                                ref,
                                DisplayDeviceType.customerDisplay,
                                registers,
                              ),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l.modeCustomerDisplay),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: registers.isEmpty
                          ? null
                          : () => _showCreateDisplayDialog(
                                context,
                                ref,
                                DisplayDeviceType.kds,
                                registers,
                              ),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l.displayDeviceAddKds),
                    ),
                  ],
                ),
                Expanded(
                  child: PosTable<_DeviceEntry>(
                    columns: [
                      PosColumn(
                        label: l.registerName,
                        flex: 3,
                        cellBuilder: (entry) => switch (entry) {
                          _RegisterEntry(:final register) => Row(
                              children: [
                                if (register.isMain) ...[
                                  Icon(Icons.star,
                                      size: 16,
                                      color: Colors.amber.shade700),
                                  const SizedBox(width: 4),
                                ],
                                Icon(Icons.point_of_sale,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    register.name.isEmpty
                                        ? register.code
                                        : register.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          _DisplayEntry(:final device) => Row(
                              children: [
                                Icon(
                                  device.type ==
                                          DisplayDeviceType.customerDisplay
                                      ? Icons.tv
                                      : Icons.restaurant_menu,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    device.name.isEmpty
                                        ? _displayTypeLabel(l, device.type)
                                        : device.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        },
                      ),
                      PosColumn(
                        label: l.registerType,
                        flex: 2,
                        cellBuilder: (entry) => Text(
                          switch (entry) {
                            _RegisterEntry(:final register) =>
                              '${l.modePOS} (${_registerTypeLabel(l, register.type)})',
                            _DisplayEntry(:final device) =>
                              _displayTypeLabel(l, device.type),
                          },
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PosColumn(
                        label: '',
                        flex: 3,
                        cellBuilder: (entry) => switch (entry) {
                          _RegisterEntry(:final register) =>
                            _PaymentFlags(register: register, l: l),
                          _DisplayEntry(
                            :final device,
                            :final parentRegisterName
                          ) =>
                            Row(
                              children: [
                                Text(
                                  device.code,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => Clipboard.setData(
                                      ClipboardData(text: device.code)),
                                  child: const Icon(Icons.copy, size: 14),
                                ),
                                if (parentRegisterName != null) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '\u2192 $parentRegisterName',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                        },
                      ),
                      PosColumn(
                        label: l.registerBoundHere,
                        flex: 2,
                        cellBuilder: (entry) => switch (entry) {
                          _RegisterEntry(:final register) =>
                            _buildBindingCell(
                              context,
                              ref,
                              l,
                              register,
                              deviceReg,
                              myDeviceId,
                              hasActiveSession,
                              company.id,
                            ),
                          _DisplayEntry() => const SizedBox.shrink(),
                        },
                      ),
                      PosColumn(
                        label: l.fieldActions,
                        flex: 2,
                        cellBuilder: (entry) => switch (entry) {
                          _RegisterEntry(:final register) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showRegisterDialog(
                                      context, ref, register, registers),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: register.isMain
                                      ? null
                                      : () => _deleteRegister(
                                          context, ref, register),
                                ),
                              ],
                            ),
                          _DisplayEntry(:final device) => IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () =>
                                  _deleteDisplayDevice(context, ref, device),
                            ),
                        },
                      ),
                    ],
                    items: entries,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _buildBindingCell(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
    RegisterModel register,
    dynamic deviceReg,
    String? myDeviceId,
    bool hasActiveSession,
    String companyId,
  ) {
    final isBound = deviceReg?.registerId == register.id;
    if (isBound) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link, size: 18, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            l.registerBoundHere,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    final boundElsewhere =
        register.boundDeviceId != null && register.boundDeviceId != myDeviceId;
    if (boundElsewhere) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              l.registerBoundOnOtherDevice,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    return TextButton(
      onPressed: hasActiveSession
          ? null
          : () => _bindRegister(context, ref, companyId, register.id),
      child: Text(l.registerBindAction),
    );
  }

  String _registerTypeLabel(AppLocalizations l, HardwareType type) {
    return switch (type) {
      HardwareType.local => l.registerTypeLocal,
      HardwareType.mobile => l.registerTypeMobile,
      HardwareType.virtual => l.registerTypeVirtual,
    };
  }

  String _displayTypeLabel(AppLocalizations l, DisplayDeviceType type) {
    return switch (type) {
      DisplayDeviceType.customerDisplay => l.modeCustomerDisplay,
      DisplayDeviceType.kds => l.modeKDS,
    };
  }

  // ---------------------------------------------------------------------------
  // Register actions
  // ---------------------------------------------------------------------------

  Future<void> _bindRegister(
    BuildContext context,
    WidgetRef ref,
    String companyId,
    String registerId,
  ) async {
    final myDeviceId = await ref.read(deviceIdProvider.future);
    await ref.read(deviceRegistrationRepositoryProvider).bind(
          companyId: companyId,
          registerId: registerId,
          deviceId: myDeviceId,
        );
    ref.invalidate(deviceRegistrationProvider);
    ref.invalidate(activeRegisterProvider);
    ref.invalidate(activeRegisterSessionProvider);
  }

  Future<void> _showRegisterDialog(
    BuildContext context,
    WidgetRef ref,
    RegisterModel? existing,
    List<RegisterModel> allRegisters,
  ) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var type = existing?.type ?? HardwareType.local;
    var isMain = existing?.isMain ?? false;
    var isActive = existing?.isActive ?? true;
    var allowCash = existing?.allowCash ?? true;
    var allowCard = existing?.allowCard ?? true;
    var allowTransfer = existing?.allowTransfer ?? true;
    var allowRefunds = existing?.allowRefunds ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? l.modePOS : l.actionEdit),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: l.registerName),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<HardwareType>(
                    initialValue: type,
                    decoration: InputDecoration(labelText: l.registerType),
                    items: HardwareType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(_registerTypeLabel(l, t)),
                            ))
                        .toList(),
                    onChanged: (v) => setDialogState(() => type = v!),
                  ),
                  if (existing != null && type == HardwareType.local) ...[
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(l.registerIsMain),
                      value: isMain,
                      onChanged: isMain
                          ? null
                          : (v) => setDialogState(() => isMain = v),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(l.fieldActive),
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v),
                  ),
                  const Divider(),
                  Text(
                    l.registerPaymentFlags,
                    style: Theme.of(ctx).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(l.registerAllowCash),
                    value: allowCash,
                    onChanged: (v) => setDialogState(() => allowCash = v),
                  ),
                  SwitchListTile(
                    title: Text(l.registerAllowCard),
                    value: allowCard,
                    onChanged: (v) => setDialogState(() => allowCard = v),
                  ),
                  SwitchListTile(
                    title: Text(l.registerAllowTransfer),
                    value: allowTransfer,
                    onChanged: (v) =>
                        setDialogState(() => allowTransfer = v),
                  ),
                  SwitchListTile(
                    title: Text(l.registerAllowRefunds),
                    value: allowRefunds,
                    onChanged: (v) =>
                        setDialogState(() => allowRefunds = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.actionSave),
            ),
          ],
        ),
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(registerRepositoryProvider);

    if (existing != null) {
      await repo.update(existing.copyWith(
        name: nameCtrl.text.trim(),
        type: type,
        isActive: isActive,
        allowCash: allowCash,
        allowCard: allowCard,
        allowTransfer: allowTransfer,
        allowRefunds: allowRefunds,
      ));
      if (isMain && !existing.isMain) {
        await repo.setMain(company.id, existing.id);
      }
    } else {
      final mainReg = allRegisters.where((r) => r.isMain).firstOrNull;
      final parentId = type != HardwareType.local ? mainReg?.id : null;

      await repo.create(
        companyId: company.id,
        name: nameCtrl.text.trim(),
        type: type,
        parentRegisterId: parentId,
        allowCash: allowCash,
        allowCard: allowCard,
        allowTransfer: allowTransfer,
        allowRefunds: allowRefunds,
      );
    }
    ref.invalidate(activeRegisterProvider);
  }

  Future<void> _deleteRegister(
      BuildContext context, WidgetRef ref, RegisterModel register) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.yes),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(registerRepositoryProvider).delete(register.id);
      ref.invalidate(activeRegisterProvider);
    }
  }

  // ---------------------------------------------------------------------------
  // Display device actions
  // ---------------------------------------------------------------------------

  Future<void> _showCreateDisplayDialog(
    BuildContext context,
    WidgetRef ref,
    DisplayDeviceType type,
    List<RegisterModel> registers,
  ) async {
    final l = context.l10n;
    String? parentRegisterId =
        registers.length == 1 ? registers.first.id : null;
    final nameCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(_displayTypeLabel(l, type)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l.registerName),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: parentRegisterId,
                  decoration: InputDecoration(labelText: l.registerParent),
                  items: registers
                      .map((r) => DropdownMenuItem(
                            value: r.id,
                            child: Text(
                                r.name.isEmpty ? r.code : r.name),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => parentRegisterId = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: parentRegisterId == null
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: Text(l.actionSave),
            ),
          ],
        ),
      ),
    );

    if (result != true || parentRegisterId == null) return;

    final company = ref.read(currentCompanyProvider)!;
    await ref.read(displayDeviceRepositoryProvider).create(
          companyId: company.id,
          parentRegisterId: parentRegisterId!,
          name: nameCtrl.text.trim(),
          type: type,
        );
  }

  Future<void> _deleteDisplayDevice(
    BuildContext context,
    WidgetRef ref,
    DisplayDeviceModel device,
  ) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.yes),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(displayDeviceRepositoryProvider).delete(device.id);
    }
  }
}

// ---------------------------------------------------------------------------
// Payment flags display
// ---------------------------------------------------------------------------

class _PaymentFlags extends StatelessWidget {
  const _PaymentFlags({required this.register, required this.l});
  final RegisterModel register;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final flags = <String>[];
    if (register.allowCash) flags.add(l.registerAllowCash);
    if (register.allowCard) flags.add(l.registerAllowCard);
    if (register.allowTransfer) flags.add(l.registerAllowTransfer);
    if (register.allowRefunds) flags.add(l.registerAllowRefunds);
    return Text(
      flags.join(', '),
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
