import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/layout_item_type.dart';

part 'layout_item_model.freezed.dart';

@freezed
class LayoutItemModel with _$LayoutItemModel {
  const factory LayoutItemModel({
    required String id,
    required String companyId,
    required String registerId,
    @Default(0) int page,
    required int row,
    required int col,
    required LayoutItemType type,
    String? itemId,
    String? categoryId,
    String? label,
    String? color,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _LayoutItemModel;
}
