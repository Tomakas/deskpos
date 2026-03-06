/// Tax calculation utility for extracting tax from gross amounts
/// and computing per-rate tax breakdowns after discounts.
class TaxByRateResult {
  const TaxByRateResult(this.byRate);

  /// rate (basis points) → (gross after discount, extracted tax)
  final Map<int, ({int gross, int tax})> byRate;

  static const empty = TaxByRateResult({});

  int get totalTax => byRate.values.fold(0, (sum, v) => sum + v.tax);

  int get totalGross => byRate.values.fold(0, (sum, v) => sum + v.gross);

  TaxByRateResult merge(TaxByRateResult other) {
    final merged = Map<int, ({int gross, int tax})>.from(byRate);
    for (final entry in other.byRate.entries) {
      final existing = merged[entry.key];
      if (existing != null) {
        merged[entry.key] = (
          gross: existing.gross + entry.value.gross,
          tax: existing.tax + entry.value.tax,
        );
      } else {
        merged[entry.key] = entry.value;
      }
    }
    return TaxByRateResult(merged);
  }
}

class TaxCalculator {
  TaxCalculator._();

  /// Extract tax from a gross amount at a given rate (basis points).
  /// Formula: gross * rate / (10000 + rate)
  static int extractTax(int gross, int rate) {
    if (gross <= 0 || rate <= 0) return 0;
    return (gross * rate / (10000 + rate)).round();
  }

  /// Compute per-rate tax breakdown for a single order item.
  ///
  /// [baseGross] — gross amount for the base item (salePriceAtt * qty)
  /// [baseRate] — tax rate in basis points for the base item
  /// [modifiers] — list of (gross, rate) for each modifier (already * qty)
  /// [totalDiscount] — total discount on this item (item discount + voucher discount)
  static TaxByRateResult computeItemTax({
    required int baseGross,
    required int baseRate,
    required List<({int gross, int rate})> modifiers,
    required int totalDiscount,
  }) {
    // Group gross amounts by rate
    final rateGross = <int, int>{};
    rateGross[baseRate] = (rateGross[baseRate] ?? 0) + baseGross;
    for (final mod in modifiers) {
      rateGross[mod.rate] = (rateGross[mod.rate] ?? 0) + mod.gross;
    }

    final totalItemGross = rateGross.values.fold(0, (sum, v) => sum + v);
    final discountedGross = totalItemGross - totalDiscount;

    if (discountedGross <= 0) {
      // Fully discounted — zero tax for all rates
      final result = <int, ({int gross, int tax})>{};
      for (final rate in rateGross.keys) {
        result[rate] = (gross: 0, tax: 0);
      }
      return TaxByRateResult(result);
    }

    final result = <int, ({int gross, int tax})>{};
    if (totalDiscount > 0 && totalItemGross > 0) {
      // Proportionally reduce gross per rate
      int allocatedGross = 0;
      final rates = rateGross.keys.toList();
      for (int i = 0; i < rates.length; i++) {
        final rate = rates[i];
        final groupGross = rateGross[rate]!;
        int adjustedGross;
        if (i == rates.length - 1) {
          // Last group gets remainder to avoid rounding drift
          adjustedGross = discountedGross - allocatedGross;
        } else {
          adjustedGross = (groupGross * discountedGross / totalItemGross).round();
        }
        allocatedGross += adjustedGross;
        result[rate] = (
          gross: adjustedGross,
          tax: extractTax(adjustedGross, rate),
        );
      }
    } else {
      // No discount — extract tax from original gross per rate
      for (final entry in rateGross.entries) {
        result[entry.key] = (
          gross: entry.value,
          tax: extractTax(entry.value, entry.key),
        );
      }
    }

    return TaxByRateResult(result);
  }

  /// Apply bill-level discount to an accumulated item tax result.
  ///
  /// [itemTaxResult] — accumulated tax from all items (after item-level discounts)
  /// [subtotalGross] — sum of all item grosses (after item discounts)
  /// [billDiscount] — bill-level discount amount (bill discount + loyalty, NOT gift vouchers)
  static TaxByRateResult applyBillDiscount({
    required TaxByRateResult itemTaxResult,
    required int subtotalGross,
    required int billDiscount,
  }) {
    if (billDiscount <= 0 || subtotalGross <= 0) return itemTaxResult;

    final effectiveGross = subtotalGross - billDiscount;
    if (effectiveGross <= 0) {
      final result = <int, ({int gross, int tax})>{};
      for (final rate in itemTaxResult.byRate.keys) {
        result[rate] = (gross: 0, tax: 0);
      }
      return TaxByRateResult(result);
    }

    final result = <int, ({int gross, int tax})>{};
    final rates = itemTaxResult.byRate.keys.toList();
    int allocatedGross = 0;

    for (int i = 0; i < rates.length; i++) {
      final rate = rates[i];
      final groupGross = itemTaxResult.byRate[rate]!.gross;
      int adjustedGross;
      if (i == rates.length - 1) {
        adjustedGross = effectiveGross - allocatedGross;
      } else {
        adjustedGross = (groupGross * effectiveGross / subtotalGross).round();
      }
      allocatedGross += adjustedGross;
      result[rate] = (
        gross: adjustedGross,
        tax: extractTax(adjustedGross, rate),
      );
    }

    return TaxByRateResult(result);
  }
}
