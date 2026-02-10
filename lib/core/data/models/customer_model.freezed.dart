// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CustomerModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get credit => throw _privateConstructorUsedError;
  int get totalSpent => throw _privateConstructorUsedError;
  DateTime? get lastVisitDate => throw _privateConstructorUsedError;
  DateTime? get birthdate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of CustomerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerModelCopyWith<CustomerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerModelCopyWith<$Res> {
  factory $CustomerModelCopyWith(
    CustomerModel value,
    $Res Function(CustomerModel) then,
  ) = _$CustomerModelCopyWithImpl<$Res, CustomerModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String firstName,
    String lastName,
    String? email,
    String? phone,
    String? address,
    int points,
    int credit,
    int totalSpent,
    DateTime? lastVisitDate,
    DateTime? birthdate,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$CustomerModelCopyWithImpl<$Res, $Val extends CustomerModel>
    implements $CustomerModelCopyWith<$Res> {
  _$CustomerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? points = null,
    Object? credit = null,
    Object? totalSpent = null,
    Object? lastVisitDate = freezed,
    Object? birthdate = freezed,
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
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            credit: null == credit
                ? _value.credit
                : credit // ignore: cast_nullable_to_non_nullable
                      as int,
            totalSpent: null == totalSpent
                ? _value.totalSpent
                : totalSpent // ignore: cast_nullable_to_non_nullable
                      as int,
            lastVisitDate: freezed == lastVisitDate
                ? _value.lastVisitDate
                : lastVisitDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            birthdate: freezed == birthdate
                ? _value.birthdate
                : birthdate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$CustomerModelImplCopyWith<$Res>
    implements $CustomerModelCopyWith<$Res> {
  factory _$$CustomerModelImplCopyWith(
    _$CustomerModelImpl value,
    $Res Function(_$CustomerModelImpl) then,
  ) = __$$CustomerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String firstName,
    String lastName,
    String? email,
    String? phone,
    String? address,
    int points,
    int credit,
    int totalSpent,
    DateTime? lastVisitDate,
    DateTime? birthdate,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$CustomerModelImplCopyWithImpl<$Res>
    extends _$CustomerModelCopyWithImpl<$Res, _$CustomerModelImpl>
    implements _$$CustomerModelImplCopyWith<$Res> {
  __$$CustomerModelImplCopyWithImpl(
    _$CustomerModelImpl _value,
    $Res Function(_$CustomerModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? points = null,
    Object? credit = null,
    Object? totalSpent = null,
    Object? lastVisitDate = freezed,
    Object? birthdate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$CustomerModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        credit: null == credit
            ? _value.credit
            : credit // ignore: cast_nullable_to_non_nullable
                  as int,
        totalSpent: null == totalSpent
            ? _value.totalSpent
            : totalSpent // ignore: cast_nullable_to_non_nullable
                  as int,
        lastVisitDate: freezed == lastVisitDate
            ? _value.lastVisitDate
            : lastVisitDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        birthdate: freezed == birthdate
            ? _value.birthdate
            : birthdate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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

class _$CustomerModelImpl implements _CustomerModel {
  const _$CustomerModelImpl({
    required this.id,
    required this.companyId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.address,
    this.points = 0,
    this.credit = 0,
    this.totalSpent = 0,
    this.lastVisitDate,
    this.birthdate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? address;
  @override
  @JsonKey()
  final int points;
  @override
  @JsonKey()
  final int credit;
  @override
  @JsonKey()
  final int totalSpent;
  @override
  final DateTime? lastVisitDate;
  @override
  final DateTime? birthdate;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'CustomerModel(id: $id, companyId: $companyId, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, address: $address, points: $points, credit: $credit, totalSpent: $totalSpent, lastVisitDate: $lastVisitDate, birthdate: $birthdate, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.credit, credit) || other.credit == credit) &&
            (identical(other.totalSpent, totalSpent) ||
                other.totalSpent == totalSpent) &&
            (identical(other.lastVisitDate, lastVisitDate) ||
                other.lastVisitDate == lastVisitDate) &&
            (identical(other.birthdate, birthdate) ||
                other.birthdate == birthdate) &&
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
    firstName,
    lastName,
    email,
    phone,
    address,
    points,
    credit,
    totalSpent,
    lastVisitDate,
    birthdate,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of CustomerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerModelImplCopyWith<_$CustomerModelImpl> get copyWith =>
      __$$CustomerModelImplCopyWithImpl<_$CustomerModelImpl>(this, _$identity);
}

abstract class _CustomerModel implements CustomerModel {
  const factory _CustomerModel({
    required final String id,
    required final String companyId,
    required final String firstName,
    required final String lastName,
    final String? email,
    final String? phone,
    final String? address,
    final int points,
    final int credit,
    final int totalSpent,
    final DateTime? lastVisitDate,
    final DateTime? birthdate,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$CustomerModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get address;
  @override
  int get points;
  @override
  int get credit;
  @override
  int get totalSpent;
  @override
  DateTime? get lastVisitDate;
  @override
  DateTime? get birthdate;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of CustomerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerModelImplCopyWith<_$CustomerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
