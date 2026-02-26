import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'section_model.freezed.dart';

@freezed
abstract class SectionModel with _$SectionModel implements CompanyScopedModel {
  const factory SectionModel({
    required String id,
    required String companyId,
    required String name,
    String? color,
    @Default(true) bool isActive,
    @Default(false) bool isDefault,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SectionModel;
}
