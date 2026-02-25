import 'package:freezed_annotation/freezed_annotation.dart';

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
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CompanySettingsModel;
}
