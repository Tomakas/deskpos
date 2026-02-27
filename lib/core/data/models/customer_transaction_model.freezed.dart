// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomerTransactionModel {

 String get id; String get companyId; String get customerId; int get pointsChange; int get creditChange; String? get orderId; String? get reference; String? get note; String get processedByUserId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of CustomerTransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerTransactionModelCopyWith<CustomerTransactionModel> get copyWith => _$CustomerTransactionModelCopyWithImpl<CustomerTransactionModel>(this as CustomerTransactionModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerTransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.pointsChange, pointsChange) || other.pointsChange == pointsChange)&&(identical(other.creditChange, creditChange) || other.creditChange == creditChange)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.note, note) || other.note == note)&&(identical(other.processedByUserId, processedByUserId) || other.processedByUserId == processedByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,customerId,pointsChange,creditChange,orderId,reference,note,processedByUserId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'CustomerTransactionModel(id: $id, companyId: $companyId, customerId: $customerId, pointsChange: $pointsChange, creditChange: $creditChange, orderId: $orderId, reference: $reference, note: $note, processedByUserId: $processedByUserId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $CustomerTransactionModelCopyWith<$Res>  {
  factory $CustomerTransactionModelCopyWith(CustomerTransactionModel value, $Res Function(CustomerTransactionModel) _then) = _$CustomerTransactionModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String customerId, int pointsChange, int creditChange, String? orderId, String? reference, String? note, String processedByUserId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$CustomerTransactionModelCopyWithImpl<$Res>
    implements $CustomerTransactionModelCopyWith<$Res> {
  _$CustomerTransactionModelCopyWithImpl(this._self, this._then);

  final CustomerTransactionModel _self;
  final $Res Function(CustomerTransactionModel) _then;

/// Create a copy of CustomerTransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? customerId = null,Object? pointsChange = null,Object? creditChange = null,Object? orderId = freezed,Object? reference = freezed,Object? note = freezed,Object? processedByUserId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,pointsChange: null == pointsChange ? _self.pointsChange : pointsChange // ignore: cast_nullable_to_non_nullable
as int,creditChange: null == creditChange ? _self.creditChange : creditChange // ignore: cast_nullable_to_non_nullable
as int,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,processedByUserId: null == processedByUserId ? _self.processedByUserId : processedByUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerTransactionModel].
extension CustomerTransactionModelPatterns on CustomerTransactionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerTransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerTransactionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerTransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _CustomerTransactionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerTransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerTransactionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String customerId,  int pointsChange,  int creditChange,  String? orderId,  String? reference,  String? note,  String processedByUserId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerTransactionModel() when $default != null:
return $default(_that.id,_that.companyId,_that.customerId,_that.pointsChange,_that.creditChange,_that.orderId,_that.reference,_that.note,_that.processedByUserId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String customerId,  int pointsChange,  int creditChange,  String? orderId,  String? reference,  String? note,  String processedByUserId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _CustomerTransactionModel():
return $default(_that.id,_that.companyId,_that.customerId,_that.pointsChange,_that.creditChange,_that.orderId,_that.reference,_that.note,_that.processedByUserId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String customerId,  int pointsChange,  int creditChange,  String? orderId,  String? reference,  String? note,  String processedByUserId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _CustomerTransactionModel() when $default != null:
return $default(_that.id,_that.companyId,_that.customerId,_that.pointsChange,_that.creditChange,_that.orderId,_that.reference,_that.note,_that.processedByUserId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerTransactionModel implements CustomerTransactionModel {
  const _CustomerTransactionModel({required this.id, required this.companyId, required this.customerId, required this.pointsChange, required this.creditChange, this.orderId, this.reference, this.note, required this.processedByUserId, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String customerId;
@override final  int pointsChange;
@override final  int creditChange;
@override final  String? orderId;
@override final  String? reference;
@override final  String? note;
@override final  String processedByUserId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of CustomerTransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerTransactionModelCopyWith<_CustomerTransactionModel> get copyWith => __$CustomerTransactionModelCopyWithImpl<_CustomerTransactionModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerTransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.pointsChange, pointsChange) || other.pointsChange == pointsChange)&&(identical(other.creditChange, creditChange) || other.creditChange == creditChange)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.note, note) || other.note == note)&&(identical(other.processedByUserId, processedByUserId) || other.processedByUserId == processedByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,customerId,pointsChange,creditChange,orderId,reference,note,processedByUserId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'CustomerTransactionModel(id: $id, companyId: $companyId, customerId: $customerId, pointsChange: $pointsChange, creditChange: $creditChange, orderId: $orderId, reference: $reference, note: $note, processedByUserId: $processedByUserId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$CustomerTransactionModelCopyWith<$Res> implements $CustomerTransactionModelCopyWith<$Res> {
  factory _$CustomerTransactionModelCopyWith(_CustomerTransactionModel value, $Res Function(_CustomerTransactionModel) _then) = __$CustomerTransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String customerId, int pointsChange, int creditChange, String? orderId, String? reference, String? note, String processedByUserId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$CustomerTransactionModelCopyWithImpl<$Res>
    implements _$CustomerTransactionModelCopyWith<$Res> {
  __$CustomerTransactionModelCopyWithImpl(this._self, this._then);

  final _CustomerTransactionModel _self;
  final $Res Function(_CustomerTransactionModel) _then;

/// Create a copy of CustomerTransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? customerId = null,Object? pointsChange = null,Object? creditChange = null,Object? orderId = freezed,Object? reference = freezed,Object? note = freezed,Object? processedByUserId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_CustomerTransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,pointsChange: null == pointsChange ? _self.pointsChange : pointsChange // ignore: cast_nullable_to_non_nullable
as int,creditChange: null == creditChange ? _self.creditChange : creditChange // ignore: cast_nullable_to_non_nullable
as int,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,processedByUserId: null == processedByUserId ? _self.processedByUserId : processedByUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
