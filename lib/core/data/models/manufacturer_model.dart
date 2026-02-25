import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'manufacturer_model.freezed.dart';

@freezed
abstract class ManufacturerModel with _$ManufacturerModel implements CompanyScopedModel {
  const factory ManufacturerModel({
    required String id,
    required String companyId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _ManufacturerModel;
}
