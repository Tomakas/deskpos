import 'package:intl/intl.dart';

import '../data/models/currency_model.dart';
import '../logging/app_logger.dart';

// ---------------------------------------------------------------------------
// Currency formatting
// ---------------------------------------------------------------------------

int _pow10(int exp) {
  int result = 1;
  for (var i = 0; i < exp; i++) {
    result *= 10;
  }
  return result;
}

/// Neutral fallback currency used when the actual currency is not yet available.
/// Empty symbol prevents displaying a wrong currency sign in edge cases.
final _fallbackCurrency = CurrencyModel(
  id: '',
  code: '',
  symbol: '',
  name: '',
  decimalPlaces: 2,
  createdAt: DateTime(2020),
  updatedAt: DateTime(2020),
);

/// Formats a monetary amount stored as integer minor units.
///
/// [minorUnits] — amount in smallest unit (haléře for CZK, cents for EUR/USD,
///                grosze for PLN, whole forints for HUF)
/// [currency]  — CurrencyModel with code, symbol, decimalPlaces
/// [appLocale] — app locale that determines numeric format (separators)
String formatMoney(
  int minorUnits,
  CurrencyModel? currency, {
  String appLocale = 'cs',
}) {
  if (currency == null) {
    AppLogger.warn('formatMoney: currency is null, using fallback');
  }
  final c = currency ?? _fallbackCurrency;
  final divisor = c.decimalPlaces > 0 ? _pow10(c.decimalPlaces) : 1;
  final amount = minorUnits / divisor;

  final formatter = NumberFormat.decimalPatternDigits(
    locale: appLocale,
    decimalDigits: c.decimalPlaces,
  );

  final symbol = c.symbol;
  if (symbol.isEmpty) return formatter.format(amount);
  return '${formatter.format(amount)} $symbol';
}

/// Formats without symbol — for table cells where the symbol is in the header.
String formatMoneyValue(
  int minorUnits,
  CurrencyModel? currency, {
  String appLocale = 'cs',
}) {
  final c = currency ?? _fallbackCurrency;
  final divisor = c.decimalPlaces > 0 ? _pow10(c.decimalPlaces) : 1;
  final amount = minorUnits / divisor;

  final formatter = NumberFormat.decimalPatternDigits(
    locale: appLocale,
    decimalDigits: c.decimalPlaces,
  );

  return formatter.format(amount);
}

/// Formats with explicit +/- sign prefix — for Z-reports and cash differences.
String formatMoneyWithSign(
  int minorUnits,
  CurrencyModel? currency, {
  String appLocale = 'cs',
}) {
  final prefix = minorUnits >= 0 ? '+' : '';
  return '$prefix${formatMoney(minorUnits, currency, appLocale: appLocale)}';
}

/// Formats for thermal printer output — replaces non-breaking spaces with regular spaces.
String formatMoneyForPrint(
  int minorUnits,
  CurrencyModel? currency, {
  String appLocale = 'cs',
}) {
  return formatMoney(minorUnits, currency, appLocale: appLocale)
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u202F', ' ');
}

// ---------------------------------------------------------------------------
// Money input parsing
// ---------------------------------------------------------------------------

/// Parses a user-entered amount string into integer minor units.
///
/// For CZK/EUR/USD/PLN (decimalPlaces=2): "12.50" → 1250
/// For HUF (decimalPlaces=0): "1234" → 1234
int parseMoney(String input, CurrencyModel? currency) {
  final c = currency ?? _fallbackCurrency;
  // Accept both comma and dot as decimal separator for input
  final normalized = input.replaceAll(',', '.').trim();
  final parsed = double.tryParse(normalized) ?? 0;
  final multiplier = c.decimalPlaces > 0 ? _pow10(c.decimalPlaces) : 1;
  return (parsed * multiplier).round();
}

/// Parses a user-entered amount string into integer minor units, or null if empty.
int? parseMoneyOrNull(String input, CurrencyModel? currency) {
  if (input.trim().isEmpty) return null;
  return parseMoney(input, currency);
}

/// Extracts the whole-unit part from minor units (drops fractional part).
///
/// For CZK (decimalPlaces=2): 50099 → 500
/// For HUF (decimalPlaces=0): 500 → 500
///
/// Used by numpad-style inputs that only accept whole numbers.
int wholeUnitsFromMinor(int minorUnits, CurrencyModel? currency) {
  final c = currency ?? _fallbackCurrency;
  final divisor = c.decimalPlaces > 0 ? _pow10(c.decimalPlaces) : 1;
  return minorUnits ~/ divisor;
}

/// Converts minor units to a string suitable for pre-filling an input field.
///
/// When [locale] is provided, uses locale-aware decimal separator (e.g. comma
/// for CS). Otherwise falls back to dot-based formatting.
///
/// For CZK (decimalPlaces=2): 1250 → "12,50" (cs) / "12.50" (en)
/// For HUF (decimalPlaces=0): 1234 → "1234"
String minorUnitsToInputString(int minorUnits, CurrencyModel? currency, {String? locale}) {
  final c = currency ?? _fallbackCurrency;
  if (c.decimalPlaces == 0) return minorUnits.toString();
  final divisor = _pow10(c.decimalPlaces);
  final value = minorUnits / divisor;
  if (locale != null) {
    final fmt = NumberFormat.decimalPattern(locale)
      ..turnOffGrouping()
      ..maximumFractionDigits = c.decimalPlaces
      ..minimumFractionDigits = c.decimalPlaces;
    return fmt.format(value);
  }
  return value.toStringAsFixed(c.decimalPlaces);
}

/// Formats a number for pre-filling a text input field.
///
/// Uses locale-aware decimal separator, no grouping separators.
/// Drops trailing zeros: 21.0 → "21", 10.5 → "10,5" (cs) / "10.5" (en).
String formatForInput(num value, String locale, {int maxDecimals = 2}) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  final fmt = NumberFormat.decimalPattern(locale)
    ..turnOffGrouping()
    ..maximumFractionDigits = maxDecimals
    ..minimumFractionDigits = 0;
  return fmt.format(value);
}

/// Parses a user-entered number, accepting both comma and dot as decimal
/// separator. Returns `null` when the input cannot be parsed.
double? parseInputDouble(String input) {
  final normalized = input.replaceAll(',', '.').trim();
  return double.tryParse(normalized);
}

// ---------------------------------------------------------------------------
// Date / Time formatting
// ---------------------------------------------------------------------------

/// Formats date per app locale. cs → 5. 2. 2026, en → 2/5/2026
String formatDate(DateTime dt, String locale) {
  return DateFormat.yMd(locale).format(dt);
}

/// Formats time in 24-hour format per locale. cs → 14:30, en → 14:30
String formatTime(DateTime dt, String locale) {
  return DateFormat.Hm(locale).format(dt);
}

/// Formats date + 24-hour time. cs → 5. 2. 2026 14:30, en → 2/5/2026 14:30
String formatDateTime(DateTime dt, String locale) {
  return DateFormat.yMd(locale).add_Hm().format(dt);
}

/// Short date without year. cs → 5. 2., en → 2/5
String formatDateShort(DateTime dt, String locale) {
  return DateFormat.Md(locale).format(dt);
}

/// Day of week + date. cs → po 5. 2. 2026, en → Mon, 2/5/2026
String formatDateWithDay(DateTime dt, String locale) {
  return DateFormat.yMEd(locale).format(dt);
}

/// Time with seconds. cs → 14:30:45, en → 14:30:45
String formatTimeWithSeconds(DateTime dt, String locale) {
  return DateFormat.Hms(locale).format(dt);
}

/// Short date + time (no year). cs → 5. 2. 14:30, en → 2/5 14:30
String formatDateTimeShort(DateTime dt, String locale) {
  return DateFormat.Md(locale).add_Hm().format(dt);
}

/// For print output — replaces non-breaking spaces in date formatting.
String formatDateForPrint(DateTime dt, String locale) {
  return formatDateTime(dt, locale)
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u202F', ' ');
}

/// Date only for print output — replaces non-breaking spaces.
String formatDateOnlyForPrint(DateTime dt, String locale) {
  return formatDate(dt, locale)
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u202F', ' ');
}

/// Time only for print output — replaces non-breaking spaces.
String formatTimeForPrint(DateTime dt, String locale) {
  return formatTime(dt, locale)
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u202F', ' ');
}

// ---------------------------------------------------------------------------
// Number formatting (quantities, decimals, percentages)
// ---------------------------------------------------------------------------

/// Formats a quantity — drops trailing zeros.
/// 5.0 → "5", 2.5 → "2,5" (cs) / "2.5" (en), 1.75 → "1,75" / "1.75"
String formatQuantity(double value, String locale, {int maxDecimals = 2}) {
  if (value == value.roundToDouble() && maxDecimals >= 0) {
    return value.round().toString();
  }
  final fmt = NumberFormat.decimalPattern(locale)
    ..maximumFractionDigits = maxDecimals
    ..minimumFractionDigits = 0;
  return fmt.format(value);
}

/// Formats a decimal with fixed precision.
/// 25.50 → "25,50" (cs) / "25.50" (en)
String formatDecimal(double value, String locale, {int decimalPlaces = 2}) {
  final fmt = NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: decimalPlaces,
  );
  return fmt.format(value);
}

/// Formats a percentage value — drops trailing zeros, appends " %".
/// 21.0 → "21 %", 10.5 → "10,5 %" (cs) / "10.5 %" (en)
String formatPercent(double percent, String locale, {int maxDecimals = 1}) {
  if (percent == percent.roundToDouble()) {
    return '${percent.round()} %';
  }
  final fmt = NumberFormat.decimalPattern(locale)
    ..maximumFractionDigits = maxDecimals
    ..minimumFractionDigits = 0;
  return '${fmt.format(percent)} %';
}

// ---------------------------------------------------------------------------
// Duration formatting
// ---------------------------------------------------------------------------

/// Formats a [Duration] using localized hour/minute labels.
///
/// [hm], [hOnly], [mOnly] are localized format strings from l10n
/// (e.g., l.durationHoursMinutes, l.durationHoursOnly, l.durationMinutesOnly).
String formatDuration(
  Duration d, {
  required String Function(int h, int m) hm,
  required String Function(int h) hOnly,
  required String Function(int m) mOnly,
}) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h > 0 && m > 0) return hm(h, m);
  if (h > 0) return hOnly(h);
  return mOnly(m);
}
