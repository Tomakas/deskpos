import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/discount_type.dart';
import '../enums/voucher_discount_scope.dart';
import '../enums/voucher_status.dart';
import '../enums/voucher_type.dart';
import 'company_scoped_model.dart';

part 'voucher_model.freezed.dart';

@freezed
class VoucherModel with _$VoucherModel implements CompanyScopedModel {
  const factory VoucherModel({
    required String id,
    required String companyId,
    required String code,
    required VoucherType type,
    required VoucherStatus status,
    required int value,
    DiscountType? discountType,
    VoucherDiscountScope? discountScope,
    String? itemId,
    String? categoryId,
    int? minOrderValue,
    @Default(1) int maxUses,
    @Default(0) int usedCount,
    String? customerId,
    DateTime? expiresAt,
    DateTime? redeemedAt,
    String? redeemedOnBillId,
    String? sourceBillId,
    String? createdByUserId,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _VoucherModel;
}
