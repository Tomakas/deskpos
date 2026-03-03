import 'dart:convert';

import '../../../core/data/repositories/company_settings_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

/// Handles company settings AI tool calls.
///
/// IMPORTANT: Only allows updating safe fields — NOT aiProviderType,
/// aiModel, or security settings (requirePinOnSwitch, autoLockTimeoutMinutes).
class AiCompanyToolHandler {
  AiCompanyToolHandler({
    required CompanySettingsRepository companySettingsRepo,
  }) : _companySettingsRepo = companySettingsRepo;

  final CompanySettingsRepository _companySettingsRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        'get_company_settings' => _getCompanySettings(companyId),
        'update_company_settings' => _updateCompanySettings(args, companyId),
        _ => AiCommandError('Unknown company tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Company tool handler error', tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  Future<AiCommandResult> _getCompanySettings(String companyId) async {
    final settings = await _companySettingsRepo.getByCompany(companyId);
    if (settings == null) {
      return const AiCommandError('Company settings not found');
    }
    return AiCommandSuccess(jsonEncode({
      'id': settings.id,
      'locale': settings.locale,
      'loyalty_earn_rate': settings.loyaltyEarnRate,
      'loyalty_point_value': settings.loyaltyPointValue,
      'max_item_discount_percent': settings.maxItemDiscountPercent,
      'max_bill_discount_percent': settings.maxBillDiscountPercent,
      'bill_age_warning_minutes': settings.billAgeWarningMinutes,
      'bill_age_danger_minutes': settings.billAgeDangerMinutes,
      'bill_age_critical_minutes': settings.billAgeCriticalMinutes,
      'negative_stock_policy': settings.negativeStockPolicy.name,
      // AI and security settings intentionally omitted
    }));
  }

  Future<AiCommandResult> _updateCompanySettings(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final existing = await _companySettingsRepo.getByCompany(companyId);
    if (existing == null) {
      return const AiCommandError('Company settings not found');
    }

    final updated = existing.copyWith(
      locale: args['locale'] as String? ?? existing.locale,
      loyaltyEarnRate:
          (args['loyalty_earn_rate'] as num?)?.toInt() ?? existing.loyaltyEarnRate,
      loyaltyPointValue:
          (args['loyalty_point_value'] as num?)?.toInt() ?? existing.loyaltyPointValue,
      maxItemDiscountPercent: (args['max_item_discount_percent'] as num?)?.toInt() ??
          existing.maxItemDiscountPercent,
      maxBillDiscountPercent: (args['max_bill_discount_percent'] as num?)?.toInt() ??
          existing.maxBillDiscountPercent,
      billAgeWarningMinutes: (args['bill_age_warning_minutes'] as num?)?.toInt() ??
          existing.billAgeWarningMinutes,
      billAgeDangerMinutes: (args['bill_age_danger_minutes'] as num?)?.toInt() ??
          existing.billAgeDangerMinutes,
      billAgeCriticalMinutes: (args['bill_age_critical_minutes'] as num?)?.toInt() ??
          existing.billAgeCriticalMinutes,
      updatedAt: DateTime.now(),
    );
    final result = await _companySettingsRepo.update(updated);
    return switch (result) {
      Success() =>
        AiCommandSuccess('Company settings updated', entityId: existing.id),
      Failure(:final message) => AiCommandError(message),
    };
  }
}
