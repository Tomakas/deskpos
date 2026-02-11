import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/table_shape.dart';
import 'company_scoped_model.dart';

part 'table_model.freezed.dart';

@freezed
class TableModel with _$TableModel implements CompanyScopedModel {
  const factory TableModel({
    required String id,
    required String companyId,
    String? sectionId,
    required String name,
    @Default(0) int capacity,
    @Default(true) bool isActive,
    @Default(0) int gridRow,
    @Default(0) int gridCol,
    @Default(1) int gridWidth,
    @Default(1) int gridHeight,
    @Default(TableShape.rectangle) TableShape shape,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _TableModel;
}
