// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_movement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StockMovementModel {

 String get id; String get companyId; String? get stockDocumentId; String? get billId; String get itemId; double get quantity; int? get purchasePrice; StockMovementDirection get direction; PurchasePriceStrategy? get purchasePriceStrategy; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of StockMovementModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockMovementModelCopyWith<StockMovementModel> get copyWith => _$StockMovementModelCopyWithImpl<StockMovementModel>(this as StockMovementModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockMovementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.stockDocumentId, stockDocumentId) || other.stockDocumentId == stockDocumentId)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.purchasePriceStrategy, purchasePriceStrategy) || other.purchasePriceStrategy == purchasePriceStrategy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,stockDocumentId,billId,itemId,quantity,purchasePrice,direction,purchasePriceStrategy,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'StockMovementModel(id: $id, companyId: $companyId, stockDocumentId: $stockDocumentId, billId: $billId, itemId: $itemId, quantity: $quantity, purchasePrice: $purchasePrice, direction: $direction, purchasePriceStrategy: $purchasePriceStrategy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $StockMovementModelCopyWith<$Res>  {
  factory $StockMovementModelCopyWith(StockMovementModel value, $Res Function(StockMovementModel) _then) = _$StockMovementModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String? stockDocumentId, String? billId, String itemId, double quantity, int? purchasePrice, StockMovementDirection direction, PurchasePriceStrategy? purchasePriceStrategy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$StockMovementModelCopyWithImpl<$Res>
    implements $StockMovementModelCopyWith<$Res> {
  _$StockMovementModelCopyWithImpl(this._self, this._then);

  final StockMovementModel _self;
  final $Res Function(StockMovementModel) _then;

/// Create a copy of StockMovementModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? stockDocumentId = freezed,Object? billId = freezed,Object? itemId = null,Object? quantity = null,Object? purchasePrice = freezed,Object? direction = null,Object? purchasePriceStrategy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,stockDocumentId: freezed == stockDocumentId ? _self.stockDocumentId : stockDocumentId // ignore: cast_nullable_to_non_nullable
as String?,billId: freezed == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String?,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,purchasePrice: freezed == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as int?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as StockMovementDirection,purchasePriceStrategy: freezed == purchasePriceStrategy ? _self.purchasePriceStrategy : purchasePriceStrategy // ignore: cast_nullable_to_non_nullable
as PurchasePriceStrategy?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StockMovementModel].
extension StockMovementModelPatterns on StockMovementModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockMovementModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockMovementModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockMovementModel value)  $default,){
final _that = this;
switch (_that) {
case _StockMovementModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockMovementModel value)?  $default,){
final _that = this;
switch (_that) {
case _StockMovementModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String? stockDocumentId,  String? billId,  String itemId,  double quantity,  int? purchasePrice,  StockMovementDirection direction,  PurchasePriceStrategy? purchasePriceStrategy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockMovementModel() when $default != null:
return $default(_that.id,_that.companyId,_that.stockDocumentId,_that.billId,_that.itemId,_that.quantity,_that.purchasePrice,_that.direction,_that.purchasePriceStrategy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String? stockDocumentId,  String? billId,  String itemId,  double quantity,  int? purchasePrice,  StockMovementDirection direction,  PurchasePriceStrategy? purchasePriceStrategy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _StockMovementModel():
return $default(_that.id,_that.companyId,_that.stockDocumentId,_that.billId,_that.itemId,_that.quantity,_that.purchasePrice,_that.direction,_that.purchasePriceStrategy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String? stockDocumentId,  String? billId,  String itemId,  double quantity,  int? purchasePrice,  StockMovementDirection direction,  PurchasePriceStrategy? purchasePriceStrategy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _StockMovementModel() when $default != null:
return $default(_that.id,_that.companyId,_that.stockDocumentId,_that.billId,_that.itemId,_that.quantity,_that.purchasePrice,_that.direction,_that.purchasePriceStrategy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _StockMovementModel implements StockMovementModel {
  const _StockMovementModel({required this.id, required this.companyId, this.stockDocumentId, this.billId, required this.itemId, required this.quantity, this.purchasePrice, required this.direction, this.purchasePriceStrategy, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String? stockDocumentId;
@override final  String? billId;
@override final  String itemId;
@override final  double quantity;
@override final  int? purchasePrice;
@override final  StockMovementDirection direction;
@override final  PurchasePriceStrategy? purchasePriceStrategy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of StockMovementModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockMovementModelCopyWith<_StockMovementModel> get copyWith => __$StockMovementModelCopyWithImpl<_StockMovementModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockMovementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.stockDocumentId, stockDocumentId) || other.stockDocumentId == stockDocumentId)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.purchasePriceStrategy, purchasePriceStrategy) || other.purchasePriceStrategy == purchasePriceStrategy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,stockDocumentId,billId,itemId,quantity,purchasePrice,direction,purchasePriceStrategy,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'StockMovementModel(id: $id, companyId: $companyId, stockDocumentId: $stockDocumentId, billId: $billId, itemId: $itemId, quantity: $quantity, purchasePrice: $purchasePrice, direction: $direction, purchasePriceStrategy: $purchasePriceStrategy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$StockMovementModelCopyWith<$Res> implements $StockMovementModelCopyWith<$Res> {
  factory _$StockMovementModelCopyWith(_StockMovementModel value, $Res Function(_StockMovementModel) _then) = __$StockMovementModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String? stockDocumentId, String? billId, String itemId, double quantity, int? purchasePrice, StockMovementDirection direction, PurchasePriceStrategy? purchasePriceStrategy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$StockMovementModelCopyWithImpl<$Res>
    implements _$StockMovementModelCopyWith<$Res> {
  __$StockMovementModelCopyWithImpl(this._self, this._then);

  final _StockMovementModel _self;
  final $Res Function(_StockMovementModel) _then;

/// Create a copy of StockMovementModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? stockDocumentId = freezed,Object? billId = freezed,Object? itemId = null,Object? quantity = null,Object? purchasePrice = freezed,Object? direction = null,Object? purchasePriceStrategy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_StockMovementModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,stockDocumentId: freezed == stockDocumentId ? _self.stockDocumentId : stockDocumentId // ignore: cast_nullable_to_non_nullable
as String?,billId: freezed == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String?,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,purchasePrice: freezed == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as int?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as StockMovementDirection,purchasePriceStrategy: freezed == purchasePriceStrategy ? _self.purchasePriceStrategy : purchasePriceStrategy // ignore: cast_nullable_to_non_nullable
as PurchasePriceStrategy?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
