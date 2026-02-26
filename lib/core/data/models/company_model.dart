import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/business_type.dart';
import '../enums/company_status.dart';

part 'company_model.freezed.dart';

@freezed
abstract class CompanyModel with _$CompanyModel {
  const factory CompanyModel({
    required String id,
    required String name,
    required CompanyStatus status,
    String? businessId,
    String? address,
    String? phone,
    String? email,
    String? vatNumber,
    String? country,
    String? city,
    String? postalCode,
    String? timezone,
    BusinessType? businessType,
    required String defaultCurrencyId,
    required String authUserId,
    @Default(false) bool isDemo,
    DateTime? demoExpiresAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CompanyModel;
}
