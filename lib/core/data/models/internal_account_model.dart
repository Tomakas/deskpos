import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'internal_account_model.freezed.dart';

@freezed
abstract class InternalAccountModel with _$InternalAccountModel implements CompanyScopedModel {
  const factory InternalAccountModel({
    required String id,
    required String companyId,
    required String name,
    String? userId,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _InternalAccountModel;
}
