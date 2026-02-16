import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/enums/hardware_type.dart';
import '../../../core/data/models/register_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/logging/app_logger.dart';

enum _Step { credentials, searching, companyPreview, syncing, selectRegister, done }

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
  List<RegisterModel> _registers = [];

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
      final companyRepo = ref.read(companyRepositoryProvider);
      final result = await companyRepo.findRemoteByAuthUserId(userId);

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _step = _Step.credentials;
          _error = context.l10n.connectCompanyNotFound;
        });
        return;
      }

      setState(() {
        _companyId = result.id;
        _companyName = result.name;
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

      // KDS devices don't need register binding — skip selection
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString('display_type') == 'kds') {
        _finalize();
        return;
      }

      // Load ALL registers for selection — never auto-bind, never skip
      final registerRepo = ref.read(registerRepositoryProvider);
      final allRegisters = await registerRepo.getAll(_companyId!);

      if (!mounted) return;

      // Always show register selection (user explicitly picks or creates)
      setState(() {
        _registers = allRegisters;
        _step = _Step.selectRegister;
      });
    } catch (e, s) {
      AppLogger.error('Initial sync failed', error: e, stackTrace: s);
      if (!mounted) return;
      setState(() {
        _step = _Step.companyPreview;
        _error = context.l10n.connectCompanySyncFailed;
      });
    }
  }

  Future<void> _selectRegister(RegisterModel register) async {
    final myDeviceId = await ref.read(deviceIdProvider.future);
    await ref.read(deviceRegistrationRepositoryProvider).bind(
      companyId: _companyId!,
      registerId: register.id,
      deviceId: myDeviceId,
    );
    if (!mounted) return;
    _finalize();
  }

  Future<void> _createAndSelectRegister() async {
    final registerRepo = ref.read(registerRepositoryProvider);
    final result = await registerRepo.create(
      companyId: _companyId!,
      name: '',
      type: HardwareType.local,
    );

    if (!mounted) return;

    if (result case Success(value: final newRegister)) {
      await _selectRegister(newRegister);
    }
  }

  void _finalize() {
    setState(() => _step = _Step.done);

    // Navigate to login — appInitProvider will see the company in local DB
    ref.invalidate(appInitProvider);
    ref.invalidate(deviceRegistrationProvider);
    ref.invalidate(activeRegisterProvider);
    ref.read(appInitProvider.future).then((_) {
      if (mounted) context.go('/login');
    });
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
                if (_step == _Step.selectRegister) ...[
                  _buildRegisterSelection(l),
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

  Widget _buildForm(AppLocalizations l) {
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

  Widget _buildCompanyPreview(AppLocalizations l) {
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

  Widget _buildRegisterSelection(AppLocalizations l) {
    final theme = Theme.of(context);

    return FutureBuilder<String>(
      future: ref.read(deviceIdProvider.future),
      builder: (context, snap) {
        final myDeviceId = snap.data;
        if (myDeviceId == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final unbound = _registers
            .where((r) =>
                r.boundDeviceId == null || r.boundDeviceId == myDeviceId)
            .toList();
        final boundElsewhere = _registers
            .where((r) =>
                r.boundDeviceId != null && r.boundDeviceId != myDeviceId)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.connectCompanySelectRegister,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l.connectCompanySelectRegisterSubtitle,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Selectable registers (unbound or bound to this device)
            for (final register in unbound) ...[
              Card(
                child: ListTile(
                  leading: Icon(
                    register.type == HardwareType.local
                        ? Icons.point_of_sale
                        : register.type == HardwareType.mobile
                            ? Icons.phone_android
                            : Icons.computer,
                  ),
                  title: Text(
                      register.name.isEmpty ? register.code : register.name),
                  subtitle: Text('#${register.registerNumber}'),
                  trailing: register.isMain
                      ? Icon(Icons.star, color: Colors.amber.shade700)
                      : null,
                  onTap: () => _selectRegister(register),
                ),
              ),
              const SizedBox(height: 4),
            ],
            // Non-selectable registers (bound to other devices)
            for (final register in boundElsewhere) ...[
              Opacity(
                opacity: 0.5,
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      register.type == HardwareType.local
                          ? Icons.point_of_sale
                          : register.type == HardwareType.mobile
                              ? Icons.phone_android
                              : Icons.computer,
                    ),
                    title: Text(
                        register.name.isEmpty ? register.code : register.name),
                    subtitle: Text(l.registerBoundOnOtherDevice),
                    trailing:
                        Icon(Icons.lock, size: 18, color: Colors.orange.shade700),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            // Create new register option
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: Text(l.connectCompanyCreateRegister),
                onTap: _createAndSelectRegister,
              ),
            ),
          ],
        );
      },
    );
  }
}
