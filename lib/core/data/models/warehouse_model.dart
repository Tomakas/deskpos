import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'warehouse_model.freezed.dart';

@freezed
class WarehouseModel with _$WarehouseModel implements CompanyScopedModel {
  const factory WarehouseModel({
    required String id,
    required String companyId,
    required String name,
    @Default(false) bool isDefault,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _WarehouseModel;
}
