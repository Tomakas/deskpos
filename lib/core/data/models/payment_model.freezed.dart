// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentModel {

 String get id; String get companyId; String get billId; String? get registerId; String? get registerSessionId; String? get userId; String get paymentMethodId; int get amount; DateTime get paidAt; String get currencyId; int get tipIncludedAmount; String? get notes; String? get transactionId; String? get paymentProvider; String? get cardLast4; String? get authorizationCode; String? get foreignCurrencyId; int? get foreignAmount; double? get exchangeRate; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of PaymentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentModelCopyWith<PaymentModel> get copyWith => _$PaymentModelCopyWithImpl<PaymentModel>(this as PaymentModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.registerSessionId, registerSessionId) || other.registerSessionId == registerSessionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.currencyId, currencyId) || other.currencyId == currencyId)&&(identical(other.tipIncludedAmount, tipIncludedAmount) || other.tipIncludedAmount == tipIncludedAmount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&(identical(other.authorizationCode, authorizationCode) || other.authorizationCode == authorizationCode)&&(identical(other.foreignCurrencyId, foreignCurrencyId) || other.foreignCurrencyId == foreignCurrencyId)&&(identical(other.foreignAmount, foreignAmount) || other.foreignAmount == foreignAmount)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,billId,registerId,registerSessionId,userId,paymentMethodId,amount,paidAt,currencyId,tipIncludedAmount,notes,transactionId,paymentProvider,cardLast4,authorizationCode,foreignCurrencyId,foreignAmount,exchangeRate,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'PaymentModel(id: $id, companyId: $companyId, billId: $billId, registerId: $registerId, registerSessionId: $registerSessionId, userId: $userId, paymentMethodId: $paymentMethodId, amount: $amount, paidAt: $paidAt, currencyId: $currencyId, tipIncludedAmount: $tipIncludedAmount, notes: $notes, transactionId: $transactionId, paymentProvider: $paymentProvider, cardLast4: $cardLast4, authorizationCode: $authorizationCode, foreignCurrencyId: $foreignCurrencyId, foreignAmount: $foreignAmount, exchangeRate: $exchangeRate, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $PaymentModelCopyWith<$Res>  {
  factory $PaymentModelCopyWith(PaymentModel value, $Res Function(PaymentModel) _then) = _$PaymentModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String billId, String? registerId, String? registerSessionId, String? userId, String paymentMethodId, int amount, DateTime paidAt, String currencyId, int tipIncludedAmount, String? notes, String? transactionId, String? paymentProvider, String? cardLast4, String? authorizationCode, String? foreignCurrencyId, int? foreignAmount, double? exchangeRate, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$PaymentModelCopyWithImpl<$Res>
    implements $PaymentModelCopyWith<$Res> {
  _$PaymentModelCopyWithImpl(this._self, this._then);

  final PaymentModel _self;
  final $Res Function(PaymentModel) _then;

/// Create a copy of PaymentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? billId = null,Object? registerId = freezed,Object? registerSessionId = freezed,Object? userId = freezed,Object? paymentMethodId = null,Object? amount = null,Object? paidAt = null,Object? currencyId = null,Object? tipIncludedAmount = null,Object? notes = freezed,Object? transactionId = freezed,Object? paymentProvider = freezed,Object? cardLast4 = freezed,Object? authorizationCode = freezed,Object? foreignCurrencyId = freezed,Object? foreignAmount = freezed,Object? exchangeRate = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,billId: null == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String,registerId: freezed == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String?,registerSessionId: freezed == registerSessionId ? _self.registerSessionId : registerSessionId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,currencyId: null == currencyId ? _self.currencyId : currencyId // ignore: cast_nullable_to_non_nullable
as String,tipIncludedAmount: null == tipIncludedAmount ? _self.tipIncludedAmount : tipIncludedAmount // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,paymentProvider: freezed == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as String?,cardLast4: freezed == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String?,authorizationCode: freezed == authorizationCode ? _self.authorizationCode : authorizationCode // ignore: cast_nullable_to_non_nullable
as String?,foreignCurrencyId: freezed == foreignCurrencyId ? _self.foreignCurrencyId : foreignCurrencyId // ignore: cast_nullable_to_non_nullable
as String?,foreignAmount: freezed == foreignAmount ? _self.foreignAmount : foreignAmount // ignore: cast_nullable_to_non_nullable
as int?,exchangeRate: freezed == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentModel].
extension PaymentModelPatterns on PaymentModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentModel value)  $default,){
final _that = this;
switch (_that) {
case _PaymentModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentModel value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String billId,  String? registerId,  String? registerSessionId,  String? userId,  String paymentMethodId,  int amount,  DateTime paidAt,  String currencyId,  int tipIncludedAmount,  String? notes,  String? transactionId,  String? paymentProvider,  String? cardLast4,  String? authorizationCode,  String? foreignCurrencyId,  int? foreignAmount,  double? exchangeRate,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentModel() when $default != null:
return $default(_that.id,_that.companyId,_that.billId,_that.registerId,_that.registerSessionId,_that.userId,_that.paymentMethodId,_that.amount,_that.paidAt,_that.currencyId,_that.tipIncludedAmount,_that.notes,_that.transactionId,_that.paymentProvider,_that.cardLast4,_that.authorizationCode,_that.foreignCurrencyId,_that.foreignAmount,_that.exchangeRate,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String billId,  String? registerId,  String? registerSessionId,  String? userId,  String paymentMethodId,  int amount,  DateTime paidAt,  String currencyId,  int tipIncludedAmount,  String? notes,  String? transactionId,  String? paymentProvider,  String? cardLast4,  String? authorizationCode,  String? foreignCurrencyId,  int? foreignAmount,  double? exchangeRate,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentModel():
return $default(_that.id,_that.companyId,_that.billId,_that.registerId,_that.registerSessionId,_that.userId,_that.paymentMethodId,_that.amount,_that.paidAt,_that.currencyId,_that.tipIncludedAmount,_that.notes,_that.transactionId,_that.paymentProvider,_that.cardLast4,_that.authorizationCode,_that.foreignCurrencyId,_that.foreignAmount,_that.exchangeRate,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String billId,  String? registerId,  String? registerSessionId,  String? userId,  String paymentMethodId,  int amount,  DateTime paidAt,  String currencyId,  int tipIncludedAmount,  String? notes,  String? transactionId,  String? paymentProvider,  String? cardLast4,  String? authorizationCode,  String? foreignCurrencyId,  int? foreignAmount,  double? exchangeRate,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentModel() when $default != null:
return $default(_that.id,_that.companyId,_that.billId,_that.registerId,_that.registerSessionId,_that.userId,_that.paymentMethodId,_that.amount,_that.paidAt,_that.currencyId,_that.tipIncludedAmount,_that.notes,_that.transactionId,_that.paymentProvider,_that.cardLast4,_that.authorizationCode,_that.foreignCurrencyId,_that.foreignAmount,_that.exchangeRate,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentModel implements PaymentModel {
  const _PaymentModel({required this.id, required this.companyId, required this.billId, this.registerId, this.registerSessionId, this.userId, required this.paymentMethodId, required this.amount, required this.paidAt, required this.currencyId, this.tipIncludedAmount = 0, this.notes, this.transactionId, this.paymentProvider, this.cardLast4, this.authorizationCode, this.foreignCurrencyId, this.foreignAmount, this.exchangeRate, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String billId;
@override final  String? registerId;
@override final  String? registerSessionId;
@override final  String? userId;
@override final  String paymentMethodId;
@override final  int amount;
@override final  DateTime paidAt;
@override final  String currencyId;
@override@JsonKey() final  int tipIncludedAmount;
@override final  String? notes;
@override final  String? transactionId;
@override final  String? paymentProvider;
@override final  String? cardLast4;
@override final  String? authorizationCode;
@override final  String? foreignCurrencyId;
@override final  int? foreignAmount;
@override final  double? exchangeRate;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of PaymentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentModelCopyWith<_PaymentModel> get copyWith => __$PaymentModelCopyWithImpl<_PaymentModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.registerSessionId, registerSessionId) || other.registerSessionId == registerSessionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.currencyId, currencyId) || other.currencyId == currencyId)&&(identical(other.tipIncludedAmount, tipIncludedAmount) || other.tipIncludedAmount == tipIncludedAmount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&(identical(other.authorizationCode, authorizationCode) || other.authorizationCode == authorizationCode)&&(identical(other.foreignCurrencyId, foreignCurrencyId) || other.foreignCurrencyId == foreignCurrencyId)&&(identical(other.foreignAmount, foreignAmount) || other.foreignAmount == foreignAmount)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,billId,registerId,registerSessionId,userId,paymentMethodId,amount,paidAt,currencyId,tipIncludedAmount,notes,transactionId,paymentProvider,cardLast4,authorizationCode,foreignCurrencyId,foreignAmount,exchangeRate,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'PaymentModel(id: $id, companyId: $companyId, billId: $billId, registerId: $registerId, registerSessionId: $registerSessionId, userId: $userId, paymentMethodId: $paymentMethodId, amount: $amount, paidAt: $paidAt, currencyId: $currencyId, tipIncludedAmount: $tipIncludedAmount, notes: $notes, transactionId: $transactionId, paymentProvider: $paymentProvider, cardLast4: $cardLast4, authorizationCode: $authorizationCode, foreignCurrencyId: $foreignCurrencyId, foreignAmount: $foreignAmount, exchangeRate: $exchangeRate, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentModelCopyWith<$Res> implements $PaymentModelCopyWith<$Res> {
  factory _$PaymentModelCopyWith(_PaymentModel value, $Res Function(_PaymentModel) _then) = __$PaymentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String billId, String? registerId, String? registerSessionId, String? userId, String paymentMethodId, int amount, DateTime paidAt, String currencyId, int tipIncludedAmount, String? notes, String? transactionId, String? paymentProvider, String? cardLast4, String? authorizationCode, String? foreignCurrencyId, int? foreignAmount, double? exchangeRate, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$PaymentModelCopyWithImpl<$Res>
    implements _$PaymentModelCopyWith<$Res> {
  __$PaymentModelCopyWithImpl(this._self, this._then);

  final _PaymentModel _self;
  final $Res Function(_PaymentModel) _then;

/// Create a copy of PaymentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? billId = null,Object? registerId = freezed,Object? registerSessionId = freezed,Object? userId = freezed,Object? paymentMethodId = null,Object? amount = null,Object? paidAt = null,Object? currencyId = null,Object? tipIncludedAmount = null,Object? notes = freezed,Object? transactionId = freezed,Object? paymentProvider = freezed,Object? cardLast4 = freezed,Object? authorizationCode = freezed,Object? foreignCurrencyId = freezed,Object? foreignAmount = freezed,Object? exchangeRate = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_PaymentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,billId: null == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String,registerId: freezed == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String?,registerSessionId: freezed == registerSessionId ? _self.registerSessionId : registerSessionId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,currencyId: null == currencyId ? _self.currencyId : currencyId // ignore: cast_nullable_to_non_nullable
as String,tipIncludedAmount: null == tipIncludedAmount ? _self.tipIncludedAmount : tipIncludedAmount // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,paymentProvider: freezed == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as String?,cardLast4: freezed == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String?,authorizationCode: freezed == authorizationCode ? _self.authorizationCode : authorizationCode // ignore: cast_nullable_to_non_nullable
as String?,foreignCurrencyId: freezed == foreignCurrencyId ? _self.foreignCurrencyId : foreignCurrencyId // ignore: cast_nullable_to_non_nullable
as String?,foreignAmount: freezed == foreignAmount ? _self.foreignAmount : foreignAmount // ignore: cast_nullable_to_non_nullable
as int?,exchangeRate: freezed == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
