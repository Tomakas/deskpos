import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/company_settings_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class CompanyInfoTab extends ConsumerStatefulWidget {
  const CompanyInfoTab({super.key});

  @override
  ConsumerState<CompanyInfoTab> createState() => _CompanyInfoTabState();
}

class _CompanyInfoTabState extends ConsumerState<CompanyInfoTab> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _businessIdCtrl;
  late final TextEditingController _vatNumberCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  bool _companyInitialized = false;

  // Loyalty settings
  StreamSubscription<CompanySettingsModel?>? _settingsSub;
  CompanySettingsModel? _settings;
  bool _settingsInitialized = false;
  late final TextEditingController _earnCtrl;
  late final TextEditingController _pointValueCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _businessIdCtrl = TextEditingController();
    _vatNumberCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _earnCtrl = TextEditingController();
    _pointValueCtrl = TextEditingController();
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
    _earnCtrl.text = settings.loyaltyEarnPerHundredCzk.toString();
    _pointValueCtrl.text = settings.loyaltyPointValueHalere.toString();
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

  Future<void> _updateSettings(CompanySettingsModel updated) async {
    final repo = ref.read(companySettingsRepositoryProvider);
    await repo.update(updated);
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    _nameCtrl.dispose();
    _businessIdCtrl.dispose();
    _vatNumberCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _earnCtrl.dispose();
    _pointValueCtrl.dispose();
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l.settingsSectionCompanyInfo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
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
          const SizedBox(height: 24),
          // Loyalty section
          if (_settingsInitialized && _settings != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l.loyaltySectionTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _earnCtrl,
                    decoration: InputDecoration(labelText: l.loyaltyEarnPerHundredCzk),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final value = int.tryParse(v) ?? 0;
                      _updateSettings(_settings!.copyWith(loyaltyEarnPerHundredCzk: value));
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pointValueCtrl,
                    decoration: InputDecoration(labelText: l.loyaltyPointValueHalere),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final value = int.tryParse(v) ?? 0;
                      _updateSettings(_settings!.copyWith(loyaltyPointValueHalere: value));
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _settings!.loyaltyEarnPerHundredCzk > 0 || _settings!.loyaltyPointValueHalere > 0
                        ? l.loyaltyDescription(
                            _settings!.loyaltyEarnPerHundredCzk,
                            (_settings!.loyaltyPointValueHalere / 100).toStringAsFixed(2).replaceAll('.', ','),
                          )
                        : l.loyaltyDisabled,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
