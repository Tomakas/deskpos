import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'internal_account_settlement_model.freezed.dart';

@freezed
abstract class InternalAccountSettlementModel with _$InternalAccountSettlementModel implements CompanyScopedModel {
  const factory InternalAccountSettlementModel({
    required String id,
    required String companyId,
    required String internalAccountId,
    required String settledByUserId,
    required DateTime settledAt,
    @Default(0) int totalAmount,
    @Default(0) int settledAmount,
    @Default(0) int forgivenAmount,
    @Default(0) int discountAmount,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _InternalAccountSettlementModel;
}
