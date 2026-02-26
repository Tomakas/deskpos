import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/negative_stock_policy.dart';
import 'company_scoped_model.dart';

part 'company_settings_model.freezed.dart';

@freezed
abstract class CompanySettingsModel with _$CompanySettingsModel implements CompanyScopedModel {
  const factory CompanySettingsModel({
    required String id,
    required String companyId,
    @Default(true) bool requirePinOnSwitch,
    int? autoLockTimeoutMinutes,
    @Default(0) int loyaltyEarnRate,
    @Default(0) int loyaltyPointValue,
    @Default('cs') String locale,
    @Default(NegativeStockPolicy.allow) NegativeStockPolicy negativeStockPolicy,
    // TODO: Add UI for editing these thresholds in company settings screen.
    @Default(15) int billAgeWarningMinutes,
    @Default(30) int billAgeDangerMinutes,
    @Default(45) int billAgeCriticalMinutes,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CompanySettingsModel;
}
