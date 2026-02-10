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
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CompanySettingsModel;
}
