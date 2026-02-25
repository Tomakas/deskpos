// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_item_modifier_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderItemModifierModel {

 String get id; String get companyId; String get orderItemId; String get modifierItemId; String get modifierGroupId; String get modifierItemName; double get quantity; int get unitPrice; int get taxRate; int get taxAmount; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of OrderItemModifierModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemModifierModelCopyWith<OrderItemModifierModel> get copyWith => _$OrderItemModifierModelCopyWithImpl<OrderItemModifierModel>(this as OrderItemModifierModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItemModifierModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.orderItemId, orderItemId) || other.orderItemId == orderItemId)&&(identical(other.modifierItemId, modifierItemId) || other.modifierItemId == modifierItemId)&&(identical(other.modifierGroupId, modifierGroupId) || other.modifierGroupId == modifierGroupId)&&(identical(other.modifierItemName, modifierItemName) || other.modifierItemName == modifierItemName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,orderItemId,modifierItemId,modifierGroupId,modifierItemName,quantity,unitPrice,taxRate,taxAmount,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'OrderItemModifierModel(id: $id, companyId: $companyId, orderItemId: $orderItemId, modifierItemId: $modifierItemId, modifierGroupId: $modifierGroupId, modifierItemName: $modifierItemName, quantity: $quantity, unitPrice: $unitPrice, taxRate: $taxRate, taxAmount: $taxAmount, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $OrderItemModifierModelCopyWith<$Res>  {
  factory $OrderItemModifierModelCopyWith(OrderItemModifierModel value, $Res Function(OrderItemModifierModel) _then) = _$OrderItemModifierModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String orderItemId, String modifierItemId, String modifierGroupId, String modifierItemName, double quantity, int unitPrice, int taxRate, int taxAmount, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$OrderItemModifierModelCopyWithImpl<$Res>
    implements $OrderItemModifierModelCopyWith<$Res> {
  _$OrderItemModifierModelCopyWithImpl(this._self, this._then);

  final OrderItemModifierModel _self;
  final $Res Function(OrderItemModifierModel) _then;

/// Create a copy of OrderItemModifierModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? orderItemId = null,Object? modifierItemId = null,Object? modifierGroupId = null,Object? modifierItemName = null,Object? quantity = null,Object? unitPrice = null,Object? taxRate = null,Object? taxAmount = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,orderItemId: null == orderItemId ? _self.orderItemId : orderItemId // ignore: cast_nullable_to_non_nullable
as String,modifierItemId: null == modifierItemId ? _self.modifierItemId : modifierItemId // ignore: cast_nullable_to_non_nullable
as String,modifierGroupId: null == modifierGroupId ? _self.modifierGroupId : modifierGroupId // ignore: cast_nullable_to_non_nullable
as String,modifierItemName: null == modifierItemName ? _self.modifierItemName : modifierItemName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as int,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItemModifierModel].
extension OrderItemModifierModelPatterns on OrderItemModifierModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItemModifierModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItemModifierModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItemModifierModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderItemModifierModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItemModifierModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItemModifierModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String orderItemId,  String modifierItemId,  String modifierGroupId,  String modifierItemName,  double quantity,  int unitPrice,  int taxRate,  int taxAmount,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItemModifierModel() when $default != null:
return $default(_that.id,_that.companyId,_that.orderItemId,_that.modifierItemId,_that.modifierGroupId,_that.modifierItemName,_that.quantity,_that.unitPrice,_that.taxRate,_that.taxAmount,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String orderItemId,  String modifierItemId,  String modifierGroupId,  String modifierItemName,  double quantity,  int unitPrice,  int taxRate,  int taxAmount,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _OrderItemModifierModel():
return $default(_that.id,_that.companyId,_that.orderItemId,_that.modifierItemId,_that.modifierGroupId,_that.modifierItemName,_that.quantity,_that.unitPrice,_that.taxRate,_that.taxAmount,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String orderItemId,  String modifierItemId,  String modifierGroupId,  String modifierItemName,  double quantity,  int unitPrice,  int taxRate,  int taxAmount,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderItemModifierModel() when $default != null:
return $default(_that.id,_that.companyId,_that.orderItemId,_that.modifierItemId,_that.modifierGroupId,_that.modifierItemName,_that.quantity,_that.unitPrice,_that.taxRate,_that.taxAmount,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _OrderItemModifierModel implements OrderItemModifierModel {
  const _OrderItemModifierModel({required this.id, required this.companyId, required this.orderItemId, required this.modifierItemId, required this.modifierGroupId, this.modifierItemName = '', this.quantity = 1.0, required this.unitPrice, required this.taxRate, required this.taxAmount, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String orderItemId;
@override final  String modifierItemId;
@override final  String modifierGroupId;
@override@JsonKey() final  String modifierItemName;
@override@JsonKey() final  double quantity;
@override final  int unitPrice;
@override final  int taxRate;
@override final  int taxAmount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of OrderItemModifierModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemModifierModelCopyWith<_OrderItemModifierModel> get copyWith => __$OrderItemModifierModelCopyWithImpl<_OrderItemModifierModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItemModifierModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.orderItemId, orderItemId) || other.orderItemId == orderItemId)&&(identical(other.modifierItemId, modifierItemId) || other.modifierItemId == modifierItemId)&&(identical(other.modifierGroupId, modifierGroupId) || other.modifierGroupId == modifierGroupId)&&(identical(other.modifierItemName, modifierItemName) || other.modifierItemName == modifierItemName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,orderItemId,modifierItemId,modifierGroupId,modifierItemName,quantity,unitPrice,taxRate,taxAmount,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'OrderItemModifierModel(id: $id, companyId: $companyId, orderItemId: $orderItemId, modifierItemId: $modifierItemId, modifierGroupId: $modifierGroupId, modifierItemName: $modifierItemName, quantity: $quantity, unitPrice: $unitPrice, taxRate: $taxRate, taxAmount: $taxAmount, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderItemModifierModelCopyWith<$Res> implements $OrderItemModifierModelCopyWith<$Res> {
  factory _$OrderItemModifierModelCopyWith(_OrderItemModifierModel value, $Res Function(_OrderItemModifierModel) _then) = __$OrderItemModifierModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String orderItemId, String modifierItemId, String modifierGroupId, String modifierItemName, double quantity, int unitPrice, int taxRate, int taxAmount, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$OrderItemModifierModelCopyWithImpl<$Res>
    implements _$OrderItemModifierModelCopyWith<$Res> {
  __$OrderItemModifierModelCopyWithImpl(this._self, this._then);

  final _OrderItemModifierModel _self;
  final $Res Function(_OrderItemModifierModel) _then;

/// Create a copy of OrderItemModifierModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? orderItemId = null,Object? modifierItemId = null,Object? modifierGroupId = null,Object? modifierItemName = null,Object? quantity = null,Object? unitPrice = null,Object? taxRate = null,Object? taxAmount = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_OrderItemModifierModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,orderItemId: null == orderItemId ? _self.orderItemId : orderItemId // ignore: cast_nullable_to_non_nullable
as String,modifierItemId: null == modifierItemId ? _self.modifierItemId : modifierItemId // ignore: cast_nullable_to_non_nullable
as String,modifierGroupId: null == modifierGroupId ? _self.modifierGroupId : modifierGroupId // ignore: cast_nullable_to_non_nullable
as String,modifierItemName: null == modifierItemName ? _self.modifierItemName : modifierItemName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as int,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
