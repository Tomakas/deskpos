import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/prep_area.dart';
import 'company_scoped_model.dart';

part 'category_model.freezed.dart';

@freezed
abstract class CategoryModel with _$CategoryModel implements CompanyScopedModel {
  const factory CategoryModel({
    required String id,
    required String companyId,
    required String name,
    @Default(true) bool isActive,
    String? parentId,
    PrepArea? prepArea,
    String? defaultSaleTaxRateId,
    String? defaultPurchaseTaxRateId,
    bool? defaultIsSellable,
    String? color,
    String? itemColor,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CategoryModel;
}
