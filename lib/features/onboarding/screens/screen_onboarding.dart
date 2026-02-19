import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/pin_helper.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/logging/app_logger.dart';

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
                // --- Pokladna ---
                Text(l.onboardingSectionPos,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 16),
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
                // --- Displeje ---
                Text(l.onboardingSectionDisplays,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.go('/display-code?type=customer_display'),
                    child: Text(l.onboardingCustomerDisplay),
                  ),
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
      adminFullName: _fullNameCtrl.text.trim(),
      adminUsername: _usernameCtrl.text.trim(),
      adminPin: _pinCtrl.text,
      withTestData: _withTestData,
      deviceId: myDeviceId,
      locale: _selectedLocale,
      defaultCurrencyCode: _selectedCurrencyCode,
      authUserId: _authUserId!,
    );

    if (!mounted) return;

    switch (result) {
      case Success():
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
}
