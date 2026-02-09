import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/payment_type.dart';

part 'payment_method_model.freezed.dart';

@freezed
class PaymentMethodModel with _$PaymentMethodModel {
  const factory PaymentMethodModel({
    required String id,
    required String companyId,
    required String name,
    required PaymentType type,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _PaymentMethodModel;
}
