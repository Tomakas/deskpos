// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_movement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CashMovementModel {

 String get id; String get companyId; String get registerSessionId; String get userId; CashMovementType get type; int get amount; String? get reason; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of CashMovementModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashMovementModelCopyWith<CashMovementModel> get copyWith => _$CashMovementModelCopyWithImpl<CashMovementModel>(this as CashMovementModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashMovementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.registerSessionId, registerSessionId) || other.registerSessionId == registerSessionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,registerSessionId,userId,type,amount,reason,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'CashMovementModel(id: $id, companyId: $companyId, registerSessionId: $registerSessionId, userId: $userId, type: $type, amount: $amount, reason: $reason, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $CashMovementModelCopyWith<$Res>  {
  factory $CashMovementModelCopyWith(CashMovementModel value, $Res Function(CashMovementModel) _then) = _$CashMovementModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String registerSessionId, String userId, CashMovementType type, int amount, String? reason, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$CashMovementModelCopyWithImpl<$Res>
    implements $CashMovementModelCopyWith<$Res> {
  _$CashMovementModelCopyWithImpl(this._self, this._then);

  final CashMovementModel _self;
  final $Res Function(CashMovementModel) _then;

/// Create a copy of CashMovementModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? registerSessionId = null,Object? userId = null,Object? type = null,Object? amount = null,Object? reason = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,registerSessionId: null == registerSessionId ? _self.registerSessionId : registerSessionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CashMovementType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CashMovementModel].
extension CashMovementModelPatterns on CashMovementModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashMovementModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashMovementModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashMovementModel value)  $default,){
final _that = this;
switch (_that) {
case _CashMovementModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashMovementModel value)?  $default,){
final _that = this;
switch (_that) {
case _CashMovementModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String registerSessionId,  String userId,  CashMovementType type,  int amount,  String? reason,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashMovementModel() when $default != null:
return $default(_that.id,_that.companyId,_that.registerSessionId,_that.userId,_that.type,_that.amount,_that.reason,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String registerSessionId,  String userId,  CashMovementType type,  int amount,  String? reason,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _CashMovementModel():
return $default(_that.id,_that.companyId,_that.registerSessionId,_that.userId,_that.type,_that.amount,_that.reason,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String registerSessionId,  String userId,  CashMovementType type,  int amount,  String? reason,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _CashMovementModel() when $default != null:
return $default(_that.id,_that.companyId,_that.registerSessionId,_that.userId,_that.type,_that.amount,_that.reason,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CashMovementModel implements CashMovementModel {
  const _CashMovementModel({required this.id, required this.companyId, required this.registerSessionId, required this.userId, required this.type, required this.amount, this.reason, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String registerSessionId;
@override final  String userId;
@override final  CashMovementType type;
@override final  int amount;
@override final  String? reason;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of CashMovementModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashMovementModelCopyWith<_CashMovementModel> get copyWith => __$CashMovementModelCopyWithImpl<_CashMovementModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashMovementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.registerSessionId, registerSessionId) || other.registerSessionId == registerSessionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,registerSessionId,userId,type,amount,reason,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'CashMovementModel(id: $id, companyId: $companyId, registerSessionId: $registerSessionId, userId: $userId, type: $type, amount: $amount, reason: $reason, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$CashMovementModelCopyWith<$Res> implements $CashMovementModelCopyWith<$Res> {
  factory _$CashMovementModelCopyWith(_CashMovementModel value, $Res Function(_CashMovementModel) _then) = __$CashMovementModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String registerSessionId, String userId, CashMovementType type, int amount, String? reason, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$CashMovementModelCopyWithImpl<$Res>
    implements _$CashMovementModelCopyWith<$Res> {
  __$CashMovementModelCopyWithImpl(this._self, this._then);

  final _CashMovementModel _self;
  final $Res Function(_CashMovementModel) _then;

/// Create a copy of CashMovementModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? registerSessionId = null,Object? userId = null,Object? type = null,Object? amount = null,Object? reason = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_CashMovementModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,registerSessionId: null == registerSessionId ? _self.registerSessionId : registerSessionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CashMovementType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
