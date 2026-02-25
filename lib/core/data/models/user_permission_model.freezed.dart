// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_permission_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserPermissionModel {

 String get id; String get companyId; String get userId; String get permissionId; String get grantedBy; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of UserPermissionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPermissionModelCopyWith<UserPermissionModel> get copyWith => _$UserPermissionModelCopyWithImpl<UserPermissionModel>(this as UserPermissionModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPermissionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.permissionId, permissionId) || other.permissionId == permissionId)&&(identical(other.grantedBy, grantedBy) || other.grantedBy == grantedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,userId,permissionId,grantedBy,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'UserPermissionModel(id: $id, companyId: $companyId, userId: $userId, permissionId: $permissionId, grantedBy: $grantedBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $UserPermissionModelCopyWith<$Res>  {
  factory $UserPermissionModelCopyWith(UserPermissionModel value, $Res Function(UserPermissionModel) _then) = _$UserPermissionModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String userId, String permissionId, String grantedBy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$UserPermissionModelCopyWithImpl<$Res>
    implements $UserPermissionModelCopyWith<$Res> {
  _$UserPermissionModelCopyWithImpl(this._self, this._then);

  final UserPermissionModel _self;
  final $Res Function(UserPermissionModel) _then;

/// Create a copy of UserPermissionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? userId = null,Object? permissionId = null,Object? grantedBy = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,permissionId: null == permissionId ? _self.permissionId : permissionId // ignore: cast_nullable_to_non_nullable
as String,grantedBy: null == grantedBy ? _self.grantedBy : grantedBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPermissionModel].
extension UserPermissionModelPatterns on UserPermissionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPermissionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPermissionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPermissionModel value)  $default,){
final _that = this;
switch (_that) {
case _UserPermissionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPermissionModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserPermissionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String userId,  String permissionId,  String grantedBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPermissionModel() when $default != null:
return $default(_that.id,_that.companyId,_that.userId,_that.permissionId,_that.grantedBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String userId,  String permissionId,  String grantedBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _UserPermissionModel():
return $default(_that.id,_that.companyId,_that.userId,_that.permissionId,_that.grantedBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String userId,  String permissionId,  String grantedBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserPermissionModel() when $default != null:
return $default(_that.id,_that.companyId,_that.userId,_that.permissionId,_that.grantedBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _UserPermissionModel implements UserPermissionModel {
  const _UserPermissionModel({required this.id, required this.companyId, required this.userId, required this.permissionId, required this.grantedBy, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String userId;
@override final  String permissionId;
@override final  String grantedBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of UserPermissionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPermissionModelCopyWith<_UserPermissionModel> get copyWith => __$UserPermissionModelCopyWithImpl<_UserPermissionModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPermissionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.permissionId, permissionId) || other.permissionId == permissionId)&&(identical(other.grantedBy, grantedBy) || other.grantedBy == grantedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,userId,permissionId,grantedBy,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'UserPermissionModel(id: $id, companyId: $companyId, userId: $userId, permissionId: $permissionId, grantedBy: $grantedBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$UserPermissionModelCopyWith<$Res> implements $UserPermissionModelCopyWith<$Res> {
  factory _$UserPermissionModelCopyWith(_UserPermissionModel value, $Res Function(_UserPermissionModel) _then) = __$UserPermissionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String userId, String permissionId, String grantedBy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$UserPermissionModelCopyWithImpl<$Res>
    implements _$UserPermissionModelCopyWith<$Res> {
  __$UserPermissionModelCopyWithImpl(this._self, this._then);

  final _UserPermissionModel _self;
  final $Res Function(_UserPermissionModel) _then;

/// Create a copy of UserPermissionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? userId = null,Object? permissionId = null,Object? grantedBy = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_UserPermissionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,permissionId: null == permissionId ? _self.permissionId : permissionId // ignore: cast_nullable_to_non_nullable
as String,grantedBy: null == grantedBy ? _self.grantedBy : grantedBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
