// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ItemModel {

 String get id; String get companyId; String? get categoryId; String get name; String? get description; ItemType get itemType; String? get sku; int get unitPrice; String? get saleTaxRateId; bool get isSellable; bool get isActive; UnitType get unit; String? get altSku; int? get purchasePrice; String? get purchaseTaxRateId; bool get isOnSale; bool get isStockTracked; String? get manufacturerId; String? get supplierId; String? get parentId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemModelCopyWith<ItemModel> get copyWith => _$ItemModelCopyWithImpl<ItemModel>(this as ItemModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.saleTaxRateId, saleTaxRateId) || other.saleTaxRateId == saleTaxRateId)&&(identical(other.isSellable, isSellable) || other.isSellable == isSellable)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.altSku, altSku) || other.altSku == altSku)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.purchaseTaxRateId, purchaseTaxRateId) || other.purchaseTaxRateId == purchaseTaxRateId)&&(identical(other.isOnSale, isOnSale) || other.isOnSale == isOnSale)&&(identical(other.isStockTracked, isStockTracked) || other.isStockTracked == isStockTracked)&&(identical(other.manufacturerId, manufacturerId) || other.manufacturerId == manufacturerId)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,categoryId,name,description,itemType,sku,unitPrice,saleTaxRateId,isSellable,isActive,unit,altSku,purchasePrice,purchaseTaxRateId,isOnSale,isStockTracked,manufacturerId,supplierId,parentId,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'ItemModel(id: $id, companyId: $companyId, categoryId: $categoryId, name: $name, description: $description, itemType: $itemType, sku: $sku, unitPrice: $unitPrice, saleTaxRateId: $saleTaxRateId, isSellable: $isSellable, isActive: $isActive, unit: $unit, altSku: $altSku, purchasePrice: $purchasePrice, purchaseTaxRateId: $purchaseTaxRateId, isOnSale: $isOnSale, isStockTracked: $isStockTracked, manufacturerId: $manufacturerId, supplierId: $supplierId, parentId: $parentId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ItemModelCopyWith<$Res>  {
  factory $ItemModelCopyWith(ItemModel value, $Res Function(ItemModel) _then) = _$ItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String? categoryId, String name, String? description, ItemType itemType, String? sku, int unitPrice, String? saleTaxRateId, bool isSellable, bool isActive, UnitType unit, String? altSku, int? purchasePrice, String? purchaseTaxRateId, bool isOnSale, bool isStockTracked, String? manufacturerId, String? supplierId, String? parentId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$ItemModelCopyWithImpl<$Res>
    implements $ItemModelCopyWith<$Res> {
  _$ItemModelCopyWithImpl(this._self, this._then);

  final ItemModel _self;
  final $Res Function(ItemModel) _then;

/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? categoryId = freezed,Object? name = null,Object? description = freezed,Object? itemType = null,Object? sku = freezed,Object? unitPrice = null,Object? saleTaxRateId = freezed,Object? isSellable = null,Object? isActive = null,Object? unit = null,Object? altSku = freezed,Object? purchasePrice = freezed,Object? purchaseTaxRateId = freezed,Object? isOnSale = null,Object? isStockTracked = null,Object? manufacturerId = freezed,Object? supplierId = freezed,Object? parentId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as ItemType,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,saleTaxRateId: freezed == saleTaxRateId ? _self.saleTaxRateId : saleTaxRateId // ignore: cast_nullable_to_non_nullable
as String?,isSellable: null == isSellable ? _self.isSellable : isSellable // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as UnitType,altSku: freezed == altSku ? _self.altSku : altSku // ignore: cast_nullable_to_non_nullable
as String?,purchasePrice: freezed == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as int?,purchaseTaxRateId: freezed == purchaseTaxRateId ? _self.purchaseTaxRateId : purchaseTaxRateId // ignore: cast_nullable_to_non_nullable
as String?,isOnSale: null == isOnSale ? _self.isOnSale : isOnSale // ignore: cast_nullable_to_non_nullable
as bool,isStockTracked: null == isStockTracked ? _self.isStockTracked : isStockTracked // ignore: cast_nullable_to_non_nullable
as bool,manufacturerId: freezed == manufacturerId ? _self.manufacturerId : manufacturerId // ignore: cast_nullable_to_non_nullable
as String?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemModel].
extension ItemModelPatterns on ItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemModel value)  $default,){
final _that = this;
switch (_that) {
case _ItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String? categoryId,  String name,  String? description,  ItemType itemType,  String? sku,  int unitPrice,  String? saleTaxRateId,  bool isSellable,  bool isActive,  UnitType unit,  String? altSku,  int? purchasePrice,  String? purchaseTaxRateId,  bool isOnSale,  bool isStockTracked,  String? manufacturerId,  String? supplierId,  String? parentId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
return $default(_that.id,_that.companyId,_that.categoryId,_that.name,_that.description,_that.itemType,_that.sku,_that.unitPrice,_that.saleTaxRateId,_that.isSellable,_that.isActive,_that.unit,_that.altSku,_that.purchasePrice,_that.purchaseTaxRateId,_that.isOnSale,_that.isStockTracked,_that.manufacturerId,_that.supplierId,_that.parentId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String? categoryId,  String name,  String? description,  ItemType itemType,  String? sku,  int unitPrice,  String? saleTaxRateId,  bool isSellable,  bool isActive,  UnitType unit,  String? altSku,  int? purchasePrice,  String? purchaseTaxRateId,  bool isOnSale,  bool isStockTracked,  String? manufacturerId,  String? supplierId,  String? parentId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _ItemModel():
return $default(_that.id,_that.companyId,_that.categoryId,_that.name,_that.description,_that.itemType,_that.sku,_that.unitPrice,_that.saleTaxRateId,_that.isSellable,_that.isActive,_that.unit,_that.altSku,_that.purchasePrice,_that.purchaseTaxRateId,_that.isOnSale,_that.isStockTracked,_that.manufacturerId,_that.supplierId,_that.parentId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String? categoryId,  String name,  String? description,  ItemType itemType,  String? sku,  int unitPrice,  String? saleTaxRateId,  bool isSellable,  bool isActive,  UnitType unit,  String? altSku,  int? purchasePrice,  String? purchaseTaxRateId,  bool isOnSale,  bool isStockTracked,  String? manufacturerId,  String? supplierId,  String? parentId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
return $default(_that.id,_that.companyId,_that.categoryId,_that.name,_that.description,_that.itemType,_that.sku,_that.unitPrice,_that.saleTaxRateId,_that.isSellable,_that.isActive,_that.unit,_that.altSku,_that.purchasePrice,_that.purchaseTaxRateId,_that.isOnSale,_that.isStockTracked,_that.manufacturerId,_that.supplierId,_that.parentId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ItemModel implements ItemModel {
  const _ItemModel({required this.id, required this.companyId, this.categoryId, required this.name, this.description, required this.itemType, this.sku, required this.unitPrice, this.saleTaxRateId, this.isSellable = true, this.isActive = true, required this.unit, this.altSku, this.purchasePrice, this.purchaseTaxRateId, this.isOnSale = true, this.isStockTracked = false, this.manufacturerId, this.supplierId, this.parentId, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String? categoryId;
@override final  String name;
@override final  String? description;
@override final  ItemType itemType;
@override final  String? sku;
@override final  int unitPrice;
@override final  String? saleTaxRateId;
@override@JsonKey() final  bool isSellable;
@override@JsonKey() final  bool isActive;
@override final  UnitType unit;
@override final  String? altSku;
@override final  int? purchasePrice;
@override final  String? purchaseTaxRateId;
@override@JsonKey() final  bool isOnSale;
@override@JsonKey() final  bool isStockTracked;
@override final  String? manufacturerId;
@override final  String? supplierId;
@override final  String? parentId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemModelCopyWith<_ItemModel> get copyWith => __$ItemModelCopyWithImpl<_ItemModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.saleTaxRateId, saleTaxRateId) || other.saleTaxRateId == saleTaxRateId)&&(identical(other.isSellable, isSellable) || other.isSellable == isSellable)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.altSku, altSku) || other.altSku == altSku)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.purchaseTaxRateId, purchaseTaxRateId) || other.purchaseTaxRateId == purchaseTaxRateId)&&(identical(other.isOnSale, isOnSale) || other.isOnSale == isOnSale)&&(identical(other.isStockTracked, isStockTracked) || other.isStockTracked == isStockTracked)&&(identical(other.manufacturerId, manufacturerId) || other.manufacturerId == manufacturerId)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,categoryId,name,description,itemType,sku,unitPrice,saleTaxRateId,isSellable,isActive,unit,altSku,purchasePrice,purchaseTaxRateId,isOnSale,isStockTracked,manufacturerId,supplierId,parentId,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'ItemModel(id: $id, companyId: $companyId, categoryId: $categoryId, name: $name, description: $description, itemType: $itemType, sku: $sku, unitPrice: $unitPrice, saleTaxRateId: $saleTaxRateId, isSellable: $isSellable, isActive: $isActive, unit: $unit, altSku: $altSku, purchasePrice: $purchasePrice, purchaseTaxRateId: $purchaseTaxRateId, isOnSale: $isOnSale, isStockTracked: $isStockTracked, manufacturerId: $manufacturerId, supplierId: $supplierId, parentId: $parentId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemModelCopyWith<$Res> implements $ItemModelCopyWith<$Res> {
  factory _$ItemModelCopyWith(_ItemModel value, $Res Function(_ItemModel) _then) = __$ItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String? categoryId, String name, String? description, ItemType itemType, String? sku, int unitPrice, String? saleTaxRateId, bool isSellable, bool isActive, UnitType unit, String? altSku, int? purchasePrice, String? purchaseTaxRateId, bool isOnSale, bool isStockTracked, String? manufacturerId, String? supplierId, String? parentId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$ItemModelCopyWithImpl<$Res>
    implements _$ItemModelCopyWith<$Res> {
  __$ItemModelCopyWithImpl(this._self, this._then);

  final _ItemModel _self;
  final $Res Function(_ItemModel) _then;

/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? categoryId = freezed,Object? name = null,Object? description = freezed,Object? itemType = null,Object? sku = freezed,Object? unitPrice = null,Object? saleTaxRateId = freezed,Object? isSellable = null,Object? isActive = null,Object? unit = null,Object? altSku = freezed,Object? purchasePrice = freezed,Object? purchaseTaxRateId = freezed,Object? isOnSale = null,Object? isStockTracked = null,Object? manufacturerId = freezed,Object? supplierId = freezed,Object? parentId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_ItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as ItemType,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,saleTaxRateId: freezed == saleTaxRateId ? _self.saleTaxRateId : saleTaxRateId // ignore: cast_nullable_to_non_nullable
as String?,isSellable: null == isSellable ? _self.isSellable : isSellable // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as UnitType,altSku: freezed == altSku ? _self.altSku : altSku // ignore: cast_nullable_to_non_nullable
as String?,purchasePrice: freezed == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as int?,purchaseTaxRateId: freezed == purchaseTaxRateId ? _self.purchaseTaxRateId : purchaseTaxRateId // ignore: cast_nullable_to_non_nullable
as String?,isOnSale: null == isOnSale ? _self.isOnSale : isOnSale // ignore: cast_nullable_to_non_nullable
as bool,isStockTracked: null == isStockTracked ? _self.isStockTracked : isStockTracked // ignore: cast_nullable_to_non_nullable
as bool,manufacturerId: freezed == manufacturerId ? _self.manufacturerId : manufacturerId // ignore: cast_nullable_to_non_nullable
as String?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
