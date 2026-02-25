import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/auth_providers.dart';
import 'formatters.dart';

/// Convenience extensions on [WidgetRef] for formatting money and dates.
///
/// Usage in ConsumerWidget:
///   Text(ref.money(bill.totalGross))
///   Text(ref.fmtDate(bill.openedAt))
extension FormattingExtension on WidgetRef {
  String _locale() => watch(appLocaleProvider).value ?? 'cs';

  /// Returns the current currency symbol (e.g., "Kč", "$", "€").
  String get currencySymbol =>
      watch(currentCurrencyProvider).value?.symbol ?? '';

  /// Formats minor units as full currency string (e.g., "1 234,56 CZK").
  String money(int minorUnits) {
    final currency = watch(currentCurrencyProvider).value;
    return formatMoney(minorUnits, currency, appLocale: _locale());
  }

  /// Formats minor units without symbol (e.g., "1 234,56").
  String moneyValue(int minorUnits) {
    final currency = watch(currentCurrencyProvider).value;
    return formatMoneyValue(minorUnits, currency, appLocale: _locale());
  }

  /// Formats minor units with explicit sign (e.g., "+1 234" / "-1 234").
  String moneyWithSign(int minorUnits) {
    final currency = watch(currentCurrencyProvider).value;
    return formatMoneyWithSign(minorUnits, currency, appLocale: _locale());
  }

  /// Formats date (e.g., cs: "5. 2. 2026", en: "2/5/2026").
  String fmtDate(DateTime dt) => formatDate(dt, _locale());

  /// Formats time in 24h (e.g., "14:30").
  String fmtTime(DateTime dt) => formatTime(dt, _locale());

  /// Formats date + time (e.g., "5. 2. 2026 14:30").
  String fmtDateTime(DateTime dt) => formatDateTime(dt, _locale());

  /// Formats date with day of week (e.g., "po 5. 2. 2026").
  String fmtDateWithDay(DateTime dt) => formatDateWithDay(dt, _locale());

  /// Formats time with seconds (e.g., "14:30:45").
  String fmtTimeSeconds(DateTime dt) => formatTimeWithSeconds(dt, _locale());

  /// Formats short date without year (e.g., "5. 2.").
  String fmtDateShort(DateTime dt) => formatDateShort(dt, _locale());

  /// Formats short date + time (e.g., "5. 2. 14:30").
  String fmtDateTimeShort(DateTime dt) => formatDateTimeShort(dt, _locale());

  /// Formats quantity — locale-aware, trailing zeros dropped.
  String fmtQty(double value, {int maxDecimals = 2}) =>
      formatQuantity(value, _locale(), maxDecimals: maxDecimals);

  /// Formats decimal with fixed precision — locale-aware.
  String fmtDecimal(double value, {int decimalPlaces = 2}) =>
      formatDecimal(value, _locale(), decimalPlaces: decimalPlaces);

  /// Formats percentage — locale-aware, trailing zeros dropped, appends " %".
  String fmtPercent(double percent, {int maxDecimals = 1}) =>
      formatPercent(percent, _locale(), maxDecimals: maxDecimals);
}
