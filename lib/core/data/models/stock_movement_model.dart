import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/purchase_price_strategy.dart';
import '../enums/stock_movement_direction.dart';
import 'company_scoped_model.dart';

part 'stock_movement_model.freezed.dart';

@freezed
class StockMovementModel with _$StockMovementModel implements CompanyScopedModel {
  const factory StockMovementModel({
    required String id,
    required String companyId,
    String? stockDocumentId,
    required String itemId,
    required double quantity,
    int? purchasePrice,
    required StockMovementDirection direction,
    PurchasePriceStrategy? purchasePriceStrategy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _StockMovementModel;
}
