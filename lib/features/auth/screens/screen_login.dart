import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/auth/pin_helper.dart';
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

  void _numpadTap(String digit) {
    if (_pinCtrl.text.length >= 6 || _lockSeconds != null) return;
    setState(() {
      _pinCtrl.text += digit;
      _error = null;
    });
    _onPinChanged();
  }

  void _numpadBackspace() {
    if (_pinCtrl.text.isEmpty) return;
    setState(() {
      _pinCtrl.text = _pinCtrl.text.substring(0, _pinCtrl.text.length - 1);
      _error = null;
    });
  }

  Widget _buildPinEntry(dynamic l) {
    final pinLength = _pinCtrl.text.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _selectedUser!.fullName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        // PIN stars
        SizedBox(
          height: 32,
          child: Text(
            '*' * pinLength,
            style: TextStyle(
              fontSize: 28,
              letterSpacing: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Error / lockout text
        if (_lockSeconds != null)
          Text(
            l.loginLockedOut(_lockSeconds!),
            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
          )
        else if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
          ),
        const SizedBox(height: 16),
        // Numpad
        SizedBox(
          width: 280,
          child: Column(
            children: [
              _numpadRow(['1', '2', '3']),
              const SizedBox(height: 8),
              _numpadRow(['4', '5', '6']),
              const SizedBox(height: 8),
              _numpadRow(['7', '8', '9']),
              const SizedBox(height: 8),
              Row(
                children: [
                  _numpadButton(
                    child: const Icon(Icons.arrow_back),
                    onTap: () => setState(() {
                      _selectedUser = null;
                      _error = null;
                      _pinCtrl.clear();
                    }),
                  ),
                  const SizedBox(width: 8),
                  _numpadButton(child: const Text('0', style: TextStyle(fontSize: 24)), onTap: () => _numpadTap('0')),
                  const SizedBox(width: 8),
                  _numpadButton(
                    child: const Icon(Icons.backspace_outlined),
                    onTap: _numpadBackspace,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _numpadRow(List<String> digits) {
    return Row(
      children: digits.asMap().entries.map((e) {
        final widget = _numpadButton(
          child: Text(e.value, style: const TextStyle(fontSize: 24)),
          onTap: () => _numpadTap(e.value),
        );
        if (e.key < digits.length - 1) {
          return Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: widget));
        }
        return Expanded(child: widget);
      }).toList(),
    );
  }

  Widget _numpadButton({required Widget child, required VoidCallback onTap}) {
    return Expanded(
      child: SizedBox(
        height: 64,
        child: OutlinedButton(
          onPressed: _lockSeconds != null ? null : onTap,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.zero,
          ),
          child: child,
        ),
      ),
    );
  }

  void _onPinChanged() {
    final pin = _pinCtrl.text;
    if (pin.length < 4 || _selectedUser == null || _lockSeconds != null) return;

    // Silent check — no brute-force counting
    if (PinHelper.verifyPin(pin, _selectedUser!.pinHash)) {
      _loginSuccess();
      return;
    }

    // At max length (6) and still wrong — count as failed attempt
    if (pin.length == 6) {
      final authService = ref.read(authServiceProvider);
      final result = authService.authenticate(pin, _selectedUser!.pinHash);
      switch (result) {
        case AuthSuccess():
          _loginSuccess();
        case AuthLocked(remainingSeconds: final secs):
          _startLockTimer(secs);
        case AuthFailure(message: final msg):
          setState(() {
            _error = msg;
            _pinCtrl.clear();
          });
      }
    }
  }

  Future<void> _loginSuccess() async {
    final session = ref.read(sessionManagerProvider);
    final authService = ref.read(authServiceProvider);
    authService.resetAttempts();
    session.login(_selectedUser!);
    ref.read(activeUserProvider.notifier).state = _selectedUser;
    ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;
    final companyRepo = ref.read(companyRepositoryProvider);
    final companyResult = await companyRepo.getFirst();
    if (companyResult case Success(value: final company?)) {
      ref.read(currentCompanyProvider.notifier).state = company;
    }
    if (mounted) context.go('/bills');
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
