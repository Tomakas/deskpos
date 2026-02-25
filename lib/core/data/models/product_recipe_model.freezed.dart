// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_recipe_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductRecipeModel {

 String get id; String get companyId; String get parentProductId; String get componentProductId; double get quantityRequired; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of ProductRecipeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductRecipeModelCopyWith<ProductRecipeModel> get copyWith => _$ProductRecipeModelCopyWithImpl<ProductRecipeModel>(this as ProductRecipeModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductRecipeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.parentProductId, parentProductId) || other.parentProductId == parentProductId)&&(identical(other.componentProductId, componentProductId) || other.componentProductId == componentProductId)&&(identical(other.quantityRequired, quantityRequired) || other.quantityRequired == quantityRequired)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,parentProductId,componentProductId,quantityRequired,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ProductRecipeModel(id: $id, companyId: $companyId, parentProductId: $parentProductId, componentProductId: $componentProductId, quantityRequired: $quantityRequired, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ProductRecipeModelCopyWith<$Res>  {
  factory $ProductRecipeModelCopyWith(ProductRecipeModel value, $Res Function(ProductRecipeModel) _then) = _$ProductRecipeModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String parentProductId, String componentProductId, double quantityRequired, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$ProductRecipeModelCopyWithImpl<$Res>
    implements $ProductRecipeModelCopyWith<$Res> {
  _$ProductRecipeModelCopyWithImpl(this._self, this._then);

  final ProductRecipeModel _self;
  final $Res Function(ProductRecipeModel) _then;

/// Create a copy of ProductRecipeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? parentProductId = null,Object? componentProductId = null,Object? quantityRequired = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,parentProductId: null == parentProductId ? _self.parentProductId : parentProductId // ignore: cast_nullable_to_non_nullable
as String,componentProductId: null == componentProductId ? _self.componentProductId : componentProductId // ignore: cast_nullable_to_non_nullable
as String,quantityRequired: null == quantityRequired ? _self.quantityRequired : quantityRequired // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductRecipeModel].
extension ProductRecipeModelPatterns on ProductRecipeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductRecipeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductRecipeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductRecipeModel value)  $default,){
final _that = this;
switch (_that) {
case _ProductRecipeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductRecipeModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProductRecipeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String parentProductId,  String componentProductId,  double quantityRequired,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductRecipeModel() when $default != null:
return $default(_that.id,_that.companyId,_that.parentProductId,_that.componentProductId,_that.quantityRequired,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String parentProductId,  String componentProductId,  double quantityRequired,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _ProductRecipeModel():
return $default(_that.id,_that.companyId,_that.parentProductId,_that.componentProductId,_that.quantityRequired,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String parentProductId,  String componentProductId,  double quantityRequired,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductRecipeModel() when $default != null:
return $default(_that.id,_that.companyId,_that.parentProductId,_that.componentProductId,_that.quantityRequired,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ProductRecipeModel implements ProductRecipeModel {
  const _ProductRecipeModel({required this.id, required this.companyId, required this.parentProductId, required this.componentProductId, required this.quantityRequired, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String parentProductId;
@override final  String componentProductId;
@override final  double quantityRequired;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of ProductRecipeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductRecipeModelCopyWith<_ProductRecipeModel> get copyWith => __$ProductRecipeModelCopyWithImpl<_ProductRecipeModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductRecipeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.parentProductId, parentProductId) || other.parentProductId == parentProductId)&&(identical(other.componentProductId, componentProductId) || other.componentProductId == componentProductId)&&(identical(other.quantityRequired, quantityRequired) || other.quantityRequired == quantityRequired)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,parentProductId,componentProductId,quantityRequired,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ProductRecipeModel(id: $id, companyId: $companyId, parentProductId: $parentProductId, componentProductId: $componentProductId, quantityRequired: $quantityRequired, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductRecipeModelCopyWith<$Res> implements $ProductRecipeModelCopyWith<$Res> {
  factory _$ProductRecipeModelCopyWith(_ProductRecipeModel value, $Res Function(_ProductRecipeModel) _then) = __$ProductRecipeModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String parentProductId, String componentProductId, double quantityRequired, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$ProductRecipeModelCopyWithImpl<$Res>
    implements _$ProductRecipeModelCopyWith<$Res> {
  __$ProductRecipeModelCopyWithImpl(this._self, this._then);

  final _ProductRecipeModel _self;
  final $Res Function(_ProductRecipeModel) _then;

/// Create a copy of ProductRecipeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? parentProductId = null,Object? componentProductId = null,Object? quantityRequired = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_ProductRecipeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,parentProductId: null == parentProductId ? _self.parentProductId : parentProductId // ignore: cast_nullable_to_non_nullable
as String,componentProductId: null == componentProductId ? _self.componentProductId : componentProductId // ignore: cast_nullable_to_non_nullable
as String,quantityRequired: null == quantityRequired ? _self.quantityRequired : quantityRequired // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
