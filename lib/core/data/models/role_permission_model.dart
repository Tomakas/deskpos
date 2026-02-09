import 'package:freezed_annotation/freezed_annotation.dart';

part 'role_permission_model.freezed.dart';

@freezed
class RolePermissionModel with _$RolePermissionModel {
  const factory RolePermissionModel({
    required String id,
    required String roleId,
    required String permissionId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _RolePermissionModel;
}
