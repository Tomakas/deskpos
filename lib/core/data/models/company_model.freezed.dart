// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CompanyModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  CompanyStatus get status => throw _privateConstructorUsedError;
  String? get businessId => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get vatNumber => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get postalCode => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;
  String? get businessType => throw _privateConstructorUsedError;
  String get defaultCurrencyId => throw _privateConstructorUsedError;
  String get authUserId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of CompanyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompanyModelCopyWith<CompanyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyModelCopyWith<$Res> {
  factory $CompanyModelCopyWith(
    CompanyModel value,
    $Res Function(CompanyModel) then,
  ) = _$CompanyModelCopyWithImpl<$Res, CompanyModel>;
  @useResult
  $Res call({
    String id,
    String name,
    CompanyStatus status,
    String? businessId,
    String? address,
    String? phone,
    String? email,
    String? vatNumber,
    String? country,
    String? city,
    String? postalCode,
    String? timezone,
    String? businessType,
    String defaultCurrencyId,
    String authUserId,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$CompanyModelCopyWithImpl<$Res, $Val extends CompanyModel>
    implements $CompanyModelCopyWith<$Res> {
  _$CompanyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompanyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? businessId = freezed,
    Object? address = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? vatNumber = freezed,
    Object? country = freezed,
    Object? city = freezed,
    Object? postalCode = freezed,
    Object? timezone = freezed,
    Object? businessType = freezed,
    Object? defaultCurrencyId = null,
    Object? authUserId = null,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CompanyStatus,
            businessId: freezed == businessId
                ? _value.businessId
                : businessId // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            vatNumber: freezed == vatNumber
                ? _value.vatNumber
                : vatNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            postalCode: freezed == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            timezone: freezed == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String?,
            businessType: freezed == businessType
                ? _value.businessType
                : businessType // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultCurrencyId: null == defaultCurrencyId
                ? _value.defaultCurrencyId
                : defaultCurrencyId // ignore: cast_nullable_to_non_nullable
                      as String,
            authUserId: null == authUserId
                ? _value.authUserId
                : authUserId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CompanyModelImplCopyWith<$Res>
    implements $CompanyModelCopyWith<$Res> {
  factory _$$CompanyModelImplCopyWith(
    _$CompanyModelImpl value,
    $Res Function(_$CompanyModelImpl) then,
  ) = __$$CompanyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    CompanyStatus status,
    String? businessId,
    String? address,
    String? phone,
    String? email,
    String? vatNumber,
    String? country,
    String? city,
    String? postalCode,
    String? timezone,
    String? businessType,
    String defaultCurrencyId,
    String authUserId,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$CompanyModelImplCopyWithImpl<$Res>
    extends _$CompanyModelCopyWithImpl<$Res, _$CompanyModelImpl>
    implements _$$CompanyModelImplCopyWith<$Res> {
  __$$CompanyModelImplCopyWithImpl(
    _$CompanyModelImpl _value,
    $Res Function(_$CompanyModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompanyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? businessId = freezed,
    Object? address = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? vatNumber = freezed,
    Object? country = freezed,
    Object? city = freezed,
    Object? postalCode = freezed,
    Object? timezone = freezed,
    Object? businessType = freezed,
    Object? defaultCurrencyId = null,
    Object? authUserId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$CompanyModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CompanyStatus,
        businessId: freezed == businessId
            ? _value.businessId
            : businessId // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        vatNumber: freezed == vatNumber
            ? _value.vatNumber
            : vatNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        postalCode: freezed == postalCode
            ? _value.postalCode
            : postalCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        timezone: freezed == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String?,
        businessType: freezed == businessType
            ? _value.businessType
            : businessType // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultCurrencyId: null == defaultCurrencyId
            ? _value.defaultCurrencyId
            : defaultCurrencyId // ignore: cast_nullable_to_non_nullable
                  as String,
        authUserId: null == authUserId
            ? _value.authUserId
            : authUserId // ignore: cast_nullable_to_non_nullable
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

class _$CompanyModelImpl implements _CompanyModel {
  const _$CompanyModelImpl({
    required this.id,
    required this.name,
    required this.status,
    this.businessId,
    this.address,
    this.phone,
    this.email,
    this.vatNumber,
    this.country,
    this.city,
    this.postalCode,
    this.timezone,
    this.businessType,
    required this.defaultCurrencyId,
    required this.authUserId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final CompanyStatus status;
  @override
  final String? businessId;
  @override
  final String? address;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? vatNumber;
  @override
  final String? country;
  @override
  final String? city;
  @override
  final String? postalCode;
  @override
  final String? timezone;
  @override
  final String? businessType;
  @override
  final String defaultCurrencyId;
  @override
  final String authUserId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'CompanyModel(id: $id, name: $name, status: $status, businessId: $businessId, address: $address, phone: $phone, email: $email, vatNumber: $vatNumber, country: $country, city: $city, postalCode: $postalCode, timezone: $timezone, businessType: $businessType, defaultCurrencyId: $defaultCurrencyId, authUserId: $authUserId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.businessId, businessId) ||
                other.businessId == businessId) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.vatNumber, vatNumber) ||
                other.vatNumber == vatNumber) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.businessType, businessType) ||
                other.businessType == businessType) &&
            (identical(other.defaultCurrencyId, defaultCurrencyId) ||
                other.defaultCurrencyId == defaultCurrencyId) &&
            (identical(other.authUserId, authUserId) ||
                other.authUserId == authUserId) &&
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
    name,
    status,
    businessId,
    address,
    phone,
    email,
    vatNumber,
    country,
    city,
    postalCode,
    timezone,
    businessType,
    defaultCurrencyId,
    authUserId,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of CompanyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyModelImplCopyWith<_$CompanyModelImpl> get copyWith =>
      __$$CompanyModelImplCopyWithImpl<_$CompanyModelImpl>(this, _$identity);
}

abstract class _CompanyModel implements CompanyModel {
  const factory _CompanyModel({
    required final String id,
    required final String name,
    required final CompanyStatus status,
    final String? businessId,
    final String? address,
    final String? phone,
    final String? email,
    final String? vatNumber,
    final String? country,
    final String? city,
    final String? postalCode,
    final String? timezone,
    final String? businessType,
    required final String defaultCurrencyId,
    required final String authUserId,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$CompanyModelImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  CompanyStatus get status;
  @override
  String? get businessId;
  @override
  String? get address;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get vatNumber;
  @override
  String? get country;
  @override
  String? get city;
  @override
  String? get postalCode;
  @override
  String? get timezone;
  @override
  String? get businessType;
  @override
  String get defaultCurrencyId;
  @override
  String get authUserId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of CompanyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompanyModelImplCopyWith<_$CompanyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
