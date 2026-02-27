import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'customer_transaction_model.freezed.dart';

@freezed
abstract class CustomerTransactionModel with _$CustomerTransactionModel implements CompanyScopedModel {
  const factory CustomerTransactionModel({
    required String id,
    required String companyId,
    required String customerId,
    required int pointsChange,
    required int creditChange,
    String? orderId,
    String? reference,
    String? note,
    required String processedByUserId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CustomerTransactionModel;
}
