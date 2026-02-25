import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/purchase_price_strategy.dart';
import '../enums/stock_document_type.dart';
import 'company_scoped_model.dart';

part 'stock_document_model.freezed.dart';

@freezed
abstract class StockDocumentModel with _$StockDocumentModel implements CompanyScopedModel {
  const factory StockDocumentModel({
    required String id,
    required String companyId,
    required String warehouseId,
    String? supplierId,
    required String userId,
    required String documentNumber,
    required StockDocumentType type,
    PurchasePriceStrategy? purchasePriceStrategy,
    String? note,
    @Default(0) int totalAmount,
    required DateTime documentDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _StockDocumentModel;
}
