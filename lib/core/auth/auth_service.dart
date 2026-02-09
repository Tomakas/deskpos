import '../logging/app_logger.dart';
import 'pin_helper.dart';

sealed class AuthResult {}

class AuthSuccess extends AuthResult {}

class AuthFailure extends AuthResult {
  AuthFailure(this.message);
  final String message;
}

class AuthLocked extends AuthResult {
  AuthLocked(this.remainingSeconds);
  final int remainingSeconds;
}

class AuthService {
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  int get failedAttempts => _failedAttempts;

  AuthResult authenticate(String pin, String storedHash) {
    // Check lockout
    if (_lockoutUntil != null) {
      final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      if (remaining > 0) {
        return AuthLocked(remaining);
      }
      _lockoutUntil = null;
    }

    // Verify PIN
    if (PinHelper.verifyPin(pin, storedHash)) {
      _failedAttempts = 0;
      _lockoutUntil = null;
      AppLogger.info('Authentication successful');
      return AuthSuccess();
    }

    // Failed attempt
    _failedAttempts++;
    AppLogger.warn('Authentication failed, attempt $_failedAttempts');

    final lockoutSeconds = _getLockoutSeconds(_failedAttempts);
    if (lockoutSeconds > 0) {
      _lockoutUntil = DateTime.now().add(Duration(seconds: lockoutSeconds));
      return AuthLocked(lockoutSeconds);
    }

    return AuthFailure('Invalid PIN');
  }

  int _getLockoutSeconds(int attempts) {
    return switch (attempts) {
      <= 3 => 0,
      4 => 5,
      5 => 30,
      6 => 300,
      _ => 3600,
    };
  }

  void resetAttempts() {
    _failedAttempts = 0;
    _lockoutUntil = null;
  }
}
