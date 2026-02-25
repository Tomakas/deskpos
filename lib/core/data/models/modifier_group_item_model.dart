import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'modifier_group_item_model.freezed.dart';

@freezed
abstract class ModifierGroupItemModel with _$ModifierGroupItemModel implements CompanyScopedModel {
  const factory ModifierGroupItemModel({
    required String id,
    required String companyId,
    required String modifierGroupId,
    required String itemId,
    @Default(0) int sortOrder,
    @Default(false) bool isDefault,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _ModifierGroupItemModel;
}
