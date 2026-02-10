import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_model.dart';
import '../data/providers/auth_providers.dart';
import '../data/providers/repository_providers.dart';
import 'lock_overlay.dart';

class InactivityDetector extends ConsumerStatefulWidget {
  const InactivityDetector({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InactivityDetector> createState() => _InactivityDetectorState();
}

class _InactivityDetectorState extends ConsumerState<InactivityDetector> {
  Timer? _timer;
  bool _isLocked = false;
  int? _currentTimeoutMinutes;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    if (_isLocked) return;
    _timer?.cancel();
    if (_currentTimeoutMinutes != null && _currentTimeoutMinutes! > 0) {
      _timer = Timer(Duration(minutes: _currentTimeoutMinutes!), _onTimeout);
    }
  }

  void _onTimeout() {
    if (mounted && !_isLocked) {
      // Only lock if there is a logged-in user
      final activeUser = ref.read(activeUserProvider);
      if (activeUser != null) {
        setState(() => _isLocked = true);
      }
    }
  }

  void _onUnlocked(UserModel user, bool isNew) {
    setState(() => _isLocked = false);
    _resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    // Watch company settings for timeout changes
    final company = ref.watch(currentCompanyProvider);
    if (company != null) {
      final settingsRepo = ref.read(companySettingsRepositoryProvider);
      return StreamBuilder(
        stream: settingsRepo.watchByCompany(company.id),
        builder: (context, snap) {
          final newTimeout = snap.data?.autoLockTimeoutMinutes;
          if (newTimeout != _currentTimeoutMinutes) {
            _currentTimeoutMinutes = newTimeout;
            // Reschedule timer on next frame to avoid build-phase setState
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_isLocked) _resetTimer();
            });
          }
          return _buildContent();
        },
      );
    }
    return widget.child;
  }

  Widget _buildContent() {
    return Listener(
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          widget.child,
          if (_isLocked)
            Positioned.fill(
              child: LockOverlay(onUnlocked: _onUnlocked),
            ),
        ],
      ),
    );
  }
}
