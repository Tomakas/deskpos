import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/item_type.dart';
import '../enums/unit_type.dart';
import 'company_scoped_model.dart';

part 'item_model.freezed.dart';

@freezed
abstract class ItemModel with _$ItemModel implements CompanyScopedModel {
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
    String? altSku,
    int? purchasePrice,
    String? purchaseTaxRateId,
    @Default(true) bool isOnSale,
    @Default(false) bool isStockTracked,
    String? manufacturerId,
    String? supplierId,
    String? parentId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _ItemModel;
}
