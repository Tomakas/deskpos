// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RegisterSessionModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get registerId => throw _privateConstructorUsedError;
  String get openedByUserId => throw _privateConstructorUsedError;
  DateTime get openedAt => throw _privateConstructorUsedError;
  DateTime? get closedAt => throw _privateConstructorUsedError;
  int get orderCounter => throw _privateConstructorUsedError;
  int get billCounter => throw _privateConstructorUsedError;
  String? get parentSessionId => throw _privateConstructorUsedError;
  int? get openingCash => throw _privateConstructorUsedError;
  int? get closingCash => throw _privateConstructorUsedError;
  int? get expectedCash => throw _privateConstructorUsedError;
  int? get difference => throw _privateConstructorUsedError;
  int? get openBillsAtOpenCount => throw _privateConstructorUsedError;
  int? get openBillsAtOpenAmount => throw _privateConstructorUsedError;
  int? get openBillsAtCloseCount => throw _privateConstructorUsedError;
  int? get openBillsAtCloseAmount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of RegisterSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterSessionModelCopyWith<RegisterSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterSessionModelCopyWith<$Res> {
  factory $RegisterSessionModelCopyWith(
    RegisterSessionModel value,
    $Res Function(RegisterSessionModel) then,
  ) = _$RegisterSessionModelCopyWithImpl<$Res, RegisterSessionModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String registerId,
    String openedByUserId,
    DateTime openedAt,
    DateTime? closedAt,
    int orderCounter,
    int billCounter,
    String? parentSessionId,
    int? openingCash,
    int? closingCash,
    int? expectedCash,
    int? difference,
    int? openBillsAtOpenCount,
    int? openBillsAtOpenAmount,
    int? openBillsAtCloseCount,
    int? openBillsAtCloseAmount,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$RegisterSessionModelCopyWithImpl<
  $Res,
  $Val extends RegisterSessionModel
>
    implements $RegisterSessionModelCopyWith<$Res> {
  _$RegisterSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? registerId = null,
    Object? openedByUserId = null,
    Object? openedAt = null,
    Object? closedAt = freezed,
    Object? orderCounter = null,
    Object? billCounter = null,
    Object? parentSessionId = freezed,
    Object? openingCash = freezed,
    Object? closingCash = freezed,
    Object? expectedCash = freezed,
    Object? difference = freezed,
    Object? openBillsAtOpenCount = freezed,
    Object? openBillsAtOpenAmount = freezed,
    Object? openBillsAtCloseCount = freezed,
    Object? openBillsAtCloseAmount = freezed,
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
            registerId: null == registerId
                ? _value.registerId
                : registerId // ignore: cast_nullable_to_non_nullable
                      as String,
            openedByUserId: null == openedByUserId
                ? _value.openedByUserId
                : openedByUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            openedAt: null == openedAt
                ? _value.openedAt
                : openedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            closedAt: freezed == closedAt
                ? _value.closedAt
                : closedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            orderCounter: null == orderCounter
                ? _value.orderCounter
                : orderCounter // ignore: cast_nullable_to_non_nullable
                      as int,
            billCounter: null == billCounter
                ? _value.billCounter
                : billCounter // ignore: cast_nullable_to_non_nullable
                      as int,
            parentSessionId: freezed == parentSessionId
                ? _value.parentSessionId
                : parentSessionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            openingCash: freezed == openingCash
                ? _value.openingCash
                : openingCash // ignore: cast_nullable_to_non_nullable
                      as int?,
            closingCash: freezed == closingCash
                ? _value.closingCash
                : closingCash // ignore: cast_nullable_to_non_nullable
                      as int?,
            expectedCash: freezed == expectedCash
                ? _value.expectedCash
                : expectedCash // ignore: cast_nullable_to_non_nullable
                      as int?,
            difference: freezed == difference
                ? _value.difference
                : difference // ignore: cast_nullable_to_non_nullable
                      as int?,
            openBillsAtOpenCount: freezed == openBillsAtOpenCount
                ? _value.openBillsAtOpenCount
                : openBillsAtOpenCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            openBillsAtOpenAmount: freezed == openBillsAtOpenAmount
                ? _value.openBillsAtOpenAmount
                : openBillsAtOpenAmount // ignore: cast_nullable_to_non_nullable
                      as int?,
            openBillsAtCloseCount: freezed == openBillsAtCloseCount
                ? _value.openBillsAtCloseCount
                : openBillsAtCloseCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            openBillsAtCloseAmount: freezed == openBillsAtCloseAmount
                ? _value.openBillsAtCloseAmount
                : openBillsAtCloseAmount // ignore: cast_nullable_to_non_nullable
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
abstract class _$$RegisterSessionModelImplCopyWith<$Res>
    implements $RegisterSessionModelCopyWith<$Res> {
  factory _$$RegisterSessionModelImplCopyWith(
    _$RegisterSessionModelImpl value,
    $Res Function(_$RegisterSessionModelImpl) then,
  ) = __$$RegisterSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String registerId,
    String openedByUserId,
    DateTime openedAt,
    DateTime? closedAt,
    int orderCounter,
    int billCounter,
    String? parentSessionId,
    int? openingCash,
    int? closingCash,
    int? expectedCash,
    int? difference,
    int? openBillsAtOpenCount,
    int? openBillsAtOpenAmount,
    int? openBillsAtCloseCount,
    int? openBillsAtCloseAmount,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$RegisterSessionModelImplCopyWithImpl<$Res>
    extends _$RegisterSessionModelCopyWithImpl<$Res, _$RegisterSessionModelImpl>
    implements _$$RegisterSessionModelImplCopyWith<$Res> {
  __$$RegisterSessionModelImplCopyWithImpl(
    _$RegisterSessionModelImpl _value,
    $Res Function(_$RegisterSessionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegisterSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? registerId = null,
    Object? openedByUserId = null,
    Object? openedAt = null,
    Object? closedAt = freezed,
    Object? orderCounter = null,
    Object? billCounter = null,
    Object? parentSessionId = freezed,
    Object? openingCash = freezed,
    Object? closingCash = freezed,
    Object? expectedCash = freezed,
    Object? difference = freezed,
    Object? openBillsAtOpenCount = freezed,
    Object? openBillsAtOpenAmount = freezed,
    Object? openBillsAtCloseCount = freezed,
    Object? openBillsAtCloseAmount = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$RegisterSessionModelImpl(
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
        openedByUserId: null == openedByUserId
            ? _value.openedByUserId
            : openedByUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        openedAt: null == openedAt
            ? _value.openedAt
            : openedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        closedAt: freezed == closedAt
            ? _value.closedAt
            : closedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        orderCounter: null == orderCounter
            ? _value.orderCounter
            : orderCounter // ignore: cast_nullable_to_non_nullable
                  as int,
        billCounter: null == billCounter
            ? _value.billCounter
            : billCounter // ignore: cast_nullable_to_non_nullable
                  as int,
        parentSessionId: freezed == parentSessionId
            ? _value.parentSessionId
            : parentSessionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        openingCash: freezed == openingCash
            ? _value.openingCash
            : openingCash // ignore: cast_nullable_to_non_nullable
                  as int?,
        closingCash: freezed == closingCash
            ? _value.closingCash
            : closingCash // ignore: cast_nullable_to_non_nullable
                  as int?,
        expectedCash: freezed == expectedCash
            ? _value.expectedCash
            : expectedCash // ignore: cast_nullable_to_non_nullable
                  as int?,
        difference: freezed == difference
            ? _value.difference
            : difference // ignore: cast_nullable_to_non_nullable
                  as int?,
        openBillsAtOpenCount: freezed == openBillsAtOpenCount
            ? _value.openBillsAtOpenCount
            : openBillsAtOpenCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        openBillsAtOpenAmount: freezed == openBillsAtOpenAmount
            ? _value.openBillsAtOpenAmount
            : openBillsAtOpenAmount // ignore: cast_nullable_to_non_nullable
                  as int?,
        openBillsAtCloseCount: freezed == openBillsAtCloseCount
            ? _value.openBillsAtCloseCount
            : openBillsAtCloseCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        openBillsAtCloseAmount: freezed == openBillsAtCloseAmount
            ? _value.openBillsAtCloseAmount
            : openBillsAtCloseAmount // ignore: cast_nullable_to_non_nullable
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

class _$RegisterSessionModelImpl implements _RegisterSessionModel {
  const _$RegisterSessionModelImpl({
    required this.id,
    required this.companyId,
    required this.registerId,
    required this.openedByUserId,
    required this.openedAt,
    this.closedAt,
    this.orderCounter = 0,
    this.billCounter = 0,
    this.parentSessionId,
    this.openingCash,
    this.closingCash,
    this.expectedCash,
    this.difference,
    this.openBillsAtOpenCount,
    this.openBillsAtOpenAmount,
    this.openBillsAtCloseCount,
    this.openBillsAtCloseAmount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String registerId;
  @override
  final String openedByUserId;
  @override
  final DateTime openedAt;
  @override
  final DateTime? closedAt;
  @override
  @JsonKey()
  final int orderCounter;
  @override
  @JsonKey()
  final int billCounter;
  @override
  final String? parentSessionId;
  @override
  final int? openingCash;
  @override
  final int? closingCash;
  @override
  final int? expectedCash;
  @override
  final int? difference;
  @override
  final int? openBillsAtOpenCount;
  @override
  final int? openBillsAtOpenAmount;
  @override
  final int? openBillsAtCloseCount;
  @override
  final int? openBillsAtCloseAmount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'RegisterSessionModel(id: $id, companyId: $companyId, registerId: $registerId, openedByUserId: $openedByUserId, openedAt: $openedAt, closedAt: $closedAt, orderCounter: $orderCounter, billCounter: $billCounter, parentSessionId: $parentSessionId, openingCash: $openingCash, closingCash: $closingCash, expectedCash: $expectedCash, difference: $difference, openBillsAtOpenCount: $openBillsAtOpenCount, openBillsAtOpenAmount: $openBillsAtOpenAmount, openBillsAtCloseCount: $openBillsAtCloseCount, openBillsAtCloseAmount: $openBillsAtCloseAmount, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterSessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.registerId, registerId) ||
                other.registerId == registerId) &&
            (identical(other.openedByUserId, openedByUserId) ||
                other.openedByUserId == openedByUserId) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.orderCounter, orderCounter) ||
                other.orderCounter == orderCounter) &&
            (identical(other.billCounter, billCounter) ||
                other.billCounter == billCounter) &&
            (identical(other.parentSessionId, parentSessionId) ||
                other.parentSessionId == parentSessionId) &&
            (identical(other.openingCash, openingCash) ||
                other.openingCash == openingCash) &&
            (identical(other.closingCash, closingCash) ||
                other.closingCash == closingCash) &&
            (identical(other.expectedCash, expectedCash) ||
                other.expectedCash == expectedCash) &&
            (identical(other.difference, difference) ||
                other.difference == difference) &&
            (identical(other.openBillsAtOpenCount, openBillsAtOpenCount) ||
                other.openBillsAtOpenCount == openBillsAtOpenCount) &&
            (identical(other.openBillsAtOpenAmount, openBillsAtOpenAmount) ||
                other.openBillsAtOpenAmount == openBillsAtOpenAmount) &&
            (identical(other.openBillsAtCloseCount, openBillsAtCloseCount) ||
                other.openBillsAtCloseCount == openBillsAtCloseCount) &&
            (identical(other.openBillsAtCloseAmount, openBillsAtCloseAmount) ||
                other.openBillsAtCloseAmount == openBillsAtCloseAmount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    companyId,
    registerId,
    openedByUserId,
    openedAt,
    closedAt,
    orderCounter,
    billCounter,
    parentSessionId,
    openingCash,
    closingCash,
    expectedCash,
    difference,
    openBillsAtOpenCount,
    openBillsAtOpenAmount,
    openBillsAtCloseCount,
    openBillsAtCloseAmount,
    createdAt,
    updatedAt,
    deletedAt,
  ]);

  /// Create a copy of RegisterSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterSessionModelImplCopyWith<_$RegisterSessionModelImpl>
  get copyWith =>
      __$$RegisterSessionModelImplCopyWithImpl<_$RegisterSessionModelImpl>(
        this,
        _$identity,
      );
}

abstract class _RegisterSessionModel implements RegisterSessionModel {
  const factory _RegisterSessionModel({
    required final String id,
    required final String companyId,
    required final String registerId,
    required final String openedByUserId,
    required final DateTime openedAt,
    final DateTime? closedAt,
    final int orderCounter,
    final int billCounter,
    final String? parentSessionId,
    final int? openingCash,
    final int? closingCash,
    final int? expectedCash,
    final int? difference,
    final int? openBillsAtOpenCount,
    final int? openBillsAtOpenAmount,
    final int? openBillsAtCloseCount,
    final int? openBillsAtCloseAmount,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$RegisterSessionModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get registerId;
  @override
  String get openedByUserId;
  @override
  DateTime get openedAt;
  @override
  DateTime? get closedAt;
  @override
  int get orderCounter;
  @override
  int get billCounter;
  @override
  String? get parentSessionId;
  @override
  int? get openingCash;
  @override
  int? get closingCash;
  @override
  int? get expectedCash;
  @override
  int? get difference;
  @override
  int? get openBillsAtOpenCount;
  @override
  int? get openBillsAtOpenAmount;
  @override
  int? get openBillsAtCloseCount;
  @override
  int? get openBillsAtCloseAmount;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of RegisterSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterSessionModelImplCopyWith<_$RegisterSessionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
