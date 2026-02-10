import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/cash_movement_type.dart';

part 'cash_movement_model.freezed.dart';

@freezed
class CashMovementModel with _$CashMovementModel {
  const factory CashMovementModel({
    required String id,
    required String companyId,
    required String registerSessionId,
    required String userId,
    required CashMovementType type,
    required int amount,
    String? reason,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CashMovementModel;
}
