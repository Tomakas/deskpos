// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderModel {

 String get id; String get companyId; String get billId; String? get registerId; String get createdByUserId; String get orderNumber; String? get notes; PrepStatus get status; int get itemCount; int get subtotalGross; int get subtotalNet; int get taxTotal; bool get isStorno; String? get stornoSourceOrderId; DateTime? get prepStartedAt; DateTime? get readyAt; DateTime? get deliveredAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderModelCopyWith<OrderModel> get copyWith => _$OrderModelCopyWithImpl<OrderModel>(this as OrderModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.subtotalGross, subtotalGross) || other.subtotalGross == subtotalGross)&&(identical(other.subtotalNet, subtotalNet) || other.subtotalNet == subtotalNet)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.isStorno, isStorno) || other.isStorno == isStorno)&&(identical(other.stornoSourceOrderId, stornoSourceOrderId) || other.stornoSourceOrderId == stornoSourceOrderId)&&(identical(other.prepStartedAt, prepStartedAt) || other.prepStartedAt == prepStartedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,billId,registerId,createdByUserId,orderNumber,notes,status,itemCount,subtotalGross,subtotalNet,taxTotal,isStorno,stornoSourceOrderId,prepStartedAt,readyAt,deliveredAt,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'OrderModel(id: $id, companyId: $companyId, billId: $billId, registerId: $registerId, createdByUserId: $createdByUserId, orderNumber: $orderNumber, notes: $notes, status: $status, itemCount: $itemCount, subtotalGross: $subtotalGross, subtotalNet: $subtotalNet, taxTotal: $taxTotal, isStorno: $isStorno, stornoSourceOrderId: $stornoSourceOrderId, prepStartedAt: $prepStartedAt, readyAt: $readyAt, deliveredAt: $deliveredAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $OrderModelCopyWith<$Res>  {
  factory $OrderModelCopyWith(OrderModel value, $Res Function(OrderModel) _then) = _$OrderModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String billId, String? registerId, String createdByUserId, String orderNumber, String? notes, PrepStatus status, int itemCount, int subtotalGross, int subtotalNet, int taxTotal, bool isStorno, String? stornoSourceOrderId, DateTime? prepStartedAt, DateTime? readyAt, DateTime? deliveredAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$OrderModelCopyWithImpl<$Res>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._self, this._then);

  final OrderModel _self;
  final $Res Function(OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? billId = null,Object? registerId = freezed,Object? createdByUserId = null,Object? orderNumber = null,Object? notes = freezed,Object? status = null,Object? itemCount = null,Object? subtotalGross = null,Object? subtotalNet = null,Object? taxTotal = null,Object? isStorno = null,Object? stornoSourceOrderId = freezed,Object? prepStartedAt = freezed,Object? readyAt = freezed,Object? deliveredAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,billId: null == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String,registerId: freezed == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PrepStatus,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,subtotalGross: null == subtotalGross ? _self.subtotalGross : subtotalGross // ignore: cast_nullable_to_non_nullable
as int,subtotalNet: null == subtotalNet ? _self.subtotalNet : subtotalNet // ignore: cast_nullable_to_non_nullable
as int,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as int,isStorno: null == isStorno ? _self.isStorno : isStorno // ignore: cast_nullable_to_non_nullable
as bool,stornoSourceOrderId: freezed == stornoSourceOrderId ? _self.stornoSourceOrderId : stornoSourceOrderId // ignore: cast_nullable_to_non_nullable
as String?,prepStartedAt: freezed == prepStartedAt ? _self.prepStartedAt : prepStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readyAt: freezed == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderModel].
extension OrderModelPatterns on OrderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String billId,  String? registerId,  String createdByUserId,  String orderNumber,  String? notes,  PrepStatus status,  int itemCount,  int subtotalGross,  int subtotalNet,  int taxTotal,  bool isStorno,  String? stornoSourceOrderId,  DateTime? prepStartedAt,  DateTime? readyAt,  DateTime? deliveredAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.companyId,_that.billId,_that.registerId,_that.createdByUserId,_that.orderNumber,_that.notes,_that.status,_that.itemCount,_that.subtotalGross,_that.subtotalNet,_that.taxTotal,_that.isStorno,_that.stornoSourceOrderId,_that.prepStartedAt,_that.readyAt,_that.deliveredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String billId,  String? registerId,  String createdByUserId,  String orderNumber,  String? notes,  PrepStatus status,  int itemCount,  int subtotalGross,  int subtotalNet,  int taxTotal,  bool isStorno,  String? stornoSourceOrderId,  DateTime? prepStartedAt,  DateTime? readyAt,  DateTime? deliveredAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _OrderModel():
return $default(_that.id,_that.companyId,_that.billId,_that.registerId,_that.createdByUserId,_that.orderNumber,_that.notes,_that.status,_that.itemCount,_that.subtotalGross,_that.subtotalNet,_that.taxTotal,_that.isStorno,_that.stornoSourceOrderId,_that.prepStartedAt,_that.readyAt,_that.deliveredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String billId,  String? registerId,  String createdByUserId,  String orderNumber,  String? notes,  PrepStatus status,  int itemCount,  int subtotalGross,  int subtotalNet,  int taxTotal,  bool isStorno,  String? stornoSourceOrderId,  DateTime? prepStartedAt,  DateTime? readyAt,  DateTime? deliveredAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.companyId,_that.billId,_that.registerId,_that.createdByUserId,_that.orderNumber,_that.notes,_that.status,_that.itemCount,_that.subtotalGross,_that.subtotalNet,_that.taxTotal,_that.isStorno,_that.stornoSourceOrderId,_that.prepStartedAt,_that.readyAt,_that.deliveredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _OrderModel implements OrderModel {
  const _OrderModel({required this.id, required this.companyId, required this.billId, this.registerId, required this.createdByUserId, required this.orderNumber, this.notes, required this.status, this.itemCount = 0, this.subtotalGross = 0, this.subtotalNet = 0, this.taxTotal = 0, this.isStorno = false, this.stornoSourceOrderId, this.prepStartedAt, this.readyAt, this.deliveredAt, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String billId;
@override final  String? registerId;
@override final  String createdByUserId;
@override final  String orderNumber;
@override final  String? notes;
@override final  PrepStatus status;
@override@JsonKey() final  int itemCount;
@override@JsonKey() final  int subtotalGross;
@override@JsonKey() final  int subtotalNet;
@override@JsonKey() final  int taxTotal;
@override@JsonKey() final  bool isStorno;
@override final  String? stornoSourceOrderId;
@override final  DateTime? prepStartedAt;
@override final  DateTime? readyAt;
@override final  DateTime? deliveredAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderModelCopyWith<_OrderModel> get copyWith => __$OrderModelCopyWithImpl<_OrderModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.subtotalGross, subtotalGross) || other.subtotalGross == subtotalGross)&&(identical(other.subtotalNet, subtotalNet) || other.subtotalNet == subtotalNet)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.isStorno, isStorno) || other.isStorno == isStorno)&&(identical(other.stornoSourceOrderId, stornoSourceOrderId) || other.stornoSourceOrderId == stornoSourceOrderId)&&(identical(other.prepStartedAt, prepStartedAt) || other.prepStartedAt == prepStartedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,billId,registerId,createdByUserId,orderNumber,notes,status,itemCount,subtotalGross,subtotalNet,taxTotal,isStorno,stornoSourceOrderId,prepStartedAt,readyAt,deliveredAt,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'OrderModel(id: $id, companyId: $companyId, billId: $billId, registerId: $registerId, createdByUserId: $createdByUserId, orderNumber: $orderNumber, notes: $notes, status: $status, itemCount: $itemCount, subtotalGross: $subtotalGross, subtotalNet: $subtotalNet, taxTotal: $taxTotal, isStorno: $isStorno, stornoSourceOrderId: $stornoSourceOrderId, prepStartedAt: $prepStartedAt, readyAt: $readyAt, deliveredAt: $deliveredAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderModelCopyWith<$Res> implements $OrderModelCopyWith<$Res> {
  factory _$OrderModelCopyWith(_OrderModel value, $Res Function(_OrderModel) _then) = __$OrderModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String billId, String? registerId, String createdByUserId, String orderNumber, String? notes, PrepStatus status, int itemCount, int subtotalGross, int subtotalNet, int taxTotal, bool isStorno, String? stornoSourceOrderId, DateTime? prepStartedAt, DateTime? readyAt, DateTime? deliveredAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$OrderModelCopyWithImpl<$Res>
    implements _$OrderModelCopyWith<$Res> {
  __$OrderModelCopyWithImpl(this._self, this._then);

  final _OrderModel _self;
  final $Res Function(_OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? billId = null,Object? registerId = freezed,Object? createdByUserId = null,Object? orderNumber = null,Object? notes = freezed,Object? status = null,Object? itemCount = null,Object? subtotalGross = null,Object? subtotalNet = null,Object? taxTotal = null,Object? isStorno = null,Object? stornoSourceOrderId = freezed,Object? prepStartedAt = freezed,Object? readyAt = freezed,Object? deliveredAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_OrderModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,billId: null == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String,registerId: freezed == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PrepStatus,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,subtotalGross: null == subtotalGross ? _self.subtotalGross : subtotalGross // ignore: cast_nullable_to_non_nullable
as int,subtotalNet: null == subtotalNet ? _self.subtotalNet : subtotalNet // ignore: cast_nullable_to_non_nullable
as int,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as int,isStorno: null == isStorno ? _self.isStorno : isStorno // ignore: cast_nullable_to_non_nullable
as bool,stornoSourceOrderId: freezed == stornoSourceOrderId ? _self.stornoSourceOrderId : stornoSourceOrderId // ignore: cast_nullable_to_non_nullable
as String?,prepStartedAt: freezed == prepStartedAt ? _self.prepStartedAt : prepStartedAt // ignore: cast_nullable_to_non_nullable
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
