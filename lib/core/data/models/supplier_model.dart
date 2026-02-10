import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'supplier_model.freezed.dart';

@freezed
class SupplierModel with _$SupplierModel implements CompanyScopedModel {
  const factory SupplierModel({
    required String id,
    required String companyId,
    required String supplierName,
    String? contactPerson,
    String? email,
    String? phone,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SupplierModel;
}
