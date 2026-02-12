// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_registration_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DeviceRegistrationModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get registerId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of DeviceRegistrationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceRegistrationModelCopyWith<DeviceRegistrationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceRegistrationModelCopyWith<$Res> {
  factory $DeviceRegistrationModelCopyWith(
    DeviceRegistrationModel value,
    $Res Function(DeviceRegistrationModel) then,
  ) = _$DeviceRegistrationModelCopyWithImpl<$Res, DeviceRegistrationModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String registerId,
    DateTime createdAt,
  });
}

/// @nodoc
class _$DeviceRegistrationModelCopyWithImpl<
  $Res,
  $Val extends DeviceRegistrationModel
>
    implements $DeviceRegistrationModelCopyWith<$Res> {
  _$DeviceRegistrationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceRegistrationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? registerId = null,
    Object? createdAt = null,
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
            registerId: null == registerId
                ? _value.registerId
                : registerId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceRegistrationModelImplCopyWith<$Res>
    implements $DeviceRegistrationModelCopyWith<$Res> {
  factory _$$DeviceRegistrationModelImplCopyWith(
    _$DeviceRegistrationModelImpl value,
    $Res Function(_$DeviceRegistrationModelImpl) then,
  ) = __$$DeviceRegistrationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String registerId,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$DeviceRegistrationModelImplCopyWithImpl<$Res>
    extends
        _$DeviceRegistrationModelCopyWithImpl<
          $Res,
          _$DeviceRegistrationModelImpl
        >
    implements _$$DeviceRegistrationModelImplCopyWith<$Res> {
  __$$DeviceRegistrationModelImplCopyWithImpl(
    _$DeviceRegistrationModelImpl _value,
    $Res Function(_$DeviceRegistrationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceRegistrationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? registerId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$DeviceRegistrationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        registerId: null == registerId
            ? _value.registerId
            : registerId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$DeviceRegistrationModelImpl implements _DeviceRegistrationModel {
  const _$DeviceRegistrationModelImpl({
    required this.id,
    required this.companyId,
    required this.registerId,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String registerId;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'DeviceRegistrationModel(id: $id, companyId: $companyId, registerId: $registerId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceRegistrationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.registerId, registerId) ||
                other.registerId == registerId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, companyId, registerId, createdAt);

  /// Create a copy of DeviceRegistrationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceRegistrationModelImplCopyWith<_$DeviceRegistrationModelImpl>
  get copyWith =>
      __$$DeviceRegistrationModelImplCopyWithImpl<
        _$DeviceRegistrationModelImpl
      >(this, _$identity);
}

abstract class _DeviceRegistrationModel implements DeviceRegistrationModel {
  const factory _DeviceRegistrationModel({
    required final String id,
    required final String companyId,
    required final String registerId,
    required final DateTime createdAt,
  }) = _$DeviceRegistrationModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get registerId;
  @override
  DateTime get createdAt;

  /// Create a copy of DeviceRegistrationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceRegistrationModelImplCopyWith<_$DeviceRegistrationModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
