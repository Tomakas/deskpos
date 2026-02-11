import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/bill_status.dart';
import '../enums/discount_type.dart';

part 'bill_model.freezed.dart';

@freezed
class BillModel with _$BillModel {
  const factory BillModel({
    required String id,
    required String companyId,
    String? customerId,
    String? tableId,
    required String openedByUserId,
    required String billNumber,
    @Default(0) int numberOfGuests,
    @Default(false) bool isTakeaway,
    required BillStatus status,
    required String currencyId,
    @Default(0) int subtotalGross,
    @Default(0) int subtotalNet,
    @Default(0) int discountAmount,
    DiscountType? discountType,
    @Default(0) int taxTotal,
    @Default(0) int totalGross,
    @Default(0) int roundingAmount,
    @Default(0) int paidAmount,
    @Default(0) int loyaltyPointsUsed,
    @Default(0) int loyaltyDiscountAmount,
    required DateTime openedAt,
    DateTime? closedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _BillModel;
}
