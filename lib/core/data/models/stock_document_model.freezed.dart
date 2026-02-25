// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_document_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StockDocumentModel {

 String get id; String get companyId; String get warehouseId; String? get supplierId; String get userId; String get documentNumber; StockDocumentType get type; PurchasePriceStrategy? get purchasePriceStrategy; String? get note; int get totalAmount; DateTime get documentDate; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of StockDocumentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockDocumentModelCopyWith<StockDocumentModel> get copyWith => _$StockDocumentModelCopyWithImpl<StockDocumentModel>(this as StockDocumentModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockDocumentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.documentNumber, documentNumber) || other.documentNumber == documentNumber)&&(identical(other.type, type) || other.type == type)&&(identical(other.purchasePriceStrategy, purchasePriceStrategy) || other.purchasePriceStrategy == purchasePriceStrategy)&&(identical(other.note, note) || other.note == note)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,warehouseId,supplierId,userId,documentNumber,type,purchasePriceStrategy,note,totalAmount,documentDate,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'StockDocumentModel(id: $id, companyId: $companyId, warehouseId: $warehouseId, supplierId: $supplierId, userId: $userId, documentNumber: $documentNumber, type: $type, purchasePriceStrategy: $purchasePriceStrategy, note: $note, totalAmount: $totalAmount, documentDate: $documentDate, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $StockDocumentModelCopyWith<$Res>  {
  factory $StockDocumentModelCopyWith(StockDocumentModel value, $Res Function(StockDocumentModel) _then) = _$StockDocumentModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String warehouseId, String? supplierId, String userId, String documentNumber, StockDocumentType type, PurchasePriceStrategy? purchasePriceStrategy, String? note, int totalAmount, DateTime documentDate, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$StockDocumentModelCopyWithImpl<$Res>
    implements $StockDocumentModelCopyWith<$Res> {
  _$StockDocumentModelCopyWithImpl(this._self, this._then);

  final StockDocumentModel _self;
  final $Res Function(StockDocumentModel) _then;

/// Create a copy of StockDocumentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? warehouseId = null,Object? supplierId = freezed,Object? userId = null,Object? documentNumber = null,Object? type = null,Object? purchasePriceStrategy = freezed,Object? note = freezed,Object? totalAmount = null,Object? documentDate = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,documentNumber: null == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as StockDocumentType,purchasePriceStrategy: freezed == purchasePriceStrategy ? _self.purchasePriceStrategy : purchasePriceStrategy // ignore: cast_nullable_to_non_nullable
as PurchasePriceStrategy?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,documentDate: null == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StockDocumentModel].
extension StockDocumentModelPatterns on StockDocumentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockDocumentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockDocumentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockDocumentModel value)  $default,){
final _that = this;
switch (_that) {
case _StockDocumentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockDocumentModel value)?  $default,){
final _that = this;
switch (_that) {
case _StockDocumentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String warehouseId,  String? supplierId,  String userId,  String documentNumber,  StockDocumentType type,  PurchasePriceStrategy? purchasePriceStrategy,  String? note,  int totalAmount,  DateTime documentDate,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockDocumentModel() when $default != null:
return $default(_that.id,_that.companyId,_that.warehouseId,_that.supplierId,_that.userId,_that.documentNumber,_that.type,_that.purchasePriceStrategy,_that.note,_that.totalAmount,_that.documentDate,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String warehouseId,  String? supplierId,  String userId,  String documentNumber,  StockDocumentType type,  PurchasePriceStrategy? purchasePriceStrategy,  String? note,  int totalAmount,  DateTime documentDate,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _StockDocumentModel():
return $default(_that.id,_that.companyId,_that.warehouseId,_that.supplierId,_that.userId,_that.documentNumber,_that.type,_that.purchasePriceStrategy,_that.note,_that.totalAmount,_that.documentDate,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String warehouseId,  String? supplierId,  String userId,  String documentNumber,  StockDocumentType type,  PurchasePriceStrategy? purchasePriceStrategy,  String? note,  int totalAmount,  DateTime documentDate,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _StockDocumentModel() when $default != null:
return $default(_that.id,_that.companyId,_that.warehouseId,_that.supplierId,_that.userId,_that.documentNumber,_that.type,_that.purchasePriceStrategy,_that.note,_that.totalAmount,_that.documentDate,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _StockDocumentModel implements StockDocumentModel {
  const _StockDocumentModel({required this.id, required this.companyId, required this.warehouseId, this.supplierId, required this.userId, required this.documentNumber, required this.type, this.purchasePriceStrategy, this.note, this.totalAmount = 0, required this.documentDate, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String warehouseId;
@override final  String? supplierId;
@override final  String userId;
@override final  String documentNumber;
@override final  StockDocumentType type;
@override final  PurchasePriceStrategy? purchasePriceStrategy;
@override final  String? note;
@override@JsonKey() final  int totalAmount;
@override final  DateTime documentDate;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of StockDocumentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockDocumentModelCopyWith<_StockDocumentModel> get copyWith => __$StockDocumentModelCopyWithImpl<_StockDocumentModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockDocumentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.documentNumber, documentNumber) || other.documentNumber == documentNumber)&&(identical(other.type, type) || other.type == type)&&(identical(other.purchasePriceStrategy, purchasePriceStrategy) || other.purchasePriceStrategy == purchasePriceStrategy)&&(identical(other.note, note) || other.note == note)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,warehouseId,supplierId,userId,documentNumber,type,purchasePriceStrategy,note,totalAmount,documentDate,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'StockDocumentModel(id: $id, companyId: $companyId, warehouseId: $warehouseId, supplierId: $supplierId, userId: $userId, documentNumber: $documentNumber, type: $type, purchasePriceStrategy: $purchasePriceStrategy, note: $note, totalAmount: $totalAmount, documentDate: $documentDate, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$StockDocumentModelCopyWith<$Res> implements $StockDocumentModelCopyWith<$Res> {
  factory _$StockDocumentModelCopyWith(_StockDocumentModel value, $Res Function(_StockDocumentModel) _then) = __$StockDocumentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String warehouseId, String? supplierId, String userId, String documentNumber, StockDocumentType type, PurchasePriceStrategy? purchasePriceStrategy, String? note, int totalAmount, DateTime documentDate, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$StockDocumentModelCopyWithImpl<$Res>
    implements _$StockDocumentModelCopyWith<$Res> {
  __$StockDocumentModelCopyWithImpl(this._self, this._then);

  final _StockDocumentModel _self;
  final $Res Function(_StockDocumentModel) _then;

/// Create a copy of StockDocumentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? warehouseId = null,Object? supplierId = freezed,Object? userId = null,Object? documentNumber = null,Object? type = null,Object? purchasePriceStrategy = freezed,Object? note = freezed,Object? totalAmount = null,Object? documentDate = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_StockDocumentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,documentNumber: null == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as StockDocumentType,purchasePriceStrategy: freezed == purchasePriceStrategy ? _self.purchasePriceStrategy : purchasePriceStrategy // ignore: cast_nullable_to_non_nullable
as PurchasePriceStrategy?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,documentDate: null == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
