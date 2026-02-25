import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';

import '../../../core/data/models/company_currency_model.dart';
import '../../../core/data/models/company_model.dart';
import '../../../core/data/models/company_settings_model.dart';
import '../../../core/data/models/currency_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';

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
  bool _currencyLocked = false;

  // Currencies
  List<CurrencyModel> _currencies = [];

  // Alternative currencies
  StreamSubscription<List<CompanyCurrencyModel>>? _altCurrenciesSub;
  List<CompanyCurrencyModel> _altCurrencies = [];
  final Map<String, TextEditingController> _rateControllers = {};

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

    // Load currencies
    final currencyRepo = ref.read(currencyRepositoryProvider);
    final currencyResult = await currencyRepo.getAll();
    final allCurrencies = switch (currencyResult) {
      Success(value: final list) => list,
      Failure() => <CurrencyModel>[],
    };
    final unique = <String, CurrencyModel>{};
    for (final r in allCurrencies) {
      unique.putIfAbsent(r.code, () => r);
    }
    final currencies = unique.values.toList()
      ..sort((a, b) => a.code.compareTo(b.code));

    // Check if currency should be locked (any bills exist)
    final billRepo = ref.read(billRepositoryProvider);
    final bills = await billRepo.getByCompany(company.id);
    final currencyLocked = bills.isNotEmpty;

    if (!mounted) return;
    final repo = ref.read(companySettingsRepositoryProvider);
    final settings = await repo.getOrCreate(company.id);
    if (!mounted) return;
    _earnCtrl.text = settings.loyaltyEarnRate.toString();
    _pointValueCtrl.text = settings.loyaltyPointValue.toString();
    setState(() {
      _currencies = currencies;
      _currencyLocked = currencyLocked;
      _settings = settings;
      _settingsInitialized = true;
    });

    _settingsSub = repo.watchByCompany(company.id).listen((s) {
      if (mounted && s != null) {
        setState(() => _settings = s);
      }
    });

    // Watch alternative currencies
    final ccRepo = ref.read(companyCurrencyRepositoryProvider);
    _altCurrenciesSub = ccRepo.watchActive(company.id).listen((list) {
      if (!mounted) return;
      // Create/update rate controllers
      for (final cc in list) {
        if (!_rateControllers.containsKey(cc.id)) {
          _rateControllers[cc.id] = TextEditingController(text: cc.exchangeRate.toString());
        }
      }
      // Remove controllers for deleted entries
      final activeIds = list.map((cc) => cc.id).toSet();
      _rateControllers.keys.where((k) => !activeIds.contains(k)).toList().forEach((k) {
        _rateControllers[k]?.dispose();
        _rateControllers.remove(k);
      });
      setState(() => _altCurrencies = list);
    });
  }

  Future<void> _updateSettings(CompanySettingsModel updated) async {
    final repo = ref.read(companySettingsRepositoryProvider);
    await repo.update(updated);
  }

  Future<void> _updateCurrency(String currencyId) async {
    if (_currencyLocked) return;
    final company = ref.read(currentCompanyProvider);
    if (company == null || company.defaultCurrencyId == currencyId) return;

    final updated = company.copyWith(defaultCurrencyId: currencyId);
    final companyRepo = ref.read(companyRepositoryProvider);
    final result = await companyRepo.update(updated);

    if (!mounted) return;
    if (result is Success<CompanyModel>) {
      ref.read(currentCompanyProvider.notifier).state = updated;
      ref.invalidate(currentCurrencyProvider);
    }
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    _altCurrenciesSub?.cancel();
    for (final ctrl in _rateControllers.values) {
      ctrl.dispose();
    }
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

  Future<void> _addAlternativeCurrency() async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    // Filter out default currency and already-added currencies
    final usedIds = {company.defaultCurrencyId, ..._altCurrencies.map((c) => c.currencyId)};
    final available = _currencies.where((c) => !usedIds.contains(c.id)).toList();
    if (available.isEmpty) return;

    final selected = await showDialog<CurrencyModel>(
      context: context,
      builder: (ctx) {
        final l = ctx.l10n;
        return SimpleDialog(
          title: Text(l.currencySelectorTitle),
          children: [
            for (final currency in available)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, currency),
                child: Text('${currency.code} (${currency.symbol})'),
              ),
          ],
        );
      },
    );
    if (selected == null || !mounted) return;

    final ccRepo = ref.read(companyCurrencyRepositoryProvider);
    final model = CompanyCurrencyModel(
      id: const Uuid().v7(),
      companyId: company.id,
      currencyId: selected.id,
      exchangeRate: 1.0,
      sortOrder: _altCurrencies.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ccRepo.create(model);
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

    if (result is Success<CompanyModel>) {
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _businessIdCtrl,
                          decoration: InputDecoration(labelText: l.wizardBusinessId),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _vatNumberCtrl,
                          decoration: InputDecoration(labelText: l.companyFieldVatNumber),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: InputDecoration(labelText: l.wizardAddress),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneCtrl,
                          decoration: InputDecoration(labelText: l.wizardPhone),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(labelText: l.wizardEmail),
                        ),
                      ),
                    ],
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
          // Language section
          if (_settingsInitialized && _settings != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l.settingsLanguage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (final entry in [
                    ('cs', l.languageCzech),
                    ('en', l.languageEnglish),
                  ]) ...[
                    if (entry != ('cs', l.languageCzech))
                      const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilterChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(entry.$2, textAlign: TextAlign.center),
                          ),
                          selected: _settings!.locale == entry.$1,
                          onSelected: (_) {
                            _updateSettings(_settings!.copyWith(locale: entry.$1));
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          // Currency section
          if (_settingsInitialized && _currencies.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l.settingsCurrency,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Builder(builder: (context) {
                final defaultId = ref.watch(currentCompanyProvider)?.defaultCurrencyId;
                final defaultCurrencyModel = _currencies.where((c) => c.id == defaultId).firstOrNull;
                final currentCurrency = ref.watch(currentCurrencyProvider).value;

                final children = <Widget>[];

                // Default currency chip
                if (_currencyLocked) {
                  children.add(FilterChip(
                    label: Text(defaultCurrencyModel != null
                        ? '${defaultCurrencyModel.code} (${defaultCurrencyModel.symbol})'
                        : '-'),
                    selected: true,
                    onSelected: null,
                  ));
                } else {
                  for (final (i, currency) in _currencies.indexed) {
                    if (i > 0) children.add(const SizedBox(width: 8));
                    children.add(FilterChip(
                      label: Text('${currency.code} (${currency.symbol})'),
                      selected: defaultId == currency.id,
                      onSelected: (_) => _updateCurrency(currency.id),
                    ));
                  }
                }

                // Alternative currencies inline
                for (final cc in _altCurrencies) {
                  final currency = _currencies.where((c) => c.id == cc.currencyId).firstOrNull;
                  if (currency == null) continue;
                  children.addAll([
                    const SizedBox(width: 12),
                    Text(currency.code, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _rateControllers[cc.id],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          suffixText: currentCurrency?.code ?? '',
                          isDense: true,
                        ),
                        onChanged: (v) {
                          final rate = double.tryParse(v);
                          if (rate != null && rate > 0) {
                            final ccRepo = ref.read(companyCurrencyRepositoryProvider);
                            ccRepo.update(cc.copyWith(
                              exchangeRate: rate,
                              updatedAt: DateTime.now(),
                            ));
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        final ccRepo = ref.read(companyCurrencyRepositoryProvider);
                        ccRepo.delete(cc.id);
                      },
                      iconSize: 18,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ]);
                }

                // Add currency button
                children.addAll([
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _addAlternativeCurrency,
                    tooltip: l.settingsAddCurrency,
                  ),
                ]);

                return Row(children: children);
              }),
            ),
            if (_currencyLocked)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  l.settingsCurrencyLocked,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _earnCtrl,
                          decoration: InputDecoration(labelText: l.loyaltyEarnRate(ref.money(parseMoney('100', ref.watch(currentCurrencyProvider).value)))),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final value = int.tryParse(v) ?? 0;
                            _updateSettings(_settings!.copyWith(loyaltyEarnRate: value));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _pointValueCtrl,
                          decoration: InputDecoration(labelText: l.loyaltyPointValue),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final value = int.tryParse(v) ?? 0;
                            _updateSettings(_settings!.copyWith(loyaltyPointValue: value));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _settings!.loyaltyEarnRate > 0 || _settings!.loyaltyPointValue > 0
                        ? l.loyaltyDescription(
                            _settings!.loyaltyEarnRate,
                            ref.money(parseMoney('100', ref.watch(currentCurrencyProvider).value)),
                            ref.money(_settings!.loyaltyPointValue),
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
