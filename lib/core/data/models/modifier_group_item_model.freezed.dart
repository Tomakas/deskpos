// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'modifier_group_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ModifierGroupItemModel {

 String get id; String get companyId; String get modifierGroupId; String get itemId; int get sortOrder; bool get isDefault; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of ModifierGroupItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModifierGroupItemModelCopyWith<ModifierGroupItemModel> get copyWith => _$ModifierGroupItemModelCopyWithImpl<ModifierGroupItemModel>(this as ModifierGroupItemModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModifierGroupItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.modifierGroupId, modifierGroupId) || other.modifierGroupId == modifierGroupId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,modifierGroupId,itemId,sortOrder,isDefault,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ModifierGroupItemModel(id: $id, companyId: $companyId, modifierGroupId: $modifierGroupId, itemId: $itemId, sortOrder: $sortOrder, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ModifierGroupItemModelCopyWith<$Res>  {
  factory $ModifierGroupItemModelCopyWith(ModifierGroupItemModel value, $Res Function(ModifierGroupItemModel) _then) = _$ModifierGroupItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String modifierGroupId, String itemId, int sortOrder, bool isDefault, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$ModifierGroupItemModelCopyWithImpl<$Res>
    implements $ModifierGroupItemModelCopyWith<$Res> {
  _$ModifierGroupItemModelCopyWithImpl(this._self, this._then);

  final ModifierGroupItemModel _self;
  final $Res Function(ModifierGroupItemModel) _then;

/// Create a copy of ModifierGroupItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? modifierGroupId = null,Object? itemId = null,Object? sortOrder = null,Object? isDefault = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,modifierGroupId: null == modifierGroupId ? _self.modifierGroupId : modifierGroupId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModifierGroupItemModel].
extension ModifierGroupItemModelPatterns on ModifierGroupItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModifierGroupItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModifierGroupItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModifierGroupItemModel value)  $default,){
final _that = this;
switch (_that) {
case _ModifierGroupItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModifierGroupItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _ModifierGroupItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String modifierGroupId,  String itemId,  int sortOrder,  bool isDefault,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModifierGroupItemModel() when $default != null:
return $default(_that.id,_that.companyId,_that.modifierGroupId,_that.itemId,_that.sortOrder,_that.isDefault,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String modifierGroupId,  String itemId,  int sortOrder,  bool isDefault,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _ModifierGroupItemModel():
return $default(_that.id,_that.companyId,_that.modifierGroupId,_that.itemId,_that.sortOrder,_that.isDefault,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String modifierGroupId,  String itemId,  int sortOrder,  bool isDefault,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _ModifierGroupItemModel() when $default != null:
return $default(_that.id,_that.companyId,_that.modifierGroupId,_that.itemId,_that.sortOrder,_that.isDefault,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ModifierGroupItemModel implements ModifierGroupItemModel {
  const _ModifierGroupItemModel({required this.id, required this.companyId, required this.modifierGroupId, required this.itemId, this.sortOrder = 0, this.isDefault = false, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String modifierGroupId;
@override final  String itemId;
@override@JsonKey() final  int sortOrder;
@override@JsonKey() final  bool isDefault;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of ModifierGroupItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModifierGroupItemModelCopyWith<_ModifierGroupItemModel> get copyWith => __$ModifierGroupItemModelCopyWithImpl<_ModifierGroupItemModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModifierGroupItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.modifierGroupId, modifierGroupId) || other.modifierGroupId == modifierGroupId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,modifierGroupId,itemId,sortOrder,isDefault,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ModifierGroupItemModel(id: $id, companyId: $companyId, modifierGroupId: $modifierGroupId, itemId: $itemId, sortOrder: $sortOrder, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ModifierGroupItemModelCopyWith<$Res> implements $ModifierGroupItemModelCopyWith<$Res> {
  factory _$ModifierGroupItemModelCopyWith(_ModifierGroupItemModel value, $Res Function(_ModifierGroupItemModel) _then) = __$ModifierGroupItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String modifierGroupId, String itemId, int sortOrder, bool isDefault, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$ModifierGroupItemModelCopyWithImpl<$Res>
    implements _$ModifierGroupItemModelCopyWith<$Res> {
  __$ModifierGroupItemModelCopyWithImpl(this._self, this._then);

  final _ModifierGroupItemModel _self;
  final $Res Function(_ModifierGroupItemModel) _then;

/// Create a copy of ModifierGroupItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? modifierGroupId = null,Object? itemId = null,Object? sortOrder = null,Object? isDefault = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_ModifierGroupItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,modifierGroupId: null == modifierGroupId ? _self.modifierGroupId : modifierGroupId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
