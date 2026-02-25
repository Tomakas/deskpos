// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'modifier_group_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ModifierGroupModel {

 String get id; String get companyId; String get name; int get minSelections; int? get maxSelections; int get sortOrder; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of ModifierGroupModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModifierGroupModelCopyWith<ModifierGroupModel> get copyWith => _$ModifierGroupModelCopyWithImpl<ModifierGroupModel>(this as ModifierGroupModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModifierGroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.minSelections, minSelections) || other.minSelections == minSelections)&&(identical(other.maxSelections, maxSelections) || other.maxSelections == maxSelections)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,minSelections,maxSelections,sortOrder,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ModifierGroupModel(id: $id, companyId: $companyId, name: $name, minSelections: $minSelections, maxSelections: $maxSelections, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ModifierGroupModelCopyWith<$Res>  {
  factory $ModifierGroupModelCopyWith(ModifierGroupModel value, $Res Function(ModifierGroupModel) _then) = _$ModifierGroupModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String name, int minSelections, int? maxSelections, int sortOrder, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$ModifierGroupModelCopyWithImpl<$Res>
    implements $ModifierGroupModelCopyWith<$Res> {
  _$ModifierGroupModelCopyWithImpl(this._self, this._then);

  final ModifierGroupModel _self;
  final $Res Function(ModifierGroupModel) _then;

/// Create a copy of ModifierGroupModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? minSelections = null,Object? maxSelections = freezed,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,minSelections: null == minSelections ? _self.minSelections : minSelections // ignore: cast_nullable_to_non_nullable
as int,maxSelections: freezed == maxSelections ? _self.maxSelections : maxSelections // ignore: cast_nullable_to_non_nullable
as int?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModifierGroupModel].
extension ModifierGroupModelPatterns on ModifierGroupModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModifierGroupModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModifierGroupModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModifierGroupModel value)  $default,){
final _that = this;
switch (_that) {
case _ModifierGroupModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModifierGroupModel value)?  $default,){
final _that = this;
switch (_that) {
case _ModifierGroupModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  int minSelections,  int? maxSelections,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModifierGroupModel() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.minSelections,_that.maxSelections,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  int minSelections,  int? maxSelections,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _ModifierGroupModel():
return $default(_that.id,_that.companyId,_that.name,_that.minSelections,_that.maxSelections,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String name,  int minSelections,  int? maxSelections,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _ModifierGroupModel() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.minSelections,_that.maxSelections,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ModifierGroupModel implements ModifierGroupModel {
  const _ModifierGroupModel({required this.id, required this.companyId, required this.name, this.minSelections = 0, this.maxSelections, this.sortOrder = 0, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String name;
@override@JsonKey() final  int minSelections;
@override final  int? maxSelections;
@override@JsonKey() final  int sortOrder;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of ModifierGroupModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModifierGroupModelCopyWith<_ModifierGroupModel> get copyWith => __$ModifierGroupModelCopyWithImpl<_ModifierGroupModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModifierGroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.minSelections, minSelections) || other.minSelections == minSelections)&&(identical(other.maxSelections, maxSelections) || other.maxSelections == maxSelections)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,minSelections,maxSelections,sortOrder,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ModifierGroupModel(id: $id, companyId: $companyId, name: $name, minSelections: $minSelections, maxSelections: $maxSelections, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ModifierGroupModelCopyWith<$Res> implements $ModifierGroupModelCopyWith<$Res> {
  factory _$ModifierGroupModelCopyWith(_ModifierGroupModel value, $Res Function(_ModifierGroupModel) _then) = __$ModifierGroupModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String name, int minSelections, int? maxSelections, int sortOrder, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$ModifierGroupModelCopyWithImpl<$Res>
    implements _$ModifierGroupModelCopyWith<$Res> {
  __$ModifierGroupModelCopyWithImpl(this._self, this._then);

  final _ModifierGroupModel _self;
  final $Res Function(_ModifierGroupModel) _then;

/// Create a copy of ModifierGroupModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? minSelections = null,Object? maxSelections = freezed,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_ModifierGroupModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,minSelections: null == minSelections ? _self.minSelections : minSelections // ignore: cast_nullable_to_non_nullable
as int,maxSelections: freezed == maxSelections ? _self.maxSelections : maxSelections // ignore: cast_nullable_to_non_nullable
as int?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
