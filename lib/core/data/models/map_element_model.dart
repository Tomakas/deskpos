import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/table_shape.dart';
import 'company_scoped_model.dart';

part 'map_element_model.freezed.dart';

@freezed
class MapElementModel with _$MapElementModel implements CompanyScopedModel {
  const factory MapElementModel({
    required String id,
    required String companyId,
    String? sectionId,
    @Default(0) int gridRow,
    @Default(0) int gridCol,
    @Default(2) int gridWidth,
    @Default(2) int gridHeight,
    String? label,
    String? color,
    int? fontSize,
    @Default(1) int fillStyle,
    @Default(1) int borderStyle,
    @Default(TableShape.rectangle) TableShape shape,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _MapElementModel;
}
