import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/models/bill_model.dart';
import '../../core/data/enums/prep_status.dart';
import '../../core/data/enums/voucher_discount_scope.dart';
import '../../core/data/enums/voucher_type.dart';
import '../../core/data/models/order_item_modifier_model.dart';
import '../../core/data/providers/repository_providers.dart';
import '../../core/data/result.dart';
import '../../core/data/utils/voucher_discount_calculator.dart';
import '../../core/logging/app_logger.dart';

/// Recalculates voucher discounts for a bill after items change.
///
/// For gift/deposit vouchers: re-clamps the bill-level discount to the new subtotal.
/// For discount vouchers: unredeems old uses, clears per-item discounts,
/// recomputes via [VoucherDiscountCalculator], applies new per-item discounts
/// (without splitting items), and re-redeems.
Future<void> recalculateVoucherForBill(WidgetRef ref, String billId) async {
  final billRepo = ref.read(billRepositoryProvider);
  final voucherRepo = ref.read(voucherRepositoryProvider);
  final orderRepo = ref.read(orderRepositoryProvider);

  // Load bill
  final billResult = await billRepo.getById(billId);
  if (billResult is! Success<BillModel>) return;
  final bill = billResult.value;

  // No voucher applied — nothing to do
  if (bill.voucherId == null) return;

  final voucher = await voucherRepo.getById(bill.voucherId!, includeDeleted: true);
  if (voucher == null) return;

  // --- Gift / Deposit vouchers ---
  if (voucher.type == VoucherType.gift || voucher.type == VoucherType.deposit) {
    final newAmount = voucher.value.clamp(0, bill.subtotalGross);
    if (newAmount != bill.voucherDiscountAmount) {
      await billRepo.applyVoucher(
        billId: billId,
        voucherId: voucher.id,
        voucherDiscountAmount: newAmount,
      );
    }
    return;
  }

  // --- Discount vouchers ---
  if (voucher.type != VoucherType.discount) return;

  try {
    // 1. Count old uses from items that currently have a voucher discount
    final allItems = await orderRepo.getOrderItemsByBill(billId);
    final oldCoveredItems = allItems.where(
      (i) => i.voucherDiscount > 0 && i.status != PrepStatus.voided,
    );
    final oldUses = oldCoveredItems.fold<double>(0, (s, i) => s + i.quantity).ceil();

    // 2. Unredeem old uses
    if (oldUses > 0) {
      await voucherRepo.unredeem(voucher.id, usesToReturn: oldUses);
    }

    // 3. Clear per-item voucher discounts
    await orderRepo.clearVoucherDiscounts(billId);

    // 4. Recalculate bill totals (now without voucher discounts) to get correct subtotal
    await billRepo.updateTotals(billId);

    // 5. Re-fetch bill and active items for fresh computation
    final freshBillResult = await billRepo.getById(billId);
    if (freshBillResult is! Success<BillModel>) return;
    final freshBill = freshBillResult.value;

    final freshItems = await orderRepo.getOrderItemsByBill(billId);
    final activeItems = freshItems.where((i) => i.status != PrepStatus.voided).toList();

    if (activeItems.isEmpty) {
      // No items left — remove voucher from bill entirely
      await billRepo.applyVoucher(
        billId: billId,
        voucherId: voucher.id,
        voucherDiscountAmount: 0,
      );
      return;
    }

    // 6. Build modifier map
    final modifierRepo = ref.read(orderItemModifierRepositoryProvider);
    final itemIds = activeItems.map((i) => i.id).toList();
    final allMods = await modifierRepo.getByOrderItemIds(itemIds);
    final modsByItem = <String, List<OrderItemModifierModel>>{};
    for (final mod in allMods) {
      modsByItem.putIfAbsent(mod.orderItemId, () => []).add(mod);
    }

    // 7. Build category map if needed
    Map<String, String>? itemCategoryMap;
    if (voucher.discountScope == VoucherDiscountScope.category && voucher.categoryId != null) {
      final itemRepo = ref.read(itemRepositoryProvider);
      itemCategoryMap = {};
      final catalogIds = activeItems.map((i) => i.itemId).toSet();
      for (final catId in catalogIds) {
        final catalogItem = await itemRepo.getById(catId, includeDeleted: true);
        if (catalogItem?.categoryId != null) {
          itemCategoryMap[catId] = catalogItem!.categoryId!;
        }
      }
    }

    // 8. Compute new voucher discount distribution
    final vResult = VoucherDiscountCalculator.compute(
      voucher: voucher,
      activeItems: activeItems,
      modsByItem: modsByItem,
      subtotalGross: freshBill.subtotalGross,
      itemCategoryMap: itemCategoryMap,
    );

    // 9. Apply per-item discounts (no splitting!)
    for (final attr in vResult.attributions) {
      await orderRepo.setVoucherDiscount(attr.orderItemId, attr.discountAmount);
    }

    // 10. Re-redeem with new uses
    final newUses = vResult.attributions.fold<double>(0, (s, a) => s + a.coveredQty).ceil();
    if (newUses > 0) {
      await voucherRepo.redeem(voucher.id, billId, usesConsumed: newUses);
    }

    // 11. Final totals update
    await billRepo.updateTotals(billId);
  } catch (e, s) {
    AppLogger.error('Failed to recalculate voucher for bill $billId', error: e, stackTrace: s);
  }
}
