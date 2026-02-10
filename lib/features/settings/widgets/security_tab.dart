import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/models/company_settings_model.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class SecurityTab extends ConsumerStatefulWidget {
  const SecurityTab({super.key});

  @override
  ConsumerState<SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends ConsumerState<SecurityTab> {
  StreamSubscription<CompanySettingsModel?>? _sub;
  CompanySettingsModel? _settings;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final repo = ref.read(companySettingsRepositoryProvider);
    // Ensure a row exists
    final settings = await repo.getOrCreate(company.id);
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _initialized = true;
    });

    // Start watching for changes
    _sub = repo.watchByCompany(company.id).listen((s) {
      if (mounted && s != null) {
        setState(() => _settings = s);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _updateSettings(CompanySettingsModel updated) async {
    final repo = ref.read(companySettingsRepositoryProvider);
    await repo.update(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (!_initialized || _settings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final settings = _settings!;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        SwitchListTile(
          title: Text(l.settingsRequirePinOnSwitch),
          value: settings.requirePinOnSwitch,
          onChanged: (value) {
            _updateSettings(settings.copyWith(requirePinOnSwitch: value));
          },
        ),
        const Divider(),
        ListTile(
          title: Text(l.settingsAutoLockTimeout),
          trailing: SizedBox(
            width: 160,
            child: DropdownButtonFormField<int?>(
              initialValue: settings.autoLockTimeoutMinutes,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l.settingsAutoLockDisabled),
                ),
                for (final minutes in [1, 2, 5, 10, 15, 30])
                  DropdownMenuItem<int?>(
                    value: minutes,
                    child: Text(l.settingsAutoLockMinutes(minutes)),
                  ),
              ],
              onChanged: (value) {
                _updateSettings(settings.copyWith(autoLockTimeoutMinutes: value));
              },
            ),
          ),
        ),
      ],
    );
  }
}
