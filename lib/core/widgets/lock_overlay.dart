import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_service.dart';
import '../auth/pin_helper.dart';
import '../data/models/user_model.dart';
import '../data/providers/auth_providers.dart';
import '../data/providers/repository_providers.dart';
import '../l10n/app_localizations_ext.dart';
import 'pos_numpad.dart';

enum _LockStep { loggedIn, newUser, pin }

class LockOverlay extends ConsumerStatefulWidget {
  const LockOverlay({super.key, required this.onUnlocked});

  final void Function(UserModel user, bool isNew) onUnlocked;

  @override
  ConsumerState<LockOverlay> createState() => _LockOverlayState();
}

class _LockOverlayState extends ConsumerState<LockOverlay> {
  _LockStep _step = _LockStep.loggedIn;
  UserModel? _selectedUser;
  bool _isNewLogin = false;
  String _pin = '';
  String? _error;
  int? _lockSeconds;
  Timer? _lockTimer;

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: SizedBox(
            width: 360,
            child: switch (_step) {
              _LockStep.loggedIn => _buildLoggedInList(context),
              _LockStep.newUser => _buildNewUserList(context),
              _LockStep.pin => _buildPinEntry(context),
            },
          ),
        ),
      ),
    );
  }

  // -- Step 1: Logged-in users -----------------------------------------------

  Widget _buildLoggedInList(BuildContext context) {
    final l = context.l10n;
    final session = ref.read(sessionManagerProvider);
    final company = ref.read(currentCompanyProvider);
    final loggedIn = session.loggedInUsers;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<UserModel>>(
        stream: company != null
            ? ref.read(userRepositoryProvider).watchAll(company.id)
            : const Stream.empty(),
        builder: (context, snap) {
          final allUsers = snap.data ?? [];
          final hasNewUsers = allUsers.any((u) => !session.isLoggedIn(u.id));

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 48),
              const SizedBox(height: 12),
              Text(l.lockScreenTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                l.lockScreenSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              ...loggedIn.map((user) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => _selectUser(user, isNew: false),
                        child: Text(user.fullName),
                      ),
                    ),
                  )),
              if (hasNewUsers) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.tonal(
                    onPressed: () => setState(() => _step = _LockStep.newUser),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_add, size: 20),
                        const SizedBox(width: 8),
                        Text(l.loginTitle),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // -- Step 2: All non-logged-in users ---------------------------------------

  Widget _buildNewUserList(BuildContext context) {
    final l = context.l10n;
    final session = ref.read(sessionManagerProvider);
    final company = ref.read(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<UserModel>>(
        stream: ref.read(userRepositoryProvider).watchAll(company.id),
        builder: (context, snap) {
          final allUsers = snap.data ?? [];
          final notLoggedIn = allUsers.where((u) => !session.isLoggedIn(u.id)).toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.loginTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              if (notLoggedIn.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    l.switchUserSelectUser,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              else
                ...notLoggedIn.map((user) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => _selectUser(user, isNew: true),
                          child: Text(user.fullName),
                        ),
                      ),
                    )),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _step = _LockStep.loggedIn),
                child: Text(l.wizardBack),
              ),
            ],
          );
        },
      ),
    );
  }

  // -- Step 3: Numpad PIN entry ----------------------------------------------

  Widget _buildPinEntry(BuildContext context) {
    final l = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedUser!.fullName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 32,
            child: Text(
              '*' * _pin.length,
              style: TextStyle(
                fontSize: 28,
                letterSpacing: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
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
          PosNumpad(
            width: 280,
            enabled: _lockSeconds == null,
            onDigit: _numpadTap,
            onBackspace: _numpadBackspace,
            bottomLeftChild: const Icon(Icons.arrow_back),
            onBottomLeft: _goBack,
          ),
        ],
      ),
    );
  }

  // -- Actions ---------------------------------------------------------------

  Future<void> _selectUser(UserModel user, {required bool isNew}) async {
    setState(() {
      _selectedUser = user;
      _isNewLogin = isNew;
      _pin = '';
      _error = null;
      _lockSeconds = null;
    });
    ref.read(authServiceProvider).resetAttempts();

    // New logins always require PIN
    if (isNew) {
      setState(() => _step = _LockStep.pin);
      return;
    }

    // For already-logged-in users, check if PIN can be skipped
    final company = ref.read(currentCompanyProvider);
    if (company != null) {
      final settingsRepo = ref.read(companySettingsRepositoryProvider);
      final settings = await settingsRepo.getByCompany(company.id);
      if (!mounted) return;
      if (settings != null && !settings.requirePinOnSwitch) {
        _onSuccess();
        return;
      }
    }

    if (!mounted) return;
    setState(() => _step = _LockStep.pin);
  }

  void _goBack() {
    setState(() {
      _selectedUser = null;
      _pin = '';
      _error = null;
      _step = _isNewLogin ? _LockStep.newUser : _LockStep.loggedIn;
    });
  }

  void _numpadTap(String digit) {
    if (_pin.length >= 6 || _lockSeconds != null) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    _onPinChanged();
  }

  void _numpadBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  void _onPinChanged() {
    if (_pin.length < 4 || _selectedUser == null || _lockSeconds != null) return;

    if (PinHelper.verifyPin(_pin, _selectedUser!.pinHash)) {
      _onSuccess();
      return;
    }

    if (_pin.length == 6) {
      final authService = ref.read(authServiceProvider);
      final result = authService.authenticate(_pin, _selectedUser!.pinHash);
      switch (result) {
        case AuthSuccess():
          _onSuccess();
        case AuthLocked(remainingSeconds: final secs):
          _startLockTimer(secs);
        case AuthFailure(message: final msg):
          setState(() {
            _error = msg;
            _pin = '';
          });
      }
    }
  }

  Future<void> _onSuccess() async {
    final session = ref.read(sessionManagerProvider);
    final authService = ref.read(authServiceProvider);
    authService.resetAttempts();

    if (_isNewLogin) {
      session.login(_selectedUser!);
    } else {
      session.switchTo(_selectedUser!.id);
    }
    ref.read(activeUserProvider.notifier).state = session.activeUser;
    ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;

    // Create shift if register session is active and user has no open shift
    final company = ref.read(currentCompanyProvider);
    if (company != null) {
      final regSessionRepo = ref.read(registerSessionRepositoryProvider);
      final shiftRepo = ref.read(shiftRepositoryProvider);
      final regSession = await regSessionRepo.getActiveSession(company.id);
      if (!mounted) return;
      if (regSession != null) {
        final existing = await shiftRepo.getActiveShiftForUser(_selectedUser!.id, regSession.id);
        if (existing == null && mounted) {
          await shiftRepo.create(
            companyId: company.id,
            registerSessionId: regSession.id,
            userId: _selectedUser!.id,
          );
        }
      }
    }

    if (!mounted) return;
    widget.onUnlocked(_selectedUser!, _isNewLogin);
  }

  void _startLockTimer(int seconds) {
    _lockTimer?.cancel();
    setState(() {
      _lockSeconds = seconds;
      _error = null;
      _pin = '';
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
