import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'order_item_modifier_model.freezed.dart';

@freezed
class OrderItemModifierModel with _$OrderItemModifierModel implements CompanyScopedModel {
  const factory OrderItemModifierModel({
    required String id,
    required String companyId,
    required String orderItemId,
    required String modifierItemId,
    required String modifierGroupId,
    @Default('') String modifierItemName,
    @Default(1.0) double quantity,
    required int unitPrice,
    required int taxRate,
    required int taxAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _OrderItemModifierModel;
}
