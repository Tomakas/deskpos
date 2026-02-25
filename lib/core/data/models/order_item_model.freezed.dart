// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderItemModel {

 String get id; String get companyId; String get orderId; String get itemId; String get itemName; double get quantity; int get salePriceAtt; int get saleTaxRateAtt; int get saleTaxAmount; UnitType get unit; int get discount; DiscountType? get discountType; int get voucherDiscount; String? get notes; PrepStatus get status; DateTime? get prepStartedAt; DateTime? get readyAt; DateTime? get deliveredAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemModelCopyWith<OrderItemModel> get copyWith => _$OrderItemModelCopyWithImpl<OrderItemModel>(this as OrderItemModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.salePriceAtt, salePriceAtt) || other.salePriceAtt == salePriceAtt)&&(identical(other.saleTaxRateAtt, saleTaxRateAtt) || other.saleTaxRateAtt == saleTaxRateAtt)&&(identical(other.saleTaxAmount, saleTaxAmount) || other.saleTaxAmount == saleTaxAmount)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.voucherDiscount, voucherDiscount) || other.voucherDiscount == voucherDiscount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.prepStartedAt, prepStartedAt) || other.prepStartedAt == prepStartedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,orderId,itemId,itemName,quantity,salePriceAtt,saleTaxRateAtt,saleTaxAmount,unit,discount,discountType,voucherDiscount,notes,status,prepStartedAt,readyAt,deliveredAt,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'OrderItemModel(id: $id, companyId: $companyId, orderId: $orderId, itemId: $itemId, itemName: $itemName, quantity: $quantity, salePriceAtt: $salePriceAtt, saleTaxRateAtt: $saleTaxRateAtt, saleTaxAmount: $saleTaxAmount, unit: $unit, discount: $discount, discountType: $discountType, voucherDiscount: $voucherDiscount, notes: $notes, status: $status, prepStartedAt: $prepStartedAt, readyAt: $readyAt, deliveredAt: $deliveredAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $OrderItemModelCopyWith<$Res>  {
  factory $OrderItemModelCopyWith(OrderItemModel value, $Res Function(OrderItemModel) _then) = _$OrderItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String orderId, String itemId, String itemName, double quantity, int salePriceAtt, int saleTaxRateAtt, int saleTaxAmount, UnitType unit, int discount, DiscountType? discountType, int voucherDiscount, String? notes, PrepStatus status, DateTime? prepStartedAt, DateTime? readyAt, DateTime? deliveredAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$OrderItemModelCopyWithImpl<$Res>
    implements $OrderItemModelCopyWith<$Res> {
  _$OrderItemModelCopyWithImpl(this._self, this._then);

  final OrderItemModel _self;
  final $Res Function(OrderItemModel) _then;

/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? orderId = null,Object? itemId = null,Object? itemName = null,Object? quantity = null,Object? salePriceAtt = null,Object? saleTaxRateAtt = null,Object? saleTaxAmount = null,Object? unit = null,Object? discount = null,Object? discountType = freezed,Object? voucherDiscount = null,Object? notes = freezed,Object? status = null,Object? prepStartedAt = freezed,Object? readyAt = freezed,Object? deliveredAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,salePriceAtt: null == salePriceAtt ? _self.salePriceAtt : salePriceAtt // ignore: cast_nullable_to_non_nullable
as int,saleTaxRateAtt: null == saleTaxRateAtt ? _self.saleTaxRateAtt : saleTaxRateAtt // ignore: cast_nullable_to_non_nullable
as int,saleTaxAmount: null == saleTaxAmount ? _self.saleTaxAmount : saleTaxAmount // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as UnitType,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as int,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as DiscountType?,voucherDiscount: null == voucherDiscount ? _self.voucherDiscount : voucherDiscount // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PrepStatus,prepStartedAt: freezed == prepStartedAt ? _self.prepStartedAt : prepStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readyAt: freezed == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItemModel].
extension OrderItemModelPatterns on OrderItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItemModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String orderId,  String itemId,  String itemName,  double quantity,  int salePriceAtt,  int saleTaxRateAtt,  int saleTaxAmount,  UnitType unit,  int discount,  DiscountType? discountType,  int voucherDiscount,  String? notes,  PrepStatus status,  DateTime? prepStartedAt,  DateTime? readyAt,  DateTime? deliveredAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
return $default(_that.id,_that.companyId,_that.orderId,_that.itemId,_that.itemName,_that.quantity,_that.salePriceAtt,_that.saleTaxRateAtt,_that.saleTaxAmount,_that.unit,_that.discount,_that.discountType,_that.voucherDiscount,_that.notes,_that.status,_that.prepStartedAt,_that.readyAt,_that.deliveredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String orderId,  String itemId,  String itemName,  double quantity,  int salePriceAtt,  int saleTaxRateAtt,  int saleTaxAmount,  UnitType unit,  int discount,  DiscountType? discountType,  int voucherDiscount,  String? notes,  PrepStatus status,  DateTime? prepStartedAt,  DateTime? readyAt,  DateTime? deliveredAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _OrderItemModel():
return $default(_that.id,_that.companyId,_that.orderId,_that.itemId,_that.itemName,_that.quantity,_that.salePriceAtt,_that.saleTaxRateAtt,_that.saleTaxAmount,_that.unit,_that.discount,_that.discountType,_that.voucherDiscount,_that.notes,_that.status,_that.prepStartedAt,_that.readyAt,_that.deliveredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String orderId,  String itemId,  String itemName,  double quantity,  int salePriceAtt,  int saleTaxRateAtt,  int saleTaxAmount,  UnitType unit,  int discount,  DiscountType? discountType,  int voucherDiscount,  String? notes,  PrepStatus status,  DateTime? prepStartedAt,  DateTime? readyAt,  DateTime? deliveredAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
return $default(_that.id,_that.companyId,_that.orderId,_that.itemId,_that.itemName,_that.quantity,_that.salePriceAtt,_that.saleTaxRateAtt,_that.saleTaxAmount,_that.unit,_that.discount,_that.discountType,_that.voucherDiscount,_that.notes,_that.status,_that.prepStartedAt,_that.readyAt,_that.deliveredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _OrderItemModel implements OrderItemModel {
  const _OrderItemModel({required this.id, required this.companyId, required this.orderId, required this.itemId, required this.itemName, required this.quantity, required this.salePriceAtt, required this.saleTaxRateAtt, required this.saleTaxAmount, this.unit = UnitType.ks, this.discount = 0, this.discountType, this.voucherDiscount = 0, this.notes, required this.status, this.prepStartedAt, this.readyAt, this.deliveredAt, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String orderId;
@override final  String itemId;
@override final  String itemName;
@override final  double quantity;
@override final  int salePriceAtt;
@override final  int saleTaxRateAtt;
@override final  int saleTaxAmount;
@override@JsonKey() final  UnitType unit;
@override@JsonKey() final  int discount;
@override final  DiscountType? discountType;
@override@JsonKey() final  int voucherDiscount;
@override final  String? notes;
@override final  PrepStatus status;
@override final  DateTime? prepStartedAt;
@override final  DateTime? readyAt;
@override final  DateTime? deliveredAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemModelCopyWith<_OrderItemModel> get copyWith => __$OrderItemModelCopyWithImpl<_OrderItemModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.salePriceAtt, salePriceAtt) || other.salePriceAtt == salePriceAtt)&&(identical(other.saleTaxRateAtt, saleTaxRateAtt) || other.saleTaxRateAtt == saleTaxRateAtt)&&(identical(other.saleTaxAmount, saleTaxAmount) || other.saleTaxAmount == saleTaxAmount)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.voucherDiscount, voucherDiscount) || other.voucherDiscount == voucherDiscount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.prepStartedAt, prepStartedAt) || other.prepStartedAt == prepStartedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,orderId,itemId,itemName,quantity,salePriceAtt,saleTaxRateAtt,saleTaxAmount,unit,discount,discountType,voucherDiscount,notes,status,prepStartedAt,readyAt,deliveredAt,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'OrderItemModel(id: $id, companyId: $companyId, orderId: $orderId, itemId: $itemId, itemName: $itemName, quantity: $quantity, salePriceAtt: $salePriceAtt, saleTaxRateAtt: $saleTaxRateAtt, saleTaxAmount: $saleTaxAmount, unit: $unit, discount: $discount, discountType: $discountType, voucherDiscount: $voucherDiscount, notes: $notes, status: $status, prepStartedAt: $prepStartedAt, readyAt: $readyAt, deliveredAt: $deliveredAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderItemModelCopyWith<$Res> implements $OrderItemModelCopyWith<$Res> {
  factory _$OrderItemModelCopyWith(_OrderItemModel value, $Res Function(_OrderItemModel) _then) = __$OrderItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String orderId, String itemId, String itemName, double quantity, int salePriceAtt, int saleTaxRateAtt, int saleTaxAmount, UnitType unit, int discount, DiscountType? discountType, int voucherDiscount, String? notes, PrepStatus status, DateTime? prepStartedAt, DateTime? readyAt, DateTime? deliveredAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$OrderItemModelCopyWithImpl<$Res>
    implements _$OrderItemModelCopyWith<$Res> {
  __$OrderItemModelCopyWithImpl(this._self, this._then);

  final _OrderItemModel _self;
  final $Res Function(_OrderItemModel) _then;

/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? orderId = null,Object? itemId = null,Object? itemName = null,Object? quantity = null,Object? salePriceAtt = null,Object? saleTaxRateAtt = null,Object? saleTaxAmount = null,Object? unit = null,Object? discount = null,Object? discountType = freezed,Object? voucherDiscount = null,Object? notes = freezed,Object? status = null,Object? prepStartedAt = freezed,Object? readyAt = freezed,Object? deliveredAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_OrderItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,salePriceAtt: null == salePriceAtt ? _self.salePriceAtt : salePriceAtt // ignore: cast_nullable_to_non_nullable
as int,saleTaxRateAtt: null == saleTaxRateAtt ? _self.saleTaxRateAtt : saleTaxRateAtt // ignore: cast_nullable_to_non_nullable
as int,saleTaxAmount: null == saleTaxAmount ? _self.saleTaxAmount : saleTaxAmount // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as UnitType,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as int,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as DiscountType?,voucherDiscount: null == voucherDiscount ? _self.voucherDiscount : voucherDiscount // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PrepStatus,prepStartedAt: freezed == prepStartedAt ? _self.prepStartedAt : prepStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readyAt: freezed == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
