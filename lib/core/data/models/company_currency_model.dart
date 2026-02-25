import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'company_currency_model.freezed.dart';

@freezed
abstract class CompanyCurrencyModel with _$CompanyCurrencyModel implements CompanyScopedModel {
  const factory CompanyCurrencyModel({
    required String id,
    required String companyId,
    required String currencyId,
    required double exchangeRate,
    @Default(true) bool isActive,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CompanyCurrencyModel;
}
