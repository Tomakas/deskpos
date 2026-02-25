import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/auth/pin_helper.dart';
import '../../../core/data/enums/role_name.dart';
import '../../../core/data/enums/sell_mode.dart';
import '../../../core/data/models/role_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/platform/platform_io.dart';
import '../../../core/widgets/pos_numpad.dart';

enum _LoginMode { pos, kds }

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
  List<RoleModel> _roles = [];
  bool _loaded = false;
  bool _isLoggingIn = false;
  _LoginMode _selectedMode = _LoginMode.pos;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadSavedMode();
  }

  Future<void> _loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('login_mode');
    if (saved == 'kds' && mounted) {
      setState(() => _selectedMode = _LoginMode.kds);
    }
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
    final roleRepo = ref.read(roleRepositoryProvider);
    final roles = await roleRepo.watchAll().first;
    if (!mounted) return;
    setState(() {
      _users = users;
      _roles = roles;
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
          constraints: const BoxConstraints(maxWidth: 600),
          child: _selectedUser != null
              ? _buildPinEntry(l)
              : _buildUserList(l),
        ),
      ),
    );
  }

  Widget _buildModeDropdown(AppLocalizations l) {
    return DropdownButton<_LoginMode>(
      value: _selectedMode,
      isExpanded: true,
      onChanged: (v) => setState(() { if (v != null) _selectedMode = v; }),
      items: [
        DropdownMenuItem(value: _LoginMode.pos, child: Text(l.modePOS)),
        DropdownMenuItem(value: _LoginMode.kds, child: Text(l.modeKDS)),
      ],
    );
  }

  String? _resolveRoleLabel(AppLocalizations l, String roleId) {
    final role = _roles.where((r) => r.id == roleId).firstOrNull;
    if (role == null) return null;
    return switch (role.name) {
      RoleName.helper => l.roleHelper,
      RoleName.operator => l.roleOperator,
      RoleName.manager => l.roleManager,
      RoleName.admin => l.roleAdmin,
    };
  }

  Widget _buildUserList(AppLocalizations l) {
    if (!_loaded) {
      return const CircularProgressIndicator();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l.loginTitle, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 32),
        ..._users.map((user) {
          final roleLabel = _resolveRoleLabel(l, user.roleId);
          return Padding(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user.fullName),
                    if (roleLabel != null)
                      Text(
                        roleLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        _buildModeDropdown(l),
        if (!kIsWeb) ...[
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => exitApp(),
            child: Text(l.actionExitApp),
          ),
        ],
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

  Widget _buildPinEntry(AppLocalizations l) {
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
        PosNumpad(
          width: 280,
          enabled: _lockSeconds == null && !_isLoggingIn,
          onDigit: _numpadTap,
          onBackspace: _numpadBackspace,
          bottomLeftChild: const Icon(Icons.arrow_back),
          onBottomLeft: () => setState(() {
            _selectedUser = null;
            _error = null;
            _pinCtrl.clear();
          }),
        ),
      ],
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
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);
    try {
      final session = ref.read(sessionManagerProvider);
      final authService = ref.read(authServiceProvider);
      authService.resetAttempts();
      session.login(_selectedUser!);
      // NOTE: activeUserProvider/loggedInUsersProvider are set AFTER async work
      // to avoid triggering the router redirect (→ /bills) before we navigate.
      final companyRepo = ref.read(companyRepositoryProvider);
      final companyResult = await companyRepo.getFirst();
      if (!mounted) return;
      if (companyResult case Success(value: final company?)) {
        ref.read(currentCompanyProvider.notifier).state = company;
        // Ensure currency is loaded before navigating to price-displaying screens
        await ref.read(currentCurrencyProvider.future);
        if (!mounted) return;
        // Create shift if register session is active
        final regSessionRepo = ref.read(registerSessionRepositoryProvider);
        final regSession = await regSessionRepo.getActiveSession(company.id);
        if (!mounted) return;
        if (regSession != null) {
          final shiftRepo = ref.read(shiftRepositoryProvider);
          final existing = await shiftRepo.getActiveShiftForUser(_selectedUser!.id, regSession.id);
          if (existing == null) {
            await shiftRepo.create(
              companyId: company.id,
              registerSessionId: regSession.id,
              userId: _selectedUser!.id,
            );
          }
        }
      }
      // Persist selected mode
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('login_mode', _selectedMode == _LoginMode.kds ? 'kds' : 'pos');
      if (!mounted) return;
      // Set auth providers just before navigation to prevent premature router redirect
      ref.read(activeUserProvider.notifier).state = _selectedUser;
      ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;
      // Navigate based on mode
      if (mounted) {
        if (_selectedMode == _LoginMode.kds) {
          context.go('/kds');
        } else {
          final reg = await ref.read(activeRegisterProvider.future);
          if (!mounted) return;
          context.go(reg?.sellMode == SellMode.retail ? '/sell' : '/bills');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
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
