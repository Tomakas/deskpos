import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/company_settings_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class SecurityTab extends ConsumerStatefulWidget {
  const SecurityTab({super.key});

  @override
  ConsumerState<SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends ConsumerState<SecurityTab> {
  StreamSubscription<CompanySettingsModel?>? _settingsSub;
  CompanySettingsModel? _settings;
  bool _settingsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final repo = ref.read(companySettingsRepositoryProvider);
    final settings = await repo.getOrCreate(company.id);
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _settingsInitialized = true;
    });

    _settingsSub = repo.watchByCompany(company.id).listen((s) {
      if (mounted && s != null) {
        setState(() => _settings = s);
      }
    });
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    super.dispose();
  }

  Future<void> _updateSettings(CompanySettingsModel updated) async {
    final repo = ref.read(companySettingsRepositoryProvider);
    await repo.update(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (!_settingsInitialized || _settings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l.settingsSectionSecurity,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile(
            title: Text(l.settingsRequirePinOnSwitch),
            value: _settings!.requirePinOnSwitch,
            onChanged: (value) {
              _updateSettings(
                  _settings!.copyWith(requirePinOnSwitch: value));
            },
          ),
          ListTile(
            title: Text(l.settingsAutoLockTimeout),
            trailing: SizedBox(
              width: 160,
              child: DropdownButtonFormField<int?>(
                initialValue: _settings!.autoLockTimeoutMinutes,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  _updateSettings(
                      _settings!.copyWith(autoLockTimeoutMinutes: value));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
