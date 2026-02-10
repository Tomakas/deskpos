import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'stock_level_model.freezed.dart';

@freezed
class StockLevelModel with _$StockLevelModel implements CompanyScopedModel {
  const factory StockLevelModel({
    required String id,
    required String companyId,
    required String warehouseId,
    required String itemId,
    @Default(0.0) double quantity,
    double? minQuantity,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _StockLevelModel;
}
