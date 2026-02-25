import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission_model.freezed.dart';

@freezed
abstract class PermissionModel with _$PermissionModel {
  const factory PermissionModel({
    required String id,
    required String code,
    required String name,
    String? description,
    required String category,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _PermissionModel;
}
