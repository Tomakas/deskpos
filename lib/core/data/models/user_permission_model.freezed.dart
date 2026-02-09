// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_permission_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserPermissionModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get permissionId => throw _privateConstructorUsedError;
  String get grantedBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of UserPermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPermissionModelCopyWith<UserPermissionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPermissionModelCopyWith<$Res> {
  factory $UserPermissionModelCopyWith(
    UserPermissionModel value,
    $Res Function(UserPermissionModel) then,
  ) = _$UserPermissionModelCopyWithImpl<$Res, UserPermissionModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String userId,
    String permissionId,
    String grantedBy,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$UserPermissionModelCopyWithImpl<$Res, $Val extends UserPermissionModel>
    implements $UserPermissionModelCopyWith<$Res> {
  _$UserPermissionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? userId = null,
    Object? permissionId = null,
    Object? grantedBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            companyId: null == companyId
                ? _value.companyId
                : companyId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            permissionId: null == permissionId
                ? _value.permissionId
                : permissionId // ignore: cast_nullable_to_non_nullable
                      as String,
            grantedBy: null == grantedBy
                ? _value.grantedBy
                : grantedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserPermissionModelImplCopyWith<$Res>
    implements $UserPermissionModelCopyWith<$Res> {
  factory _$$UserPermissionModelImplCopyWith(
    _$UserPermissionModelImpl value,
    $Res Function(_$UserPermissionModelImpl) then,
  ) = __$$UserPermissionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String userId,
    String permissionId,
    String grantedBy,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$UserPermissionModelImplCopyWithImpl<$Res>
    extends _$UserPermissionModelCopyWithImpl<$Res, _$UserPermissionModelImpl>
    implements _$$UserPermissionModelImplCopyWith<$Res> {
  __$$UserPermissionModelImplCopyWithImpl(
    _$UserPermissionModelImpl _value,
    $Res Function(_$UserPermissionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserPermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? userId = null,
    Object? permissionId = null,
    Object? grantedBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$UserPermissionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        permissionId: null == permissionId
            ? _value.permissionId
            : permissionId // ignore: cast_nullable_to_non_nullable
                  as String,
        grantedBy: null == grantedBy
            ? _value.grantedBy
            : grantedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$UserPermissionModelImpl implements _UserPermissionModel {
  const _$UserPermissionModelImpl({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.permissionId,
    required this.grantedBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String userId;
  @override
  final String permissionId;
  @override
  final String grantedBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'UserPermissionModel(id: $id, companyId: $companyId, userId: $userId, permissionId: $permissionId, grantedBy: $grantedBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPermissionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.permissionId, permissionId) ||
                other.permissionId == permissionId) &&
            (identical(other.grantedBy, grantedBy) ||
                other.grantedBy == grantedBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    companyId,
    userId,
    permissionId,
    grantedBy,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of UserPermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPermissionModelImplCopyWith<_$UserPermissionModelImpl> get copyWith =>
      __$$UserPermissionModelImplCopyWithImpl<_$UserPermissionModelImpl>(
        this,
        _$identity,
      );
}

abstract class _UserPermissionModel implements UserPermissionModel {
  const factory _UserPermissionModel({
    required final String id,
    required final String companyId,
    required final String userId,
    required final String permissionId,
    required final String grantedBy,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$UserPermissionModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get userId;
  @override
  String get permissionId;
  @override
  String get grantedBy;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of UserPermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPermissionModelImplCopyWith<_$UserPermissionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
