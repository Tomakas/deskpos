// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'warehouse_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WarehouseModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of WarehouseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WarehouseModelCopyWith<WarehouseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WarehouseModelCopyWith<$Res> {
  factory $WarehouseModelCopyWith(
    WarehouseModel value,
    $Res Function(WarehouseModel) then,
  ) = _$WarehouseModelCopyWithImpl<$Res, WarehouseModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    bool isDefault,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$WarehouseModelCopyWithImpl<$Res, $Val extends WarehouseModel>
    implements $WarehouseModelCopyWith<$Res> {
  _$WarehouseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WarehouseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? isDefault = null,
    Object? isActive = null,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$WarehouseModelImplCopyWith<$Res>
    implements $WarehouseModelCopyWith<$Res> {
  factory _$$WarehouseModelImplCopyWith(
    _$WarehouseModelImpl value,
    $Res Function(_$WarehouseModelImpl) then,
  ) = __$$WarehouseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    bool isDefault,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$WarehouseModelImplCopyWithImpl<$Res>
    extends _$WarehouseModelCopyWithImpl<$Res, _$WarehouseModelImpl>
    implements _$$WarehouseModelImplCopyWith<$Res> {
  __$$WarehouseModelImplCopyWithImpl(
    _$WarehouseModelImpl _value,
    $Res Function(_$WarehouseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WarehouseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? isDefault = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$WarehouseModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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

class _$WarehouseModelImpl implements _WarehouseModel {
  const _$WarehouseModelImpl({
    required this.id,
    required this.companyId,
    required this.name,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String name;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'WarehouseModel(id: $id, companyId: $companyId, name: $name, isDefault: $isDefault, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WarehouseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
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
    name,
    isDefault,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of WarehouseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WarehouseModelImplCopyWith<_$WarehouseModelImpl> get copyWith =>
      __$$WarehouseModelImplCopyWithImpl<_$WarehouseModelImpl>(
        this,
        _$identity,
      );
}

abstract class _WarehouseModel implements WarehouseModel {
  const factory _WarehouseModel({
    required final String id,
    required final String companyId,
    required final String name,
    final bool isDefault,
    final bool isActive,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$WarehouseModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get name;
  @override
  bool get isDefault;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of WarehouseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WarehouseModelImplCopyWith<_$WarehouseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
