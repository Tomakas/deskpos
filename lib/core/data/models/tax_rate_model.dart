import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/tax_calc_type.dart';
import 'company_scoped_model.dart';

part 'tax_rate_model.freezed.dart';

@freezed
abstract class TaxRateModel with _$TaxRateModel implements CompanyScopedModel {
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
