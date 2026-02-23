import 'dart:math';

import '../enums/discount_type.dart';
import '../enums/voucher_discount_scope.dart';
import '../enums/voucher_type.dart';
import '../models/order_item_model.dart';
import '../models/order_item_modifier_model.dart';
import '../models/voucher_model.dart';

class VoucherItemAttribution {
  const VoucherItemAttribution({
    required this.orderItemId,
    required this.itemName,
    required this.coveredQty,
    required this.discountAmount,
  });

  final String orderItemId;
  final String itemName;
  final double coveredQty;
  final int discountAmount;
}

class VoucherDiscountResult {
  const VoucherDiscountResult({
    required this.totalDiscount,
    required this.attributions,
  });

  final int totalDiscount;
  final List<VoucherItemAttribution> attributions;
}

class VoucherDiscountCalculator {
  VoucherDiscountCalculator._();

  /// Compute scope-aware voucher discount with per-item attribution.
  ///
  /// [voucher] must be of type [VoucherType.discount].
  /// [activeItems] are the non-cancelled/voided order items on the bill.
  /// [modsByItem] maps orderItemId → list of modifiers for that item.
  /// [subtotalGross] is the bill subtotal (sum of item totals after item discounts).
  /// [itemCategoryMap] maps catalog itemId → categoryId (needed for category scope).
  static VoucherDiscountResult compute({
    required VoucherModel voucher,
    required List<OrderItemModel> activeItems,
    required Map<String, List<OrderItemModifierModel>> modsByItem,
    required int subtotalGross,
    Map<String, String>? itemCategoryMap,
  }) {
    if (voucher.type != VoucherType.discount) {
      return const VoucherDiscountResult(totalDiscount: 0, attributions: []);
    }

    // 1. Filter by scope
    final scope = voucher.discountScope ?? VoucherDiscountScope.bill;
    final matchingItems = <OrderItemModel>[];
    for (final item in activeItems) {
      switch (scope) {
        case VoucherDiscountScope.bill:
          matchingItems.add(item);
        case VoucherDiscountScope.product:
          if (voucher.itemId != null && item.itemId == voucher.itemId) {
            matchingItems.add(item);
          }
        case VoucherDiscountScope.category:
          if (voucher.categoryId != null && itemCategoryMap != null) {
            final itemCatId = itemCategoryMap[item.itemId];
            if (itemCatId == voucher.categoryId) {
              matchingItems.add(item);
            }
          }
      }
    }

    if (matchingItems.isEmpty) {
      return const VoucherDiscountResult(totalDiscount: 0, attributions: []);
    }

    // 2. Compute effective unit price for each matching item
    //    effectiveUnitPrice = (basePrice × qty + modifiers − itemDiscount) / qty
    final itemInfos = <_ItemInfo>[];
    for (final item in matchingItems) {
      int itemSubtotal = (item.salePriceAtt * item.quantity).round();
      final mods = modsByItem[item.id] ?? [];
      for (final mod in mods) {
        itemSubtotal += (mod.unitPrice * mod.quantity * item.quantity).round();
      }
      int itemDiscount = 0;
      if (item.discount > 0) {
        if (item.discountType == DiscountType.percent) {
          itemDiscount = (itemSubtotal * item.discount / 10000).round();
        } else {
          itemDiscount = item.discount;
        }
      }
      final netTotal = itemSubtotal - itemDiscount;
      final effectiveUnitPrice = item.quantity > 0
          ? (netTotal / item.quantity).round()
          : 0;
      itemInfos.add(_ItemInfo(
        item: item,
        effectiveUnitPrice: effectiveUnitPrice,
        netTotal: netTotal,
      ));
    }

    // 3. Sort by effective unit price descending (most expensive first)
    itemInfos.sort((a, b) => b.effectiveUnitPrice.compareTo(a.effectiveUnitPrice));

    // 4. Allocate maxUses units across sorted items
    final maxUses = voucher.maxUses;
    double remainingUses = maxUses.toDouble();
    final coveredItems = <_CoveredItem>[];
    for (final info in itemInfos) {
      if (remainingUses <= 0) break;
      final take = min(info.item.quantity, remainingUses);
      coveredItems.add(_CoveredItem(info: info, coveredQty: take));
      remainingUses -= take;
    }

    if (coveredItems.isEmpty) {
      return const VoucherDiscountResult(totalDiscount: 0, attributions: []);
    }

    // 5. Compute discount per covered item
    final discountType = voucher.discountType ?? DiscountType.percent;
    final attributions = <VoucherItemAttribution>[];
    int totalDiscount = 0;

    if (discountType == DiscountType.percent) {
      // Percent: apply voucher.value (basis points) to each covered item's covered value
      for (final ci in coveredItems) {
        final coveredValue = (ci.info.effectiveUnitPrice * ci.coveredQty).round();
        final disc = (coveredValue * voucher.value / 10000).round();
        attributions.add(VoucherItemAttribution(
          orderItemId: ci.info.item.id,
          itemName: ci.info.item.itemName,
          coveredQty: ci.coveredQty,
          discountAmount: disc,
        ));
        totalDiscount += disc;
      }
    } else {
      // Absolute: voucher.value is total discount, split proportionally
      final totalCoveredValue = coveredItems.fold<int>(
        0,
        (sum, ci) => sum + (ci.info.effectiveUnitPrice * ci.coveredQty).round(),
      );
      if (totalCoveredValue <= 0) {
        return const VoucherDiscountResult(totalDiscount: 0, attributions: []);
      }
      final cappedValue = min(voucher.value, totalCoveredValue);
      int allocated = 0;
      for (int i = 0; i < coveredItems.length; i++) {
        final ci = coveredItems[i];
        final coveredValue = (ci.info.effectiveUnitPrice * ci.coveredQty).round();
        int disc;
        if (i == coveredItems.length - 1) {
          // Last item gets remainder to avoid rounding drift
          disc = cappedValue - allocated;
        } else {
          disc = (cappedValue * coveredValue / totalCoveredValue).round();
        }
        attributions.add(VoucherItemAttribution(
          orderItemId: ci.info.item.id,
          itemName: ci.info.item.itemName,
          coveredQty: ci.coveredQty,
          discountAmount: disc,
        ));
        allocated += disc;
        totalDiscount += disc;
      }
    }

    // 6. Cap total at subtotalGross
    if (totalDiscount > subtotalGross) {
      totalDiscount = subtotalGross;
    }

    return VoucherDiscountResult(
      totalDiscount: totalDiscount,
      attributions: attributions,
    );
  }
}

class _ItemInfo {
  const _ItemInfo({
    required this.item,
    required this.effectiveUnitPrice,
    required this.netTotal,
  });

  final OrderItemModel item;
  final int effectiveUnitPrice;
  final int netTotal;
}

class _CoveredItem {
  const _CoveredItem({
    required this.info,
    required this.coveredQty,
  });

  final _ItemInfo info;
  final double coveredQty;
}
