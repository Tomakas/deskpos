import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'company_settings_model.freezed.dart';

@freezed
class CompanySettingsModel with _$CompanySettingsModel implements CompanyScopedModel {
  const factory CompanySettingsModel({
    required String id,
    required String companyId,
    @Default(true) bool requirePinOnSwitch,
    int? autoLockTimeoutMinutes,
    @Default(0) int loyaltyEarnPerHundredCzk,
    @Default(0) int loyaltyPointValueHalere,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CompanySettingsModel;
}
