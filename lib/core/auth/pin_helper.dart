import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

abstract final class PinHelper {
  static String hashPin(String pin) {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final saltHex = saltBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final hash = sha256.convert(utf8.encode('$saltHex:$pin'));
    return '$saltHex:$hash';
  }

  static bool verifyPin(String pin, String storedHash) {
    final parts = storedHash.split(':');
    if (parts.length != 2) return false;
    final saltHex = parts[0];
    final hash = sha256.convert(utf8.encode('$saltHex:$pin'));
    return '$saltHex:$hash' == storedHash;
  }

  static bool isValidPin(String pin) {
    if (pin.length < 4 || pin.length > 6) return false;
    return RegExp(r'^\d+$').hasMatch(pin);
  }
}
