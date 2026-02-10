import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/company_settings_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../screens/screen_cloud_auth.dart';

class CompanyTab extends ConsumerStatefulWidget {
  const CompanyTab({super.key});

  @override
  ConsumerState<CompanyTab> createState() => _CompanyTabState();
}

class _CompanyTabState extends ConsumerState<CompanyTab> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _businessIdCtrl;
  late final TextEditingController _vatNumberCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  StreamSubscription<CompanySettingsModel?>? _settingsSub;
  CompanySettingsModel? _settings;
  bool _settingsInitialized = false;
  bool _companyInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _businessIdCtrl = TextEditingController();
    _vatNumberCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _initCompany();
    _initSettings();
  }

  void _initCompany() {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;
    _nameCtrl.text = company.name;
    _businessIdCtrl.text = company.businessId ?? '';
    _vatNumberCtrl.text = company.vatNumber ?? '';
    _addressCtrl.text = company.address ?? '';
    _phoneCtrl.text = company.phone ?? '';
    _emailCtrl.text = company.email ?? '';
    _companyInitialized = true;
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
    _nameCtrl.dispose();
    _businessIdCtrl.dispose();
    _vatNumberCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _settingsSub?.cancel();
    super.dispose();
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final updated = company.copyWith(
      name: _nameCtrl.text.trim(),
      businessId: _businessIdCtrl.text.trim().isEmpty
          ? null
          : _businessIdCtrl.text.trim(),
      vatNumber: _vatNumberCtrl.text.trim().isEmpty
          ? null
          : _vatNumberCtrl.text.trim(),
      address:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
    );

    final companyRepo = ref.read(companyRepositoryProvider);
    final result = await companyRepo.update(updated);

    if (!mounted) return;

    if (result is Success<dynamic>) {
      ref.read(currentCompanyProvider.notifier).state = updated;
    }
  }

  Future<void> _updateSettings(CompanySettingsModel updated) async {
    final repo = ref.read(companySettingsRepositoryProvider);
    await repo.update(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (!_companyInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Section: Company Info ---
          _buildSectionHeader(l.settingsSectionCompanyInfo),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(labelText: l.wizardCompanyName),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l.wizardCompanyNameRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _businessIdCtrl,
                    decoration: InputDecoration(labelText: l.wizardBusinessId),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _vatNumberCtrl,
                    decoration:
                        InputDecoration(labelText: l.companyFieldVatNumber),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: InputDecoration(labelText: l.wizardAddress),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: InputDecoration(labelText: l.wizardPhone),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(labelText: l.wizardEmail),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _saveCompany,
                      child: Text(l.actionSave),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 32),

          // --- Section: Security ---
          _buildSectionHeader(l.settingsSectionSecurity),
          if (!_settingsInitialized || _settings == null)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
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

          const Divider(height: 32),

          // --- Section: Cloud ---
          _buildSectionHeader(l.settingsSectionCloud),
          const ScreenCloudAuth(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
