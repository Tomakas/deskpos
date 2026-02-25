// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_modifier_group_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ItemModifierGroupModel {

 String get id; String get companyId; String get itemId; String get modifierGroupId; int get sortOrder; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of ItemModifierGroupModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemModifierGroupModelCopyWith<ItemModifierGroupModel> get copyWith => _$ItemModifierGroupModelCopyWithImpl<ItemModifierGroupModel>(this as ItemModifierGroupModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemModifierGroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.modifierGroupId, modifierGroupId) || other.modifierGroupId == modifierGroupId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,itemId,modifierGroupId,sortOrder,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ItemModifierGroupModel(id: $id, companyId: $companyId, itemId: $itemId, modifierGroupId: $modifierGroupId, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ItemModifierGroupModelCopyWith<$Res>  {
  factory $ItemModifierGroupModelCopyWith(ItemModifierGroupModel value, $Res Function(ItemModifierGroupModel) _then) = _$ItemModifierGroupModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String itemId, String modifierGroupId, int sortOrder, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$ItemModifierGroupModelCopyWithImpl<$Res>
    implements $ItemModifierGroupModelCopyWith<$Res> {
  _$ItemModifierGroupModelCopyWithImpl(this._self, this._then);

  final ItemModifierGroupModel _self;
  final $Res Function(ItemModifierGroupModel) _then;

/// Create a copy of ItemModifierGroupModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? itemId = null,Object? modifierGroupId = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,modifierGroupId: null == modifierGroupId ? _self.modifierGroupId : modifierGroupId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemModifierGroupModel].
extension ItemModifierGroupModelPatterns on ItemModifierGroupModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemModifierGroupModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemModifierGroupModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemModifierGroupModel value)  $default,){
final _that = this;
switch (_that) {
case _ItemModifierGroupModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemModifierGroupModel value)?  $default,){
final _that = this;
switch (_that) {
case _ItemModifierGroupModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String itemId,  String modifierGroupId,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemModifierGroupModel() when $default != null:
return $default(_that.id,_that.companyId,_that.itemId,_that.modifierGroupId,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String itemId,  String modifierGroupId,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _ItemModifierGroupModel():
return $default(_that.id,_that.companyId,_that.itemId,_that.modifierGroupId,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String itemId,  String modifierGroupId,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _ItemModifierGroupModel() when $default != null:
return $default(_that.id,_that.companyId,_that.itemId,_that.modifierGroupId,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ItemModifierGroupModel implements ItemModifierGroupModel {
  const _ItemModifierGroupModel({required this.id, required this.companyId, required this.itemId, required this.modifierGroupId, this.sortOrder = 0, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String itemId;
@override final  String modifierGroupId;
@override@JsonKey() final  int sortOrder;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of ItemModifierGroupModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemModifierGroupModelCopyWith<_ItemModifierGroupModel> get copyWith => __$ItemModifierGroupModelCopyWithImpl<_ItemModifierGroupModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemModifierGroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.modifierGroupId, modifierGroupId) || other.modifierGroupId == modifierGroupId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,itemId,modifierGroupId,sortOrder,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ItemModifierGroupModel(id: $id, companyId: $companyId, itemId: $itemId, modifierGroupId: $modifierGroupId, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemModifierGroupModelCopyWith<$Res> implements $ItemModifierGroupModelCopyWith<$Res> {
  factory _$ItemModifierGroupModelCopyWith(_ItemModifierGroupModel value, $Res Function(_ItemModifierGroupModel) _then) = __$ItemModifierGroupModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String itemId, String modifierGroupId, int sortOrder, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$ItemModifierGroupModelCopyWithImpl<$Res>
    implements _$ItemModifierGroupModelCopyWith<$Res> {
  __$ItemModifierGroupModelCopyWithImpl(this._self, this._then);

  final _ItemModifierGroupModel _self;
  final $Res Function(_ItemModifierGroupModel) _then;

/// Create a copy of ItemModifierGroupModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? itemId = null,Object? modifierGroupId = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_ItemModifierGroupModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,modifierGroupId: null == modifierGroupId ? _self.modifierGroupId : modifierGroupId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
