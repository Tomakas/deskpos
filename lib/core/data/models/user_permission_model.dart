import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_permission_model.freezed.dart';

@freezed
abstract class UserPermissionModel with _$UserPermissionModel {
  const factory UserPermissionModel({
    required String id,
    required String companyId,
    required String userId,
    required String permissionId,
    required String grantedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _UserPermissionModel;
}
