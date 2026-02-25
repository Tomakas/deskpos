import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_scoped_model.dart';

part 'modifier_group_model.freezed.dart';

@freezed
abstract class ModifierGroupModel with _$ModifierGroupModel implements CompanyScopedModel {
  const factory ModifierGroupModel({
    required String id,
    required String companyId,
    required String name,
    @Default(0) int minSelections,
    int? maxSelections,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _ModifierGroupModel;
}
