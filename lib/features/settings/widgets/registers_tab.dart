import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/hardware_type.dart';
import '../../../core/data/models/register_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/widgets/pos_table.dart';

class RegistersTab extends ConsumerWidget {
  const RegistersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<RegisterModel>>(
      stream: ref.watch(registerRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final registers = snap.data ?? [];
        return Column(
          children: [
            PosTableToolbar(
              trailing: [
                FilledButton.icon(
                  onPressed: () => _showEditDialog(context, ref, null, registers),
                  icon: const Icon(Icons.add),
                  label: Text(l.actionAdd),
                ),
              ],
            ),
            Expanded(
              child: PosTable<RegisterModel>(
                columns: [
                  PosColumn(
                    label: '#',
                    flex: 1,
                    cellBuilder: (r) => Text('${r.registerNumber}'),
                  ),
                  PosColumn(
                    label: l.registerName,
                    flex: 3,
                    cellBuilder: (r) => Text(
                      r.name.isEmpty ? r.code : r.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PosColumn(
                    label: l.registerType,
                    flex: 2,
                    cellBuilder: (r) => Text(
                      _typeLabel(l, r.type),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PosColumn(
                    label: l.registerPaymentFlags,
                    flex: 3,
                    cellBuilder: (r) => _PaymentFlags(register: r, l: l),
                  ),
                  PosColumn(
                    label: l.fieldActive,
                    flex: 1,
                    cellBuilder: (r) => Icon(
                      r.isActive ? Icons.check_circle : Icons.cancel,
                      color: r.isActive ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                  ),
                  PosColumn(
                    label: l.fieldActions,
                    flex: 2,
                    cellBuilder: (r) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () =>
                              _showEditDialog(context, ref, r, registers),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _delete(context, ref, r),
                        ),
                      ],
                    ),
                  ),
                ],
                items: registers,
              ),
            ),
          ],
        );
      },
    );
  }

  String _typeLabel(dynamic l, HardwareType type) {
    return switch (type) {
      HardwareType.local => l.registerTypeLocal,
      HardwareType.mobile => l.registerTypeMobile,
      HardwareType.virtual => l.registerTypeVirtual,
    };
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    RegisterModel? existing,
    List<RegisterModel> allRegisters,
  ) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var type = existing?.type ?? HardwareType.local;
    var parentRegisterId = existing?.parentRegisterId;
    var isActive = existing?.isActive ?? true;
    var allowCash = existing?.allowCash ?? true;
    var allowCard = existing?.allowCard ?? true;
    var allowTransfer = existing?.allowTransfer ?? true;
    var allowRefunds = existing?.allowRefunds ?? false;

    // For parent register dropdown, exclude self
    final parentCandidates = allRegisters
        .where((r) => r.type == HardwareType.local && r.id != existing?.id)
        .toList();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? l.actionAdd : l.actionEdit),
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
                              child: Text(_typeLabel(l, t)),
                            ))
                        .toList(),
                    onChanged: (v) => setDialogState(() {
                      type = v!;
                      if (type == HardwareType.local) {
                        parentRegisterId = null;
                      }
                    }),
                  ),
                  if (type == HardwareType.mobile &&
                      parentCandidates.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: parentRegisterId,
                      decoration:
                          InputDecoration(labelText: l.registerParent),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l.registerNone),
                        ),
                        ...parentCandidates.map((r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(r.name.isEmpty ? r.code : r.name),
                            )),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => parentRegisterId = v),
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
        parentRegisterId: type == HardwareType.mobile ? parentRegisterId : null,
        isActive: isActive,
        allowCash: allowCash,
        allowCard: allowCard,
        allowTransfer: allowTransfer,
        allowRefunds: allowRefunds,
      ));
    } else {
      await repo.create(
        companyId: company.id,
        name: nameCtrl.text.trim(),
        type: type,
        parentRegisterId:
            type == HardwareType.mobile ? parentRegisterId : null,
        allowCash: allowCash,
        allowCard: allowCard,
        allowTransfer: allowTransfer,
        allowRefunds: allowRefunds,
      );
    }
    ref.invalidate(activeRegisterProvider);
  }

  Future<void> _delete(
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
}

class _PaymentFlags extends StatelessWidget {
  const _PaymentFlags({required this.register, required this.l});
  final RegisterModel register;
  final dynamic l;

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
