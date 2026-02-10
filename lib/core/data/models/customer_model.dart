import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'customer_model.freezed.dart';

@freezed
class CustomerModel with _$CustomerModel implements CompanyScopedModel {
  const factory CustomerModel({
    required String id,
    required String companyId,
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    String? address,
    @Default(0) int points,
    @Default(0) int credit,
    @Default(0) int totalSpent,
    DateTime? lastVisitDate,
    DateTime? birthdate,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CustomerModel;
}
