import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/prep_status.dart';

part 'order_model.freezed.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String companyId,
    required String billId,
    required String createdByUserId,
    required String orderNumber,
    String? notes,
    required PrepStatus status,
    @Default(0) int itemCount,
    @Default(0) int subtotalGross,
    @Default(0) int subtotalNet,
    @Default(0) int taxTotal,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _OrderModel;
}
