import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';

enum _Step { credentials, searching, companyPreview, syncing, done }

class ScreenConnectCompany extends ConsumerStatefulWidget {
  const ScreenConnectCompany({super.key});

  @override
  ConsumerState<ScreenConnectCompany> createState() => _ScreenConnectCompanyState();
}

class _ScreenConnectCompanyState extends ConsumerState<ScreenConnectCompany> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _Step _step = _Step.credentials;
  String? _error;
  String? _companyName;
  String? _companyId;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _step = _Step.searching;
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
        await _fetchCompany(userId);
      case Failure(message: final msg):
        setState(() {
          _step = _Step.credentials;
          _error = msg;
        });
    }
  }

  Future<void> _fetchCompany(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final rows = await supabase
          .from('companies')
          .select('id, name')
          .eq('auth_user_id', userId)
          .limit(1) as List<dynamic>;

      if (!mounted) return;

      if (rows.isEmpty) {
        setState(() {
          _step = _Step.credentials;
          _error = context.l10n.connectCompanyNotFound;
        });
        return;
      }

      final company = rows.first as Map<String, dynamic>;
      setState(() {
        _companyId = company['id'] as String;
        _companyName = company['name'] as String;
        _step = _Step.companyPreview;
      });
    } catch (e, s) {
      AppLogger.error('Failed to fetch company', error: e, stackTrace: s);
      if (!mounted) return;
      setState(() {
        _step = _Step.credentials;
        _error = e.toString();
      });
    }
  }

  Future<void> _connect() async {
    if (_companyId == null) return;
    setState(() {
      _step = _Step.syncing;
      _error = null;
    });

    try {
      // Pull all data from Supabase
      final syncService = ref.read(syncServiceProvider);
      await syncService.pullAll(_companyId!);

      if (!mounted) return;

      // Insert a completed marker so SyncLifecycleManager._initialPush() skips
      // (it checks hasCompletedEntries)
      final syncQueueRepo = ref.read(syncQueueRepositoryProvider);
      await syncQueueRepo.enqueue(
        companyId: _companyId!,
        entityType: '_initial_sync_marker',
        entityId: _companyId!,
        operation: 'insert',
        payload: '{}',
      );
      // Get the just-inserted marker and mark it completed
      final pending = await syncQueueRepo.getPending(limit: 50);
      for (final entry in pending) {
        if (entry.entityType == '_initial_sync_marker') {
          await syncQueueRepo.markCompleted(entry.id);
          break;
        }
      }

      if (!mounted) return;

      setState(() => _step = _Step.done);

      // Navigate to login — appInitProvider will see the company in local DB
      ref.invalidate(appInitProvider);
      await ref.read(appInitProvider.future);
      if (mounted) context.go('/login');
    } catch (e, s) {
      AppLogger.error('Initial sync failed', error: e, stackTrace: s);
      if (!mounted) return;
      setState(() {
        _step = _Step.companyPreview;
        _error = context.l10n.connectCompanySyncFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.connectCompanyTitle, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(l.connectCompanySubtitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),
                if (_step == _Step.credentials || _step == _Step.companyPreview) ...[
                  _buildForm(l),
                ],
                if (_step == _Step.searching) ...[
                  _buildLoading(l.connectCompanySearching),
                ],
                if (_step == _Step.companyPreview) ...[
                  const SizedBox(height: 24),
                  _buildCompanyPreview(l),
                ],
                if (_step == _Step.syncing) ...[
                  _buildLoading(l.connectCompanySyncing),
                ],
                if (_step == _Step.done) ...[
                  _buildLoading(l.connectCompanySyncComplete),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(dynamic l) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l.cloudEmail),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || v.trim().isEmpty) ? l.cloudEmailRequired : null,
            enabled: _step == _Step.credentials,
            textInputAction: TextInputAction.next,
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
            enabled: _step == _Step.credentials,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_step == _Step.credentials) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _signIn,
                child: Text(l.cloudSignIn),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.go('/onboarding'),
                child: Text(l.wizardBack),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoading(String message) {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(message),
      ],
    );
  }

  Widget _buildCompanyPreview(dynamic l) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.connectCompanyFound, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Text(_companyName ?? '', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _connect,
                child: Text(l.connectCompanyConnect),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
