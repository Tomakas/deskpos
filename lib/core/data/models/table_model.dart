import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_model.freezed.dart';

@freezed
class TableModel with _$TableModel {
  const factory TableModel({
    required String id,
    required String companyId,
    String? sectionId,
    required String name,
    @Default(0) int capacity,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _TableModel;
}
