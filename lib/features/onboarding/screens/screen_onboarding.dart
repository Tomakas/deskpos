import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/pin_helper.dart';
import '../../../core/data/enums/business_type.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/database_provider.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/widgets/business_type_selector.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../l10n/app_localizations.dart';

class ScreenOnboarding extends ConsumerStatefulWidget {
  const ScreenOnboarding({super.key});

  @override
  ConsumerState<ScreenOnboarding> createState() => _ScreenOnboardingState();
}

class _ScreenOnboardingState extends ConsumerState<ScreenOnboarding> {
  bool _showWizard = false;
  int _step = 0;
  bool _isSubmitting = false;
  bool _withTestData = false;
  String _selectedLocale = 'cs';
  String _selectedCurrencyCode = 'CZK';
  String _selectedMode = 'gastro';
  BusinessCategory? _selectedBusinessCategory;
  BusinessType? _selectedBusinessType;

  // Step 0: Supabase account
  final _authEmailCtrl = TextEditingController();
  final _authPasswordCtrl = TextEditingController();
  final _authPasswordConfirmCtrl = TextEditingController();
  bool _isSignInMode = false;
  String? _authError;
  String? _authUserId;

  // Step 1: Company
  final _companyNameCtrl = TextEditingController();
  final _businessIdCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Step 2: Admin
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _pinConfirmCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _authEmailCtrl.dispose();
    _authPasswordCtrl.dispose();
    _authPasswordConfirmCtrl.dispose();
    _companyNameCtrl.dispose();
    _businessIdCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _pinCtrl.dispose();
    _pinConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (!_showWizard) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilterChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(l.languageCzech, textAlign: TextAlign.center),
                          ),
                          selected: _selectedLocale == 'cs',
                          onSelected: (_) => _setLocale('cs'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilterChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(l.languageEnglish, textAlign: TextAlign.center),
                          ),
                          selected: _selectedLocale == 'en',
                          onSelected: (_) => _setLocale('en'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(l.onboardingTitle, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => setState(() => _showWizard = true),
                    child: Text(l.onboardingCreateCompany),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.go('/connect-company'),
                    child: Text(l.onboardingJoinCompany),
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.go('/display-code?type=customer_display'),
                    child: Text(l.onboardingCustomerDisplay),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.onboardingCustomerDisplaySubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.tonal(
                    onPressed: _showDemoDialog,
                    child: Text(l.onboardingCreateDemo),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.onboardingCreateDemoSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _step == 0
                        ? l.wizardStepAccount
                        : _step == 1
                            ? l.wizardStepCompany
                            : l.wizardStepAdmin,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 32),
                  if (_step == 0) ..._buildAccountStep(l),
                  if (_step == 1) ..._buildCompanyStep(l),
                  if (_step == 2) ..._buildAdminStep(l),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() {
                          if (_step > 0) {
                            _step--;
                          } else {
                            _showWizard = false;
                          }
                        }),
                        child: Text(l.wizardBack),
                      ),
                      const Spacer(),
                      if (_step == 0)
                        FilledButton(
                          onPressed: _isSubmitting ? null : _submitAccount,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isSignInMode
                                  ? l.wizardAccountSignIn
                                  : l.wizardAccountSignUp),
                        ),
                      if (_step == 1)
                        FilledButton(
                          onPressed: _nextStep,
                          child: Text(l.wizardNext),
                        ),
                      if (_step == 2)
                        FilledButton(
                          onPressed: _isSubmitting ? null : _finish,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l.wizardFinish),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAccountStep(AppLocalizations l) {
    return [
      TextFormField(
        controller: _authEmailCtrl,
        decoration: InputDecoration(labelText: l.wizardAccountEmail),
        keyboardType: TextInputType.emailAddress,
        validator: (v) => (v == null || v.trim().isEmpty) ? l.cloudEmailRequired : null,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _authPasswordCtrl,
        decoration: InputDecoration(labelText: l.wizardAccountPassword),
        obscureText: true,
        validator: (v) {
          if (v == null || v.isEmpty) return l.cloudPasswordRequired;
          if (v.length < 6) return l.cloudPasswordLength;
          return null;
        },
        textInputAction: TextInputAction.next,
      ),
      if (!_isSignInMode) ...[
        const SizedBox(height: 16),
        TextFormField(
          controller: _authPasswordConfirmCtrl,
          decoration: InputDecoration(labelText: l.wizardAccountPasswordConfirm),
          obscureText: true,
          validator: (v) {
            if (v != _authPasswordCtrl.text) return l.wizardAccountPasswordMismatch;
            return null;
          },
        ),
      ],
      if (_authError != null) ...[
        const SizedBox(height: 16),
        Text(
          _authError!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ],
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () => setState(() {
            _isSignInMode = !_isSignInMode;
            _authError = null;
          }),
          child: Text(_isSignInMode
              ? l.wizardAccountSwitchToSignUp
              : l.wizardAccountSwitchToSignIn),
        ),
      ),
    ];
  }

  List<Widget> _buildCompanyStep(AppLocalizations l) {
    return [
      TextFormField(
        controller: _companyNameCtrl,
        decoration: InputDecoration(labelText: l.wizardCompanyName),
        validator: (v) => (v == null || v.trim().isEmpty) ? l.wizardCompanyNameRequired : null,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _businessIdCtrl,
        decoration: InputDecoration(labelText: l.wizardBusinessId),
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _addressCtrl,
        decoration: InputDecoration(labelText: l.wizardAddress),
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailCtrl,
        decoration: InputDecoration(labelText: l.wizardEmail),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _phoneCtrl,
        decoration: InputDecoration(labelText: l.wizardPhone),
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 24),
      BusinessTypeSelector(
        selectedCategory: _selectedBusinessCategory,
        selectedType: _selectedBusinessType,
        onCategoryChanged: (cat) {
          setState(() {
            _selectedBusinessCategory = cat;
            final subtypes = businessTypesByCategory[cat] ?? [];
            if (subtypes.length == 1) {
              _selectedBusinessType = subtypes.first;
            } else {
              _selectedBusinessType = null;
            }
          });
        },
        onTypeChanged: (type) => setState(() => _selectedBusinessType = type),
      ),
      const SizedBox(height: 24),
      Text(l.wizardCurrency, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Row(
        children: [
          for (final entry in _currencyOptions.entries) ...[
            if (entry.key != _currencyOptions.keys.first) const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilterChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(entry.value, textAlign: TextAlign.center),
                  ),
                  selected: _selectedCurrencyCode == entry.key,
                  onSelected: (_) => setState(() => _selectedCurrencyCode = entry.key),
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 16),
      CheckboxListTile(
        value: _withTestData,
        onChanged: (v) => setState(() => _withTestData = v ?? false),
        title: Text(l.wizardWithTestData),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
      if (_withTestData) ...[
        const SizedBox(height: 8),
        Text(l.wizardDemoMode, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilterChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(l.sellModeGastro, textAlign: TextAlign.center),
                  ),
                  selected: _selectedMode == 'gastro',
                  onSelected: (_) => setState(() => _selectedMode = 'gastro'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilterChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(l.sellModeRetail, textAlign: TextAlign.center),
                  ),
                  selected: _selectedMode == 'retail',
                  onSelected: (_) => setState(() => _selectedMode = 'retail'),
                ),
              ),
            ),
          ],
        ),
      ],
    ];
  }

  List<Widget> _buildAdminStep(AppLocalizations l) {
    return [
      TextFormField(
        controller: _fullNameCtrl,
        decoration: InputDecoration(labelText: l.wizardFullName),
        validator: (v) => (v == null || v.trim().isEmpty) ? l.wizardFullNameRequired : null,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _usernameCtrl,
        decoration: InputDecoration(labelText: l.wizardUsername),
        validator: (v) => (v == null || v.trim().isEmpty) ? l.wizardUsernameRequired : null,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _pinCtrl,
        decoration: InputDecoration(labelText: l.wizardPin),
        obscureText: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
        validator: (v) {
          if (v == null || v.isEmpty) return l.wizardPinRequired;
          if (!PinHelper.isValidPin(v)) return l.wizardPinLength;
          return null;
        },
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _pinConfirmCtrl,
        decoration: InputDecoration(labelText: l.wizardPinConfirm),
        obscureText: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
        validator: (v) {
          if (v != _pinCtrl.text) return l.wizardPinMismatch;
          return null;
        },
      ),
    ];
  }

  static const _currencyOptions = {
    'CZK': 'CZK (Kč)',
    'EUR': 'EUR (€)',
    'USD': 'USD (\$)',
    'PLN': 'PLN (zł)',
    'HUF': 'HUF (Ft)',
  };

  void _setLocale(String locale) {
    setState(() => _selectedLocale = locale);
    ref.read(pendingLocaleProvider.notifier).state = locale;
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() => _step++);
    }
  }

  Future<void> _submitAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _authError = null;
    });

    final authService = ref.read(supabaseAuthServiceProvider);

    // Clear any stale Supabase session from a previous installation/company
    if (authService.isAuthenticated) {
      await authService.signOut();
      if (!mounted) return;
    }

    final Result<String> result;
    if (_isSignInMode) {
      result = await authService.signIn(
        _authEmailCtrl.text.trim(),
        _authPasswordCtrl.text,
      );
    } else {
      result = await authService.signUp(
        _authEmailCtrl.text.trim(),
        _authPasswordCtrl.text,
      );
    }

    if (!mounted) return;

    switch (result) {
      case Success(value: final userId):
        setState(() {
          _authUserId = userId;
          _isSubmitting = false;
          _step = 1;
        });
      case Failure(message: final msg):
        setState(() {
          _authError = msg;
          _isSubmitting = false;
        });
    }
  }

  Future<void> _finish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_authUserId == null) {
      AppLogger.error('Onboarding _finish called with null authUserId');
      setState(() {
        _isSubmitting = false;
        _step = 0;
      });
      return;
    }
    setState(() => _isSubmitting = true);

    // Pull server-owned global tables before seeding local data.
    // User must have internet (they just authenticated with Supabase).
    final syncService = ref.read(syncServiceProvider);
    const globalTables = ['currencies', 'roles', 'permissions', 'role_permissions'];
    try {
      for (final table in globalTables) {
        await syncService.pullTable('_global', table);
      }
    } catch (e, s) {
      AppLogger.error('Failed to pull global tables', error: e, stackTrace: s);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      return;
    }
    if (!mounted) return;

    final seedService = ref.read(seedServiceProvider);
    final deviceIdFuture = ref.read(deviceIdProvider.future);

    final myDeviceId = await deviceIdFuture;
    if (!mounted) return;
    final result = await seedService.seedOnboarding(
      companyName: _companyNameCtrl.text.trim(),
      businessId: _businessIdCtrl.text.trim().isEmpty ? null : _businessIdCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      businessType: _selectedBusinessType,
      adminFullName: _fullNameCtrl.text.trim(),
      adminUsername: _usernameCtrl.text.trim(),
      adminPin: _pinCtrl.text,
      deviceId: myDeviceId,
      locale: _selectedLocale,
      defaultCurrencyCode: _selectedCurrencyCode,
      authUserId: _authUserId!,
    );

    if (!mounted) return;

    switch (result) {
      case Success(value: final companyId):
        // Seed static demo data if "with test data" was checked
        if (_withTestData) {
          // Find the default tax rate for this company
          final db = ref.read(appDatabaseProvider);
          final defaultTaxRate = await (db.select(db.taxRates)
                ..where((t) => t.companyId.equals(companyId) & t.isDefault.equals(true)))
              .getSingleOrNull();

          if (defaultTaxRate != null && mounted) {
            await seedService.seedStaticDemoData(
              companyId: companyId,
              locale: _selectedLocale,
              mode: _selectedMode,
              defaultTaxRateId: defaultTaxRate.id,
            );
          }
        }

        if (!mounted) return;
        // Clear pre-company locale override — company settings now own the locale
        ref.read(pendingLocaleProvider.notifier).state = null;
        ref.invalidate(appInitProvider);
        // Wait for provider to re-resolve before navigating
        await ref.read(appInitProvider.future);
        if (mounted) context.go('/login');
      case Failure(message: final msg):
        AppLogger.error('Onboarding failed: $msg');
        setState(() => _isSubmitting = false);
    }
  }

  // --- Demo flow (anonymous auth) ---

  void _showDemoDialog() {
    var demoMode = 'gastro';
    String? demoError;
    String? demoProgress; // null = mode selection, non-null = progress phase

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final l = dialogContext.l10n;

          // Error state — show error + close button
          if (demoError != null) {
            return AlertDialog(
              title: Text(l.demoDialogTitle),
              content: SelectableText(demoError!),
              actions: [
                PosDialogActions(
                  actions: [
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(l.actionClose),
                    ),
                  ],
                ),
              ],
            );
          }

          // Progress state — show spinner + status + info
          if (demoProgress != null) {
            final bodySmall = Theme.of(dialogContext).textTheme.bodySmall;
            return PopScope(
              canPop: false,
              child: AlertDialog(
                title: Text(l.demoDialogTitle),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 24),
                        Expanded(child: Text(demoProgress!)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(l.wizardDemoUsers, style: bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      '${l.roleAdmin} · ${l.roleManager} · ${l.roleOperator} · ${l.roleHelper}',
                      style: Theme.of(dialogContext).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(l.wizardDemoInfo, style: bodySmall),
                    const SizedBox(height: 12),
                    Text(l.wizardDemoHistory, style: bodySmall),
                    const SizedBox(height: 4),
                    Text(l.demoDialogInfo, style: bodySmall),
                  ],
                ),
              ),
            );
          }

          // Mode selection state
          return AlertDialog(
            title: Text(l.demoDialogTitle),
            content: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 320),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilterChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(l.sellModeGastro, textAlign: TextAlign.center),
                          ),
                          selected: demoMode == 'gastro',
                          onSelected: (_) => setDialogState(() => demoMode = 'gastro'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilterChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(l.sellModeRetail, textAlign: TextAlign.center),
                          ),
                          selected: demoMode == 'retail',
                          onSelected: (_) => setDialogState(() => demoMode = 'retail'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
            actions: [
              PosDialogActions(
                actions: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l.wizardBack),
                  ),
                  FilledButton(
                    onPressed: () async {
                      setDialogState(() => demoProgress = l.wizardDemoCreating);
                      await _executeDemoCreation(
                        mode: demoMode,
                        onProgress: (msg) {
                          if (dialogContext.mounted) {
                            setDialogState(() => demoProgress = msg);
                          }
                        },
                        onError: (msg) {
                          if (dialogContext.mounted) {
                            setDialogState(() {
                              demoError = msg;
                              demoProgress = null;
                            });
                          }
                        },
                      );
                    },
                    child: Text(l.demoDialogCreate),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _executeDemoCreation({
    required String mode,
    required void Function(String) onProgress,
    required void Function(String) onError,
  }) async {
    final l = context.l10n;
    final currencyCode = _selectedLocale == 'cs' ? 'CZK' : 'EUR';
    final companyName = mode == 'gastro'
        ? 'Demo Gastro'
        : (_selectedLocale == 'cs' ? 'Demo Maloobchod' : 'Demo Retail');

    try {
      // 1. Anonymous sign-in
      final authService = ref.read(supabaseAuthServiceProvider);

      // Clear any stale session
      if (authService.isAuthenticated) {
        await authService.signOut();
        if (!mounted) return;
      }

      final authResult = await authService.signInAnonymously();
      if (!mounted) return;

      switch (authResult) {
        case Failure(message: final msg):
          onError(msg);
          return;
        case Success():
          break;
      }

      // 2. Pull global tables
      final syncService = ref.read(syncServiceProvider);
      const globalTables = ['currencies', 'roles', 'permissions', 'role_permissions'];
      for (final table in globalTables) {
        await syncService.pullTable('_global', table);
      }
      if (!mounted) return;

      // 3. Call edge function to create demo company server-side
      onProgress(l.wizardDemoCreating);
      final supabase = Supabase.instance.client;
      final response = await supabase.functions.invoke(
        'create-demo-data',
        body: {
          'locale': _selectedLocale,
          'mode': mode,
          'currency_code': currencyCode,
          'company_name': companyName,
        },
      );

      if (!mounted) return;

      final raw = response.data;
      final Map<String, dynamic> result;
      if (raw is Map<String, dynamic>) {
        result = raw;
      } else if (raw is String) {
        result = jsonDecode(raw) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response type: ${raw.runtimeType}');
      }

      if (result['ok'] != true) {
        throw Exception(result['message'] ?? 'Demo data creation failed');
      }

      final companyId = result['company_id'] as String?;
      final registerId = result['register_id'] as String?;
      if (companyId == null || registerId == null) {
        throw Exception('Missing company_id or register_id in response');
      }

      // 4. Pull all company data from server
      onProgress(l.wizardDemoDownloading);
      await syncService.pullAll(companyId);
      if (!mounted) return;

      // 5. Create device_registration locally (local-only table)
      final db = ref.read(appDatabaseProvider);
      await db.into(db.deviceRegistrations).insert(
        DeviceRegistrationsCompanion.insert(
          id: const Uuid().v7(),
          companyId: companyId,
          registerId: registerId,
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;

      // 6. Insert completed sync_queue marker (prevents _initialPush
      //    from re-pushing all pulled demo data back to server)
      await db.into(db.syncQueue).insert(
        SyncQueueCompanion.insert(
          id: const Uuid().v7(),
          companyId: companyId,
          entityType: '_marker',
          entityId: 'demo_onboarding',
          operation: 'create',
          payload: '{}',
          idempotencyKey: 'demo_marker_${DateTime.now().millisecondsSinceEpoch}',
        ).copyWith(
          status: const Value('completed'),
          processedAt: Value(DateTime.now()),
        ),
      );

      if (!mounted) return;

      // Close the dialog
      Navigator.of(context).pop();

      // Clear pre-company locale override — company settings now own the locale
      ref.read(pendingLocaleProvider.notifier).state = null;
      ref.invalidate(appInitProvider);
      await ref.read(appInitProvider.future);
      if (mounted) context.go('/login');
    } catch (e, s) {
      AppLogger.error('Demo onboarding failed', error: e, stackTrace: s);
      if (!mounted) return;
      onError('$e\n\n$s');
    }
  }
}
