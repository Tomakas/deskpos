import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'product_recipe_model.freezed.dart';

@freezed
abstract class ProductRecipeModel with _$ProductRecipeModel implements CompanyScopedModel {
  const factory ProductRecipeModel({
    required String id,
    required String companyId,
    required String parentProductId,
    required String componentProductId,
    required double quantityRequired,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _ProductRecipeModel;
}
