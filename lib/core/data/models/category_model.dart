import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'category_model.freezed.dart';

@freezed
class CategoryModel with _$CategoryModel implements CompanyScopedModel {
  const factory CategoryModel({
    required String id,
    required String companyId,
    required String name,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CategoryModel;
}
