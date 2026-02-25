// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role_permission_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RolePermissionModel {

 String get id; String get roleId; String get permissionId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of RolePermissionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RolePermissionModelCopyWith<RolePermissionModel> get copyWith => _$RolePermissionModelCopyWithImpl<RolePermissionModel>(this as RolePermissionModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RolePermissionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.permissionId, permissionId) || other.permissionId == permissionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,roleId,permissionId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'RolePermissionModel(id: $id, roleId: $roleId, permissionId: $permissionId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $RolePermissionModelCopyWith<$Res>  {
  factory $RolePermissionModelCopyWith(RolePermissionModel value, $Res Function(RolePermissionModel) _then) = _$RolePermissionModelCopyWithImpl;
@useResult
$Res call({
 String id, String roleId, String permissionId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$RolePermissionModelCopyWithImpl<$Res>
    implements $RolePermissionModelCopyWith<$Res> {
  _$RolePermissionModelCopyWithImpl(this._self, this._then);

  final RolePermissionModel _self;
  final $Res Function(RolePermissionModel) _then;

/// Create a copy of RolePermissionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? roleId = null,Object? permissionId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String,permissionId: null == permissionId ? _self.permissionId : permissionId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RolePermissionModel].
extension RolePermissionModelPatterns on RolePermissionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RolePermissionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RolePermissionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RolePermissionModel value)  $default,){
final _that = this;
switch (_that) {
case _RolePermissionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RolePermissionModel value)?  $default,){
final _that = this;
switch (_that) {
case _RolePermissionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String roleId,  String permissionId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RolePermissionModel() when $default != null:
return $default(_that.id,_that.roleId,_that.permissionId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String roleId,  String permissionId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _RolePermissionModel():
return $default(_that.id,_that.roleId,_that.permissionId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String roleId,  String permissionId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _RolePermissionModel() when $default != null:
return $default(_that.id,_that.roleId,_that.permissionId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RolePermissionModel implements RolePermissionModel {
  const _RolePermissionModel({required this.id, required this.roleId, required this.permissionId, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String roleId;
@override final  String permissionId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of RolePermissionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RolePermissionModelCopyWith<_RolePermissionModel> get copyWith => __$RolePermissionModelCopyWithImpl<_RolePermissionModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RolePermissionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.permissionId, permissionId) || other.permissionId == permissionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,roleId,permissionId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'RolePermissionModel(id: $id, roleId: $roleId, permissionId: $permissionId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$RolePermissionModelCopyWith<$Res> implements $RolePermissionModelCopyWith<$Res> {
  factory _$RolePermissionModelCopyWith(_RolePermissionModel value, $Res Function(_RolePermissionModel) _then) = __$RolePermissionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String roleId, String permissionId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$RolePermissionModelCopyWithImpl<$Res>
    implements _$RolePermissionModelCopyWith<$Res> {
  __$RolePermissionModelCopyWithImpl(this._self, this._then);

  final _RolePermissionModel _self;
  final $Res Function(_RolePermissionModel) _then;

/// Create a copy of RolePermissionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? roleId = null,Object? permissionId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_RolePermissionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String,permissionId: null == permissionId ? _self.permissionId : permissionId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
