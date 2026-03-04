import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ai_provider_type.dart';
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
    @Default(2000) int maxItemDiscountPercent,
    @Default(2000) int maxBillDiscountPercent,
    // TODO: Add UI for editing these thresholds in company settings screen.
    @Default(15) int billAgeWarningMinutes,
    @Default(30) int billAgeDangerMinutes,
    @Default(45) int billAgeCriticalMinutes,
    // AI assistant
    @Default(false) bool aiEnabled,
    @Default(AiProviderType.none) AiProviderType aiProviderType,
    String? aiModel,
    @Default(60) int aiRateLimitPerHour,
    @Default(4096) int aiMaxTokensPerRequest,
    @Default(16000) int aiMaxConversationTokens,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CompanySettingsModel;
}
