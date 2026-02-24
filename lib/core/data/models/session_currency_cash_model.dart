import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_currency_cash_model.freezed.dart';

@freezed
class SessionCurrencyCashModel with _$SessionCurrencyCashModel {
  const factory SessionCurrencyCashModel({
    required String id,
    required String companyId,
    required String registerSessionId,
    required String currencyId,
    @Default(0) int openingCash,
    int? closingCash,
    int? expectedCash,
    int? difference,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SessionCurrencyCashModel;
}
