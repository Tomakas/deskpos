// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterSessionModel {

 String get id; String get companyId; String get registerId; String get openedByUserId; DateTime get openedAt; DateTime? get closedAt; int get orderCounter; int get billCounter; String? get parentSessionId; int? get openingCash; int? get closingCash; int? get expectedCash; int? get difference; int? get openBillsAtOpenCount; int? get openBillsAtOpenAmount; int? get openBillsAtCloseCount; int? get openBillsAtCloseAmount; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of RegisterSessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterSessionModelCopyWith<RegisterSessionModel> get copyWith => _$RegisterSessionModelCopyWithImpl<RegisterSessionModel>(this as RegisterSessionModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.openedByUserId, openedByUserId) || other.openedByUserId == openedByUserId)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.orderCounter, orderCounter) || other.orderCounter == orderCounter)&&(identical(other.billCounter, billCounter) || other.billCounter == billCounter)&&(identical(other.parentSessionId, parentSessionId) || other.parentSessionId == parentSessionId)&&(identical(other.openingCash, openingCash) || other.openingCash == openingCash)&&(identical(other.closingCash, closingCash) || other.closingCash == closingCash)&&(identical(other.expectedCash, expectedCash) || other.expectedCash == expectedCash)&&(identical(other.difference, difference) || other.difference == difference)&&(identical(other.openBillsAtOpenCount, openBillsAtOpenCount) || other.openBillsAtOpenCount == openBillsAtOpenCount)&&(identical(other.openBillsAtOpenAmount, openBillsAtOpenAmount) || other.openBillsAtOpenAmount == openBillsAtOpenAmount)&&(identical(other.openBillsAtCloseCount, openBillsAtCloseCount) || other.openBillsAtCloseCount == openBillsAtCloseCount)&&(identical(other.openBillsAtCloseAmount, openBillsAtCloseAmount) || other.openBillsAtCloseAmount == openBillsAtCloseAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,registerId,openedByUserId,openedAt,closedAt,orderCounter,billCounter,parentSessionId,openingCash,closingCash,expectedCash,difference,openBillsAtOpenCount,openBillsAtOpenAmount,openBillsAtCloseCount,openBillsAtCloseAmount,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'RegisterSessionModel(id: $id, companyId: $companyId, registerId: $registerId, openedByUserId: $openedByUserId, openedAt: $openedAt, closedAt: $closedAt, orderCounter: $orderCounter, billCounter: $billCounter, parentSessionId: $parentSessionId, openingCash: $openingCash, closingCash: $closingCash, expectedCash: $expectedCash, difference: $difference, openBillsAtOpenCount: $openBillsAtOpenCount, openBillsAtOpenAmount: $openBillsAtOpenAmount, openBillsAtCloseCount: $openBillsAtCloseCount, openBillsAtCloseAmount: $openBillsAtCloseAmount, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $RegisterSessionModelCopyWith<$Res>  {
  factory $RegisterSessionModelCopyWith(RegisterSessionModel value, $Res Function(RegisterSessionModel) _then) = _$RegisterSessionModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String registerId, String openedByUserId, DateTime openedAt, DateTime? closedAt, int orderCounter, int billCounter, String? parentSessionId, int? openingCash, int? closingCash, int? expectedCash, int? difference, int? openBillsAtOpenCount, int? openBillsAtOpenAmount, int? openBillsAtCloseCount, int? openBillsAtCloseAmount, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$RegisterSessionModelCopyWithImpl<$Res>
    implements $RegisterSessionModelCopyWith<$Res> {
  _$RegisterSessionModelCopyWithImpl(this._self, this._then);

  final RegisterSessionModel _self;
  final $Res Function(RegisterSessionModel) _then;

/// Create a copy of RegisterSessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? registerId = null,Object? openedByUserId = null,Object? openedAt = null,Object? closedAt = freezed,Object? orderCounter = null,Object? billCounter = null,Object? parentSessionId = freezed,Object? openingCash = freezed,Object? closingCash = freezed,Object? expectedCash = freezed,Object? difference = freezed,Object? openBillsAtOpenCount = freezed,Object? openBillsAtOpenAmount = freezed,Object? openBillsAtCloseCount = freezed,Object? openBillsAtCloseAmount = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,registerId: null == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String,openedByUserId: null == openedByUserId ? _self.openedByUserId : openedByUserId // ignore: cast_nullable_to_non_nullable
as String,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,orderCounter: null == orderCounter ? _self.orderCounter : orderCounter // ignore: cast_nullable_to_non_nullable
as int,billCounter: null == billCounter ? _self.billCounter : billCounter // ignore: cast_nullable_to_non_nullable
as int,parentSessionId: freezed == parentSessionId ? _self.parentSessionId : parentSessionId // ignore: cast_nullable_to_non_nullable
as String?,openingCash: freezed == openingCash ? _self.openingCash : openingCash // ignore: cast_nullable_to_non_nullable
as int?,closingCash: freezed == closingCash ? _self.closingCash : closingCash // ignore: cast_nullable_to_non_nullable
as int?,expectedCash: freezed == expectedCash ? _self.expectedCash : expectedCash // ignore: cast_nullable_to_non_nullable
as int?,difference: freezed == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as int?,openBillsAtOpenCount: freezed == openBillsAtOpenCount ? _self.openBillsAtOpenCount : openBillsAtOpenCount // ignore: cast_nullable_to_non_nullable
as int?,openBillsAtOpenAmount: freezed == openBillsAtOpenAmount ? _self.openBillsAtOpenAmount : openBillsAtOpenAmount // ignore: cast_nullable_to_non_nullable
as int?,openBillsAtCloseCount: freezed == openBillsAtCloseCount ? _self.openBillsAtCloseCount : openBillsAtCloseCount // ignore: cast_nullable_to_non_nullable
as int?,openBillsAtCloseAmount: freezed == openBillsAtCloseAmount ? _self.openBillsAtCloseAmount : openBillsAtCloseAmount // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterSessionModel].
extension RegisterSessionModelPatterns on RegisterSessionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterSessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterSessionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterSessionModel value)  $default,){
final _that = this;
switch (_that) {
case _RegisterSessionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterSessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterSessionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String registerId,  String openedByUserId,  DateTime openedAt,  DateTime? closedAt,  int orderCounter,  int billCounter,  String? parentSessionId,  int? openingCash,  int? closingCash,  int? expectedCash,  int? difference,  int? openBillsAtOpenCount,  int? openBillsAtOpenAmount,  int? openBillsAtCloseCount,  int? openBillsAtCloseAmount,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterSessionModel() when $default != null:
return $default(_that.id,_that.companyId,_that.registerId,_that.openedByUserId,_that.openedAt,_that.closedAt,_that.orderCounter,_that.billCounter,_that.parentSessionId,_that.openingCash,_that.closingCash,_that.expectedCash,_that.difference,_that.openBillsAtOpenCount,_that.openBillsAtOpenAmount,_that.openBillsAtCloseCount,_that.openBillsAtCloseAmount,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String registerId,  String openedByUserId,  DateTime openedAt,  DateTime? closedAt,  int orderCounter,  int billCounter,  String? parentSessionId,  int? openingCash,  int? closingCash,  int? expectedCash,  int? difference,  int? openBillsAtOpenCount,  int? openBillsAtOpenAmount,  int? openBillsAtCloseCount,  int? openBillsAtCloseAmount,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _RegisterSessionModel():
return $default(_that.id,_that.companyId,_that.registerId,_that.openedByUserId,_that.openedAt,_that.closedAt,_that.orderCounter,_that.billCounter,_that.parentSessionId,_that.openingCash,_that.closingCash,_that.expectedCash,_that.difference,_that.openBillsAtOpenCount,_that.openBillsAtOpenAmount,_that.openBillsAtCloseCount,_that.openBillsAtCloseAmount,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String registerId,  String openedByUserId,  DateTime openedAt,  DateTime? closedAt,  int orderCounter,  int billCounter,  String? parentSessionId,  int? openingCash,  int? closingCash,  int? expectedCash,  int? difference,  int? openBillsAtOpenCount,  int? openBillsAtOpenAmount,  int? openBillsAtCloseCount,  int? openBillsAtCloseAmount,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _RegisterSessionModel() when $default != null:
return $default(_that.id,_that.companyId,_that.registerId,_that.openedByUserId,_that.openedAt,_that.closedAt,_that.orderCounter,_that.billCounter,_that.parentSessionId,_that.openingCash,_that.closingCash,_that.expectedCash,_that.difference,_that.openBillsAtOpenCount,_that.openBillsAtOpenAmount,_that.openBillsAtCloseCount,_that.openBillsAtCloseAmount,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterSessionModel implements RegisterSessionModel {
  const _RegisterSessionModel({required this.id, required this.companyId, required this.registerId, required this.openedByUserId, required this.openedAt, this.closedAt, this.orderCounter = 0, this.billCounter = 0, this.parentSessionId, this.openingCash, this.closingCash, this.expectedCash, this.difference, this.openBillsAtOpenCount, this.openBillsAtOpenAmount, this.openBillsAtCloseCount, this.openBillsAtCloseAmount, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String registerId;
@override final  String openedByUserId;
@override final  DateTime openedAt;
@override final  DateTime? closedAt;
@override@JsonKey() final  int orderCounter;
@override@JsonKey() final  int billCounter;
@override final  String? parentSessionId;
@override final  int? openingCash;
@override final  int? closingCash;
@override final  int? expectedCash;
@override final  int? difference;
@override final  int? openBillsAtOpenCount;
@override final  int? openBillsAtOpenAmount;
@override final  int? openBillsAtCloseCount;
@override final  int? openBillsAtCloseAmount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of RegisterSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterSessionModelCopyWith<_RegisterSessionModel> get copyWith => __$RegisterSessionModelCopyWithImpl<_RegisterSessionModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.openedByUserId, openedByUserId) || other.openedByUserId == openedByUserId)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.orderCounter, orderCounter) || other.orderCounter == orderCounter)&&(identical(other.billCounter, billCounter) || other.billCounter == billCounter)&&(identical(other.parentSessionId, parentSessionId) || other.parentSessionId == parentSessionId)&&(identical(other.openingCash, openingCash) || other.openingCash == openingCash)&&(identical(other.closingCash, closingCash) || other.closingCash == closingCash)&&(identical(other.expectedCash, expectedCash) || other.expectedCash == expectedCash)&&(identical(other.difference, difference) || other.difference == difference)&&(identical(other.openBillsAtOpenCount, openBillsAtOpenCount) || other.openBillsAtOpenCount == openBillsAtOpenCount)&&(identical(other.openBillsAtOpenAmount, openBillsAtOpenAmount) || other.openBillsAtOpenAmount == openBillsAtOpenAmount)&&(identical(other.openBillsAtCloseCount, openBillsAtCloseCount) || other.openBillsAtCloseCount == openBillsAtCloseCount)&&(identical(other.openBillsAtCloseAmount, openBillsAtCloseAmount) || other.openBillsAtCloseAmount == openBillsAtCloseAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,registerId,openedByUserId,openedAt,closedAt,orderCounter,billCounter,parentSessionId,openingCash,closingCash,expectedCash,difference,openBillsAtOpenCount,openBillsAtOpenAmount,openBillsAtCloseCount,openBillsAtCloseAmount,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'RegisterSessionModel(id: $id, companyId: $companyId, registerId: $registerId, openedByUserId: $openedByUserId, openedAt: $openedAt, closedAt: $closedAt, orderCounter: $orderCounter, billCounter: $billCounter, parentSessionId: $parentSessionId, openingCash: $openingCash, closingCash: $closingCash, expectedCash: $expectedCash, difference: $difference, openBillsAtOpenCount: $openBillsAtOpenCount, openBillsAtOpenAmount: $openBillsAtOpenAmount, openBillsAtCloseCount: $openBillsAtCloseCount, openBillsAtCloseAmount: $openBillsAtCloseAmount, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$RegisterSessionModelCopyWith<$Res> implements $RegisterSessionModelCopyWith<$Res> {
  factory _$RegisterSessionModelCopyWith(_RegisterSessionModel value, $Res Function(_RegisterSessionModel) _then) = __$RegisterSessionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String registerId, String openedByUserId, DateTime openedAt, DateTime? closedAt, int orderCounter, int billCounter, String? parentSessionId, int? openingCash, int? closingCash, int? expectedCash, int? difference, int? openBillsAtOpenCount, int? openBillsAtOpenAmount, int? openBillsAtCloseCount, int? openBillsAtCloseAmount, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$RegisterSessionModelCopyWithImpl<$Res>
    implements _$RegisterSessionModelCopyWith<$Res> {
  __$RegisterSessionModelCopyWithImpl(this._self, this._then);

  final _RegisterSessionModel _self;
  final $Res Function(_RegisterSessionModel) _then;

/// Create a copy of RegisterSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? registerId = null,Object? openedByUserId = null,Object? openedAt = null,Object? closedAt = freezed,Object? orderCounter = null,Object? billCounter = null,Object? parentSessionId = freezed,Object? openingCash = freezed,Object? closingCash = freezed,Object? expectedCash = freezed,Object? difference = freezed,Object? openBillsAtOpenCount = freezed,Object? openBillsAtOpenAmount = freezed,Object? openBillsAtCloseCount = freezed,Object? openBillsAtCloseAmount = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_RegisterSessionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,registerId: null == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String,openedByUserId: null == openedByUserId ? _self.openedByUserId : openedByUserId // ignore: cast_nullable_to_non_nullable
as String,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,orderCounter: null == orderCounter ? _self.orderCounter : orderCounter // ignore: cast_nullable_to_non_nullable
as int,billCounter: null == billCounter ? _self.billCounter : billCounter // ignore: cast_nullable_to_non_nullable
as int,parentSessionId: freezed == parentSessionId ? _self.parentSessionId : parentSessionId // ignore: cast_nullable_to_non_nullable
as String?,openingCash: freezed == openingCash ? _self.openingCash : openingCash // ignore: cast_nullable_to_non_nullable
as int?,closingCash: freezed == closingCash ? _self.closingCash : closingCash // ignore: cast_nullable_to_non_nullable
as int?,expectedCash: freezed == expectedCash ? _self.expectedCash : expectedCash // ignore: cast_nullable_to_non_nullable
as int?,difference: freezed == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as int?,openBillsAtOpenCount: freezed == openBillsAtOpenCount ? _self.openBillsAtOpenCount : openBillsAtOpenCount // ignore: cast_nullable_to_non_nullable
as int?,openBillsAtOpenAmount: freezed == openBillsAtOpenAmount ? _self.openBillsAtOpenAmount : openBillsAtOpenAmount // ignore: cast_nullable_to_non_nullable
as int?,openBillsAtCloseCount: freezed == openBillsAtCloseCount ? _self.openBillsAtCloseCount : openBillsAtCloseCount // ignore: cast_nullable_to_non_nullable
as int?,openBillsAtCloseAmount: freezed == openBillsAtCloseAmount ? _self.openBillsAtCloseAmount : openBillsAtCloseAmount // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
