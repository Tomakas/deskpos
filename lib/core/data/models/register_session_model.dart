import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_session_model.freezed.dart';

@freezed
class RegisterSessionModel with _$RegisterSessionModel {
  const factory RegisterSessionModel({
    required String id,
    required String companyId,
    required String registerId,
    required String openedByUserId,
    required DateTime openedAt,
    DateTime? closedAt,
    @Default(0) int orderCounter,
    int? openingCash,
    int? closingCash,
    int? expectedCash,
    int? difference,
    int? openBillsAtOpenCount,
    int? openBillsAtOpenAmount,
    int? openBillsAtCloseCount,
    int? openBillsAtCloseAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _RegisterSessionModel;
}
