import 'package:intl/intl.dart';

import '../data/models/currency_model.dart';

// ---------------------------------------------------------------------------
// Currency formatting
// ---------------------------------------------------------------------------

/// Returns the numeric locale for a given currency code.
/// Currency determines numeric format (separators, symbol position).
/// For EUR, the app locale is used as secondary signal since EUR formatting
/// varies by country.
String _currencyLocale(String currencyCode, {String appLocale = 'cs'}) {
  return switch (currencyCode) {
    'CZK' => 'cs',
    'USD' => 'en_US',
    'PLN' => 'pl',
    'HUF' => 'hu',
    'EUR' => switch (appLocale) {
        'en' => 'en_IE',
        'de' => 'de',
        'sk' => 'sk',
        _ => 'cs', // default: Czech formatting for EUR
      },
    _ => 'en_US',
  };
}

int _pow10(int exp) {
  int result = 1;
  for (var i = 0; i < exp; i++) {
    result *= 10;
  }
  return result;
}

/// Default CZK currency used as fallback while the actual currency is loading.
final _fallbackCurrency = CurrencyModel(
  id: '',
  code: 'CZK',
  symbol: 'Kč',
  name: 'Česká koruna',
  decimalPlaces: 2,
  createdAt: DateTime(2020),
  updatedAt: DateTime(2020),
);

/// Formats a monetary amount stored as integer minor units.
///
/// [minorUnits] — amount in smallest unit (haléře for CZK, cents for EUR/USD,
///                grosze for PLN, whole forints for HUF)
/// [currency]  — CurrencyModel with code, symbol, decimalPlaces
/// [appLocale] — app locale for EUR formatting disambiguation
String formatMoney(
  int minorUnits,
  CurrencyModel? currency, {
  String appLocale = 'cs',
}) {
  final c = currency ?? _fallbackCurrency;
  final divisor = c.decimalPlaces > 0 ? _pow10(c.decimalPlaces) : 1;
  final amount = minorUnits / divisor;

  final formatter = NumberFormat.currency(
    locale: _currencyLocale(c.code, appLocale: appLocale),
    symbol: c.symbol,
    decimalDigits: c.decimalPlaces,
  );

  return formatter.format(amount);
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
    locale: _currencyLocale(c.code, appLocale: appLocale),
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
/// For CZK (decimalPlaces=2): 1250 → "12.50"
/// For HUF (decimalPlaces=0): 1234 → "1234"
String minorUnitsToInputString(int minorUnits, CurrencyModel? currency) {
  final c = currency ?? _fallbackCurrency;
  if (c.decimalPlaces == 0) return minorUnits.toString();
  final divisor = _pow10(c.decimalPlaces);
  return (minorUnits / divisor).toStringAsFixed(c.decimalPlaces);
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
