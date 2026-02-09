import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/item_type.dart';
import '../enums/unit_type.dart';

part 'item_model.freezed.dart';

@freezed
class ItemModel with _$ItemModel {
  const factory ItemModel({
    required String id,
    required String companyId,
    String? categoryId,
    required String name,
    String? description,
    required ItemType itemType,
    String? sku,
    required int unitPrice,
    String? saleTaxRateId,
    @Default(true) bool isSellable,
    @Default(true) bool isActive,
    required UnitType unit,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _ItemModel;
}
