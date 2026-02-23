import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/discount_type.dart';
import '../enums/prep_status.dart';
import '../enums/unit_type.dart';

part 'order_item_model.freezed.dart';

@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String id,
    required String companyId,
    required String orderId,
    required String itemId,
    required String itemName,
    required double quantity,
    required int salePriceAtt,
    required int saleTaxRateAtt,
    required int saleTaxAmount,
    @Default(UnitType.ks) UnitType unit,
    @Default(0) int discount,
    DiscountType? discountType,
    String? notes,
    required PrepStatus status,
    DateTime? prepStartedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _OrderItemModel;
}
