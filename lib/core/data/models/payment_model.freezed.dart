// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaymentModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get billId => throw _privateConstructorUsedError;
  String? get registerId => throw _privateConstructorUsedError;
  String? get registerSessionId => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String get paymentMethodId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  DateTime get paidAt => throw _privateConstructorUsedError;
  String get currencyId => throw _privateConstructorUsedError;
  int get tipIncludedAmount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String? get paymentProvider => throw _privateConstructorUsedError;
  String? get cardLast4 => throw _privateConstructorUsedError;
  String? get authorizationCode => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentModelCopyWith<PaymentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentModelCopyWith<$Res> {
  factory $PaymentModelCopyWith(
    PaymentModel value,
    $Res Function(PaymentModel) then,
  ) = _$PaymentModelCopyWithImpl<$Res, PaymentModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String billId,
    String? registerId,
    String? registerSessionId,
    String? userId,
    String paymentMethodId,
    int amount,
    DateTime paidAt,
    String currencyId,
    int tipIncludedAmount,
    String? notes,
    String? transactionId,
    String? paymentProvider,
    String? cardLast4,
    String? authorizationCode,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$PaymentModelCopyWithImpl<$Res, $Val extends PaymentModel>
    implements $PaymentModelCopyWith<$Res> {
  _$PaymentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? billId = null,
    Object? registerId = freezed,
    Object? registerSessionId = freezed,
    Object? userId = freezed,
    Object? paymentMethodId = null,
    Object? amount = null,
    Object? paidAt = null,
    Object? currencyId = null,
    Object? tipIncludedAmount = null,
    Object? notes = freezed,
    Object? transactionId = freezed,
    Object? paymentProvider = freezed,
    Object? cardLast4 = freezed,
    Object? authorizationCode = freezed,
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
            billId: null == billId
                ? _value.billId
                : billId // ignore: cast_nullable_to_non_nullable
                      as String,
            registerId: freezed == registerId
                ? _value.registerId
                : registerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            registerSessionId: freezed == registerSessionId
                ? _value.registerSessionId
                : registerSessionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentMethodId: null == paymentMethodId
                ? _value.paymentMethodId
                : paymentMethodId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as int,
            paidAt: null == paidAt
                ? _value.paidAt
                : paidAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            currencyId: null == currencyId
                ? _value.currencyId
                : currencyId // ignore: cast_nullable_to_non_nullable
                      as String,
            tipIncludedAmount: null == tipIncludedAmount
                ? _value.tipIncludedAmount
                : tipIncludedAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            transactionId: freezed == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentProvider: freezed == paymentProvider
                ? _value.paymentProvider
                : paymentProvider // ignore: cast_nullable_to_non_nullable
                      as String?,
            cardLast4: freezed == cardLast4
                ? _value.cardLast4
                : cardLast4 // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorizationCode: freezed == authorizationCode
                ? _value.authorizationCode
                : authorizationCode // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$PaymentModelImplCopyWith<$Res>
    implements $PaymentModelCopyWith<$Res> {
  factory _$$PaymentModelImplCopyWith(
    _$PaymentModelImpl value,
    $Res Function(_$PaymentModelImpl) then,
  ) = __$$PaymentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String billId,
    String? registerId,
    String? registerSessionId,
    String? userId,
    String paymentMethodId,
    int amount,
    DateTime paidAt,
    String currencyId,
    int tipIncludedAmount,
    String? notes,
    String? transactionId,
    String? paymentProvider,
    String? cardLast4,
    String? authorizationCode,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$PaymentModelImplCopyWithImpl<$Res>
    extends _$PaymentModelCopyWithImpl<$Res, _$PaymentModelImpl>
    implements _$$PaymentModelImplCopyWith<$Res> {
  __$$PaymentModelImplCopyWithImpl(
    _$PaymentModelImpl _value,
    $Res Function(_$PaymentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? billId = null,
    Object? registerId = freezed,
    Object? registerSessionId = freezed,
    Object? userId = freezed,
    Object? paymentMethodId = null,
    Object? amount = null,
    Object? paidAt = null,
    Object? currencyId = null,
    Object? tipIncludedAmount = null,
    Object? notes = freezed,
    Object? transactionId = freezed,
    Object? paymentProvider = freezed,
    Object? cardLast4 = freezed,
    Object? authorizationCode = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$PaymentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        billId: null == billId
            ? _value.billId
            : billId // ignore: cast_nullable_to_non_nullable
                  as String,
        registerId: freezed == registerId
            ? _value.registerId
            : registerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        registerSessionId: freezed == registerSessionId
            ? _value.registerSessionId
            : registerSessionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentMethodId: null == paymentMethodId
            ? _value.paymentMethodId
            : paymentMethodId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as int,
        paidAt: null == paidAt
            ? _value.paidAt
            : paidAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        currencyId: null == currencyId
            ? _value.currencyId
            : currencyId // ignore: cast_nullable_to_non_nullable
                  as String,
        tipIncludedAmount: null == tipIncludedAmount
            ? _value.tipIncludedAmount
            : tipIncludedAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        transactionId: freezed == transactionId
            ? _value.transactionId
            : transactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentProvider: freezed == paymentProvider
            ? _value.paymentProvider
            : paymentProvider // ignore: cast_nullable_to_non_nullable
                  as String?,
        cardLast4: freezed == cardLast4
            ? _value.cardLast4
            : cardLast4 // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorizationCode: freezed == authorizationCode
            ? _value.authorizationCode
            : authorizationCode // ignore: cast_nullable_to_non_nullable
                  as String?,
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

class _$PaymentModelImpl implements _PaymentModel {
  const _$PaymentModelImpl({
    required this.id,
    required this.companyId,
    required this.billId,
    this.registerId,
    this.registerSessionId,
    this.userId,
    required this.paymentMethodId,
    required this.amount,
    required this.paidAt,
    required this.currencyId,
    this.tipIncludedAmount = 0,
    this.notes,
    this.transactionId,
    this.paymentProvider,
    this.cardLast4,
    this.authorizationCode,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String billId;
  @override
  final String? registerId;
  @override
  final String? registerSessionId;
  @override
  final String? userId;
  @override
  final String paymentMethodId;
  @override
  final int amount;
  @override
  final DateTime paidAt;
  @override
  final String currencyId;
  @override
  @JsonKey()
  final int tipIncludedAmount;
  @override
  final String? notes;
  @override
  final String? transactionId;
  @override
  final String? paymentProvider;
  @override
  final String? cardLast4;
  @override
  final String? authorizationCode;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'PaymentModel(id: $id, companyId: $companyId, billId: $billId, registerId: $registerId, registerSessionId: $registerSessionId, userId: $userId, paymentMethodId: $paymentMethodId, amount: $amount, paidAt: $paidAt, currencyId: $currencyId, tipIncludedAmount: $tipIncludedAmount, notes: $notes, transactionId: $transactionId, paymentProvider: $paymentProvider, cardLast4: $cardLast4, authorizationCode: $authorizationCode, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.billId, billId) || other.billId == billId) &&
            (identical(other.registerId, registerId) ||
                other.registerId == registerId) &&
            (identical(other.registerSessionId, registerSessionId) ||
                other.registerSessionId == registerSessionId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.paymentMethodId, paymentMethodId) ||
                other.paymentMethodId == paymentMethodId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.currencyId, currencyId) ||
                other.currencyId == currencyId) &&
            (identical(other.tipIncludedAmount, tipIncludedAmount) ||
                other.tipIncludedAmount == tipIncludedAmount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.paymentProvider, paymentProvider) ||
                other.paymentProvider == paymentProvider) &&
            (identical(other.cardLast4, cardLast4) ||
                other.cardLast4 == cardLast4) &&
            (identical(other.authorizationCode, authorizationCode) ||
                other.authorizationCode == authorizationCode) &&
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
    billId,
    registerId,
    registerSessionId,
    userId,
    paymentMethodId,
    amount,
    paidAt,
    currencyId,
    tipIncludedAmount,
    notes,
    transactionId,
    paymentProvider,
    cardLast4,
    authorizationCode,
    createdAt,
    updatedAt,
    deletedAt,
  ]);

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentModelImplCopyWith<_$PaymentModelImpl> get copyWith =>
      __$$PaymentModelImplCopyWithImpl<_$PaymentModelImpl>(this, _$identity);
}

abstract class _PaymentModel implements PaymentModel {
  const factory _PaymentModel({
    required final String id,
    required final String companyId,
    required final String billId,
    final String? registerId,
    final String? registerSessionId,
    final String? userId,
    required final String paymentMethodId,
    required final int amount,
    required final DateTime paidAt,
    required final String currencyId,
    final int tipIncludedAmount,
    final String? notes,
    final String? transactionId,
    final String? paymentProvider,
    final String? cardLast4,
    final String? authorizationCode,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$PaymentModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get billId;
  @override
  String? get registerId;
  @override
  String? get registerSessionId;
  @override
  String? get userId;
  @override
  String get paymentMethodId;
  @override
  int get amount;
  @override
  DateTime get paidAt;
  @override
  String get currencyId;
  @override
  int get tipIncludedAmount;
  @override
  String? get notes;
  @override
  String? get transactionId;
  @override
  String? get paymentProvider;
  @override
  String? get cardLast4;
  @override
  String? get authorizationCode;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentModelImplCopyWith<_$PaymentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
