// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CompanySettingsModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  bool get requirePinOnSwitch => throw _privateConstructorUsedError;
  int? get autoLockTimeoutMinutes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of CompanySettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompanySettingsModelCopyWith<CompanySettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanySettingsModelCopyWith<$Res> {
  factory $CompanySettingsModelCopyWith(
    CompanySettingsModel value,
    $Res Function(CompanySettingsModel) then,
  ) = _$CompanySettingsModelCopyWithImpl<$Res, CompanySettingsModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    bool requirePinOnSwitch,
    int? autoLockTimeoutMinutes,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$CompanySettingsModelCopyWithImpl<
  $Res,
  $Val extends CompanySettingsModel
>
    implements $CompanySettingsModelCopyWith<$Res> {
  _$CompanySettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompanySettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? requirePinOnSwitch = null,
    Object? autoLockTimeoutMinutes = freezed,
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
            requirePinOnSwitch: null == requirePinOnSwitch
                ? _value.requirePinOnSwitch
                : requirePinOnSwitch // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoLockTimeoutMinutes: freezed == autoLockTimeoutMinutes
                ? _value.autoLockTimeoutMinutes
                : autoLockTimeoutMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$CompanySettingsModelImplCopyWith<$Res>
    implements $CompanySettingsModelCopyWith<$Res> {
  factory _$$CompanySettingsModelImplCopyWith(
    _$CompanySettingsModelImpl value,
    $Res Function(_$CompanySettingsModelImpl) then,
  ) = __$$CompanySettingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    bool requirePinOnSwitch,
    int? autoLockTimeoutMinutes,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$CompanySettingsModelImplCopyWithImpl<$Res>
    extends _$CompanySettingsModelCopyWithImpl<$Res, _$CompanySettingsModelImpl>
    implements _$$CompanySettingsModelImplCopyWith<$Res> {
  __$$CompanySettingsModelImplCopyWithImpl(
    _$CompanySettingsModelImpl _value,
    $Res Function(_$CompanySettingsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompanySettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? requirePinOnSwitch = null,
    Object? autoLockTimeoutMinutes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$CompanySettingsModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        requirePinOnSwitch: null == requirePinOnSwitch
            ? _value.requirePinOnSwitch
            : requirePinOnSwitch // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoLockTimeoutMinutes: freezed == autoLockTimeoutMinutes
            ? _value.autoLockTimeoutMinutes
            : autoLockTimeoutMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
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

class _$CompanySettingsModelImpl implements _CompanySettingsModel {
  const _$CompanySettingsModelImpl({
    required this.id,
    required this.companyId,
    this.requirePinOnSwitch = true,
    this.autoLockTimeoutMinutes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  @JsonKey()
  final bool requirePinOnSwitch;
  @override
  final int? autoLockTimeoutMinutes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'CompanySettingsModel(id: $id, companyId: $companyId, requirePinOnSwitch: $requirePinOnSwitch, autoLockTimeoutMinutes: $autoLockTimeoutMinutes, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanySettingsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.requirePinOnSwitch, requirePinOnSwitch) ||
                other.requirePinOnSwitch == requirePinOnSwitch) &&
            (identical(other.autoLockTimeoutMinutes, autoLockTimeoutMinutes) ||
                other.autoLockTimeoutMinutes == autoLockTimeoutMinutes) &&
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
    requirePinOnSwitch,
    autoLockTimeoutMinutes,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of CompanySettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanySettingsModelImplCopyWith<_$CompanySettingsModelImpl>
  get copyWith =>
      __$$CompanySettingsModelImplCopyWithImpl<_$CompanySettingsModelImpl>(
        this,
        _$identity,
      );
}

abstract class _CompanySettingsModel implements CompanySettingsModel {
  const factory _CompanySettingsModel({
    required final String id,
    required final String companyId,
    final bool requirePinOnSwitch,
    final int? autoLockTimeoutMinutes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$CompanySettingsModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  bool get requirePinOnSwitch;
  @override
  int? get autoLockTimeoutMinutes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of CompanySettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompanySettingsModelImplCopyWith<_$CompanySettingsModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
