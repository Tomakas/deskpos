import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/tax_calc_type.dart';

part 'tax_rate_model.freezed.dart';

@freezed
class TaxRateModel with _$TaxRateModel {
  const factory TaxRateModel({
    required String id,
    required String companyId,
    required String label,
    required TaxCalcType type,
    required int rate,
    @Default(false) bool isDefault,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _TaxRateModel;
}
