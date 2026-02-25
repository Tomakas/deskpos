import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'item_modifier_group_model.freezed.dart';

@freezed
abstract class ItemModifierGroupModel with _$ItemModifierGroupModel implements CompanyScopedModel {
  const factory ItemModifierGroupModel({
    required String id,
    required String companyId,
    required String itemId,
    required String modifierGroupId,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _ItemModifierGroupModel;
}
