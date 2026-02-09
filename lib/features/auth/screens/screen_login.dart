import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class ScreenLogin extends ConsumerStatefulWidget {
  const ScreenLogin({super.key});

  @override
  ConsumerState<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends ConsumerState<ScreenLogin> {
  final _pinCtrl = TextEditingController();
  String? _error;
  int? _lockSeconds;
  Timer? _lockTimer;
  UserModel? _selectedUser;
  List<UserModel> _users = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final companyRepo = ref.read(companyRepositoryProvider);
    final userRepo = ref.read(userRepositoryProvider);

    final companyResult = await companyRepo.getFirst();
    if (companyResult is! Success) return;
    final company = (companyResult as Success).value;
    if (company == null) return;

    final users = await userRepo.getActiveUsers(company.id);
    if (!mounted) return;
    setState(() {
      _users = users;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _lockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: _selectedUser != null
              ? _buildPinEntry(l)
              : _buildUserList(l),
        ),
      ),
    );
  }

  Widget _buildUserList(dynamic l) {
    if (!_loaded) {
      return const CircularProgressIndicator();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l.loginTitle, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 32),
        ..._users.map((user) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _selectedUser = user;
                    _error = null;
                    _pinCtrl.clear();
                  }),
                  child: Text(user.fullName),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildPinEntry(dynamic l) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _selectedUser!.fullName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _pinCtrl,
          decoration: InputDecoration(
            labelText: l.loginPinLabel,
            errorText: _lockSeconds != null
                ? l.loginLockedOut(_lockSeconds!)
                : _error,
          ),
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          enabled: _lockSeconds == null,
          onSubmitted: (_) => _login(),
          autofocus: true,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _selectedUser = null;
                    _error = null;
                    _pinCtrl.clear();
                  }),
                  child: Text(l.wizardBack),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _lockSeconds != null ? null : _login,
                  child: Text(l.loginButton),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _login() async {
    final pin = _pinCtrl.text;
    if (pin.isEmpty || _selectedUser == null) return;

    final authService = ref.read(authServiceProvider);
    final session = ref.read(sessionManagerProvider);

    final result = authService.authenticate(pin, _selectedUser!.pinHash);
    switch (result) {
      case AuthSuccess():
        session.login(_selectedUser!);
        ref.read(activeUserProvider.notifier).state = _selectedUser;
        ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;
        // Load company into provider
        final companyRepo = ref.read(companyRepositoryProvider);
        final companyResult = await companyRepo.getFirst();
        if (companyResult case Success(value: final company?)) {
          ref.read(currentCompanyProvider.notifier).state = company;
        }
        if (mounted) context.go('/bills');
      case AuthLocked(remainingSeconds: final secs):
        _startLockTimer(secs);
      case AuthFailure(message: final msg):
        setState(() {
          _error = msg;
          _pinCtrl.clear();
        });
    }
  }

  void _startLockTimer(int seconds) {
    _lockTimer?.cancel();
    setState(() {
      _lockSeconds = seconds;
      _error = null;
      _pinCtrl.clear();
    });
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _lockSeconds = _lockSeconds! - 1;
        if (_lockSeconds! <= 0) {
          _lockSeconds = null;
          timer.cancel();
        }
      });
    });
  }
}
