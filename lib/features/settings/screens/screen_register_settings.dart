import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/hardware_type.dart';
import '../../../core/data/models/device_registration_model.dart';
import '../../../core/data/models/register_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/register_tab.dart';
import '../widgets/registers_tab.dart';

class ScreenRegisterSettings extends ConsumerWidget {
  const ScreenRegisterSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.settingsRegisterTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.settingsTabRegister),
              Tab(text: l.settingsRegisters),
              Tab(text: l.registerDeviceBinding),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const RegisterTab(),
            const RegistersTab(),
            _DeviceBindingTab(),
          ],
        ),
      ),
    );
  }
}

class _DeviceBindingTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final deviceRegAsync = ref.watch(deviceRegistrationProvider);

    return deviceRegAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
      data: (deviceReg) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCurrentBinding(context, ref, deviceReg, company.id),
            const SizedBox(height: 24),
            _buildRegisterSelection(context, ref, company.id, deviceReg),
          ],
        );
      },
    );
  }

  Widget _buildCurrentBinding(
    BuildContext context,
    WidgetRef ref,
    DeviceRegistrationModel? deviceReg,
    String companyId,
  ) {
    final l = context.l10n;
    final theme = Theme.of(context);

    if (deviceReg == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.link_off, color: Colors.orange),
          title: Text(l.registerNotBound),
          subtitle: Text(l.registerSelectTitle),
        ),
      );
    }

    final registerAsync = ref.watch(activeRegisterProvider);
    final registerName = registerAsync.whenOrNull(
      data: (r) => r?.name.isNotEmpty == true ? r!.name : r?.code,
    );

    return Card(
      child: ListTile(
        leading: const Icon(Icons.link, color: Colors.green),
        title: Text(l.registerBound(registerName ?? '...')),
        trailing: TextButton(
          onPressed: () async {
            await ref
                .read(deviceRegistrationRepositoryProvider)
                .unbind(companyId);
            ref.invalidate(deviceRegistrationProvider);
            ref.invalidate(activeRegisterProvider);
            ref.invalidate(activeRegisterSessionProvider);
          },
          child: Text(
            l.registerUnbind,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterSelection(
    BuildContext context,
    WidgetRef ref,
    String companyId,
    DeviceRegistrationModel? deviceReg,
  ) {
    final l = context.l10n;

    return StreamBuilder<List<RegisterModel>>(
      stream: ref.watch(registerRepositoryProvider).watchAll(companyId),
      builder: (context, snap) {
        final registers = snap.data ?? [];
        if (registers.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.registerSelectTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...registers.map((r) {
              final isBound = deviceReg?.registerId == r.id;
              return Card(
                color: isBound
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.3)
                    : null,
                child: ListTile(
                  leading: Icon(
                    r.type == HardwareType.local
                        ? Icons.point_of_sale
                        : r.type == HardwareType.mobile
                            ? Icons.phone_android
                            : Icons.computer,
                  ),
                  title: Text(r.name.isEmpty ? r.code : r.name),
                  subtitle: Text('${_typeLabel(l, r.type)} #${r.registerNumber}'),
                  trailing: isBound
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : FilledButton(
                          onPressed: () async {
                            await ref
                                .read(deviceRegistrationRepositoryProvider)
                                .bind(
                                  companyId: companyId,
                                  registerId: r.id,
                                );
                            ref.invalidate(deviceRegistrationProvider);
                            ref.invalidate(activeRegisterProvider);
                            ref.invalidate(activeRegisterSessionProvider);
                          },
                          child: Text(l.registerBind),
                        ),
                ),
              );
            }),
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
}
