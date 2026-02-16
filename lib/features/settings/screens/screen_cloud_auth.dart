import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/logging/app_logger.dart';

class ScreenCloudAuth extends ConsumerStatefulWidget {
  const ScreenCloudAuth({super.key});

  @override
  ConsumerState<ScreenCloudAuth> createState() => _ScreenCloudAuthState();
}

class _ScreenCloudAuthState extends ConsumerState<ScreenCloudAuth> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authService = ref.read(supabaseAuthServiceProvider);
    final result = await authService.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    switch (result) {
      case Success(value: final userId):
        await _saveAuthUserId(userId);
      case Failure(message: final msg):
        setState(() {
          _error = msg;
          _isLoading = false;
        });
    }
  }

  Future<void> _saveAuthUserId(String userId) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) {
      setState(() {
        _error = context.l10n.errorNoCompanyFound;
        _isLoading = false;
      });
      return;
    }

    final companyRepo = ref.read(companyRepositoryProvider);
    final updateResult = await companyRepo.updateAuthUserId(company.id, userId);

    if (!mounted) return;

    switch (updateResult) {
      case Success():
        ref.read(currentCompanyProvider.notifier).state =
            company.copyWith(authUserId: userId);
        AppLogger.info('Company authUserId updated', tag: 'SYNC');
      case Failure(message: final msg):
        _error = msg;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authService = ref.read(supabaseAuthServiceProvider);
    await authService.signOut();

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isAuthenticated = ref.watch(isSupabaseAuthenticatedProvider);

    if (isAuthenticated) {
      return _buildConnectedView(l);
    }

    return _buildAuthForm(l);
  }

  Widget _buildConnectedView(AppLocalizations l) {
    final email = Supabase.instance.client.auth.currentUser?.email;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_done, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  email != null
                      ? l.cloudConnectedAs(email)
                      : l.cloudConnected,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton.tonal(
              onPressed: _isLoading ? null : _signOut,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.cloudSignOut),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_off, color: Colors.grey, size: 28),
                const SizedBox(width: 12),
                Text(
                  l.cloudDisconnected,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: l.cloudEmail),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.trim().isEmpty) ? l.cloudEmailRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: l.cloudPassword),
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return l.cloudPasswordRequired;
                if (v.length < 6) return l.cloudPasswordLength;
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.cloudSignIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
