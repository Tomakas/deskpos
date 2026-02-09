import 'package:freezed_annotation/freezed_annotation.dart';

part 'section_model.freezed.dart';

@freezed
class SectionModel with _$SectionModel {
  const factory SectionModel({
    required String id,
    required String companyId,
    required String name,
    String? color,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SectionModel;
}
