import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String companyId,
    String? authUserId,
    required String username,
    required String fullName,
    String? email,
    String? phone,
    required String pinHash,
    @Default(true) bool pinEnabled,
    required String roleId,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _UserModel;
}
