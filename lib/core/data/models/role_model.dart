import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/role_name.dart';

part 'role_model.freezed.dart';

@freezed
abstract class RoleModel with _$RoleModel {
  const factory RoleModel({
    required String id,
    required RoleName name,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _RoleModel;
}
