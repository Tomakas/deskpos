import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/company_status.dart';

part 'company_model.freezed.dart';

@freezed
class CompanyModel with _$CompanyModel {
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
    String? businessType,
    required String defaultCurrencyId,
    String? authUserId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CompanyModel;
}
