import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/pin_helper.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
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
                            child: Text('Čeština', textAlign: TextAlign.center),
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
                            child: Text('English', textAlign: TextAlign.center),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.go('/display-code?type=kds'),
                    child: Text(l.onboardingKdsDisplay),
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
                    _step == 0 ? l.wizardStepCompany : l.wizardStepAdmin,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 32),
                  if (_step == 0) ..._buildCompanyStep(l),
                  if (_step == 1) ..._buildAdminStep(l),
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
                          onPressed: _nextStep,
                          child: Text(l.wizardNext),
                        ),
                      if (_step == 1)
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

  List<Widget> _buildCompanyStep(dynamic l) {
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

  List<Widget> _buildAdminStep(dynamic l) {
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

  Future<void> _finish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    // Clear any stale Supabase session from a previous installation/company
    final authService = ref.read(supabaseAuthServiceProvider);
    if (authService.isAuthenticated) {
      await authService.signOut();
    }

    final seedService = ref.read(seedServiceProvider);
    final myDeviceId = await ref.read(deviceIdProvider.future);
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
