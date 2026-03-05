// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'internal_account_settlement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InternalAccountSettlementModel {

 String get id; String get companyId; String get internalAccountId; String get settledByUserId; DateTime get settledAt; int get totalAmount; int get settledAmount; int get forgivenAmount; int get discountAmount; String? get note; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of InternalAccountSettlementModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InternalAccountSettlementModelCopyWith<InternalAccountSettlementModel> get copyWith => _$InternalAccountSettlementModelCopyWithImpl<InternalAccountSettlementModel>(this as InternalAccountSettlementModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InternalAccountSettlementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.internalAccountId, internalAccountId) || other.internalAccountId == internalAccountId)&&(identical(other.settledByUserId, settledByUserId) || other.settledByUserId == settledByUserId)&&(identical(other.settledAt, settledAt) || other.settledAt == settledAt)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.settledAmount, settledAmount) || other.settledAmount == settledAmount)&&(identical(other.forgivenAmount, forgivenAmount) || other.forgivenAmount == forgivenAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,internalAccountId,settledByUserId,settledAt,totalAmount,settledAmount,forgivenAmount,discountAmount,note,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'InternalAccountSettlementModel(id: $id, companyId: $companyId, internalAccountId: $internalAccountId, settledByUserId: $settledByUserId, settledAt: $settledAt, totalAmount: $totalAmount, settledAmount: $settledAmount, forgivenAmount: $forgivenAmount, discountAmount: $discountAmount, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $InternalAccountSettlementModelCopyWith<$Res>  {
  factory $InternalAccountSettlementModelCopyWith(InternalAccountSettlementModel value, $Res Function(InternalAccountSettlementModel) _then) = _$InternalAccountSettlementModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String internalAccountId, String settledByUserId, DateTime settledAt, int totalAmount, int settledAmount, int forgivenAmount, int discountAmount, String? note, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$InternalAccountSettlementModelCopyWithImpl<$Res>
    implements $InternalAccountSettlementModelCopyWith<$Res> {
  _$InternalAccountSettlementModelCopyWithImpl(this._self, this._then);

  final InternalAccountSettlementModel _self;
  final $Res Function(InternalAccountSettlementModel) _then;

/// Create a copy of InternalAccountSettlementModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? internalAccountId = null,Object? settledByUserId = null,Object? settledAt = null,Object? totalAmount = null,Object? settledAmount = null,Object? forgivenAmount = null,Object? discountAmount = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,internalAccountId: null == internalAccountId ? _self.internalAccountId : internalAccountId // ignore: cast_nullable_to_non_nullable
as String,settledByUserId: null == settledByUserId ? _self.settledByUserId : settledByUserId // ignore: cast_nullable_to_non_nullable
as String,settledAt: null == settledAt ? _self.settledAt : settledAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,settledAmount: null == settledAmount ? _self.settledAmount : settledAmount // ignore: cast_nullable_to_non_nullable
as int,forgivenAmount: null == forgivenAmount ? _self.forgivenAmount : forgivenAmount // ignore: cast_nullable_to_non_nullable
as int,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InternalAccountSettlementModel].
extension InternalAccountSettlementModelPatterns on InternalAccountSettlementModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InternalAccountSettlementModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InternalAccountSettlementModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InternalAccountSettlementModel value)  $default,){
final _that = this;
switch (_that) {
case _InternalAccountSettlementModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InternalAccountSettlementModel value)?  $default,){
final _that = this;
switch (_that) {
case _InternalAccountSettlementModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String internalAccountId,  String settledByUserId,  DateTime settledAt,  int totalAmount,  int settledAmount,  int forgivenAmount,  int discountAmount,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InternalAccountSettlementModel() when $default != null:
return $default(_that.id,_that.companyId,_that.internalAccountId,_that.settledByUserId,_that.settledAt,_that.totalAmount,_that.settledAmount,_that.forgivenAmount,_that.discountAmount,_that.note,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String internalAccountId,  String settledByUserId,  DateTime settledAt,  int totalAmount,  int settledAmount,  int forgivenAmount,  int discountAmount,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _InternalAccountSettlementModel():
return $default(_that.id,_that.companyId,_that.internalAccountId,_that.settledByUserId,_that.settledAt,_that.totalAmount,_that.settledAmount,_that.forgivenAmount,_that.discountAmount,_that.note,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String internalAccountId,  String settledByUserId,  DateTime settledAt,  int totalAmount,  int settledAmount,  int forgivenAmount,  int discountAmount,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _InternalAccountSettlementModel() when $default != null:
return $default(_that.id,_that.companyId,_that.internalAccountId,_that.settledByUserId,_that.settledAt,_that.totalAmount,_that.settledAmount,_that.forgivenAmount,_that.discountAmount,_that.note,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _InternalAccountSettlementModel implements InternalAccountSettlementModel {
  const _InternalAccountSettlementModel({required this.id, required this.companyId, required this.internalAccountId, required this.settledByUserId, required this.settledAt, this.totalAmount = 0, this.settledAmount = 0, this.forgivenAmount = 0, this.discountAmount = 0, this.note, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String internalAccountId;
@override final  String settledByUserId;
@override final  DateTime settledAt;
@override@JsonKey() final  int totalAmount;
@override@JsonKey() final  int settledAmount;
@override@JsonKey() final  int forgivenAmount;
@override@JsonKey() final  int discountAmount;
@override final  String? note;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of InternalAccountSettlementModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InternalAccountSettlementModelCopyWith<_InternalAccountSettlementModel> get copyWith => __$InternalAccountSettlementModelCopyWithImpl<_InternalAccountSettlementModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InternalAccountSettlementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.internalAccountId, internalAccountId) || other.internalAccountId == internalAccountId)&&(identical(other.settledByUserId, settledByUserId) || other.settledByUserId == settledByUserId)&&(identical(other.settledAt, settledAt) || other.settledAt == settledAt)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.settledAmount, settledAmount) || other.settledAmount == settledAmount)&&(identical(other.forgivenAmount, forgivenAmount) || other.forgivenAmount == forgivenAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,internalAccountId,settledByUserId,settledAt,totalAmount,settledAmount,forgivenAmount,discountAmount,note,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'InternalAccountSettlementModel(id: $id, companyId: $companyId, internalAccountId: $internalAccountId, settledByUserId: $settledByUserId, settledAt: $settledAt, totalAmount: $totalAmount, settledAmount: $settledAmount, forgivenAmount: $forgivenAmount, discountAmount: $discountAmount, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$InternalAccountSettlementModelCopyWith<$Res> implements $InternalAccountSettlementModelCopyWith<$Res> {
  factory _$InternalAccountSettlementModelCopyWith(_InternalAccountSettlementModel value, $Res Function(_InternalAccountSettlementModel) _then) = __$InternalAccountSettlementModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String internalAccountId, String settledByUserId, DateTime settledAt, int totalAmount, int settledAmount, int forgivenAmount, int discountAmount, String? note, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$InternalAccountSettlementModelCopyWithImpl<$Res>
    implements _$InternalAccountSettlementModelCopyWith<$Res> {
  __$InternalAccountSettlementModelCopyWithImpl(this._self, this._then);

  final _InternalAccountSettlementModel _self;
  final $Res Function(_InternalAccountSettlementModel) _then;

/// Create a copy of InternalAccountSettlementModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? internalAccountId = null,Object? settledByUserId = null,Object? settledAt = null,Object? totalAmount = null,Object? settledAmount = null,Object? forgivenAmount = null,Object? discountAmount = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_InternalAccountSettlementModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,internalAccountId: null == internalAccountId ? _self.internalAccountId : internalAccountId // ignore: cast_nullable_to_non_nullable
as String,settledByUserId: null == settledByUserId ? _self.settledByUserId : settledByUserId // ignore: cast_nullable_to_non_nullable
as String,settledAt: null == settledAt ? _self.settledAt : settledAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,settledAmount: null == settledAmount ? _self.settledAmount : settledAmount // ignore: cast_nullable_to_non_nullable
as int,forgivenAmount: null == forgivenAmount ? _self.forgivenAmount : forgivenAmount // ignore: cast_nullable_to_non_nullable
as int,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
