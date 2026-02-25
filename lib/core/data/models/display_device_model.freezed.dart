// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'display_device_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DisplayDeviceModel {

 String get id; String get companyId; String? get parentRegisterId; String get code; String get name; String get welcomeText; DisplayDeviceType get type; bool get isActive; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of DisplayDeviceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisplayDeviceModelCopyWith<DisplayDeviceModel> get copyWith => _$DisplayDeviceModelCopyWithImpl<DisplayDeviceModel>(this as DisplayDeviceModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisplayDeviceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.parentRegisterId, parentRegisterId) || other.parentRegisterId == parentRegisterId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.welcomeText, welcomeText) || other.welcomeText == welcomeText)&&(identical(other.type, type) || other.type == type)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,parentRegisterId,code,name,welcomeText,type,isActive,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'DisplayDeviceModel(id: $id, companyId: $companyId, parentRegisterId: $parentRegisterId, code: $code, name: $name, welcomeText: $welcomeText, type: $type, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $DisplayDeviceModelCopyWith<$Res>  {
  factory $DisplayDeviceModelCopyWith(DisplayDeviceModel value, $Res Function(DisplayDeviceModel) _then) = _$DisplayDeviceModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String? parentRegisterId, String code, String name, String welcomeText, DisplayDeviceType type, bool isActive, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$DisplayDeviceModelCopyWithImpl<$Res>
    implements $DisplayDeviceModelCopyWith<$Res> {
  _$DisplayDeviceModelCopyWithImpl(this._self, this._then);

  final DisplayDeviceModel _self;
  final $Res Function(DisplayDeviceModel) _then;

/// Create a copy of DisplayDeviceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? parentRegisterId = freezed,Object? code = null,Object? name = null,Object? welcomeText = null,Object? type = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,parentRegisterId: freezed == parentRegisterId ? _self.parentRegisterId : parentRegisterId // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,welcomeText: null == welcomeText ? _self.welcomeText : welcomeText // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DisplayDeviceType,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DisplayDeviceModel].
extension DisplayDeviceModelPatterns on DisplayDeviceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisplayDeviceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisplayDeviceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisplayDeviceModel value)  $default,){
final _that = this;
switch (_that) {
case _DisplayDeviceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisplayDeviceModel value)?  $default,){
final _that = this;
switch (_that) {
case _DisplayDeviceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String? parentRegisterId,  String code,  String name,  String welcomeText,  DisplayDeviceType type,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisplayDeviceModel() when $default != null:
return $default(_that.id,_that.companyId,_that.parentRegisterId,_that.code,_that.name,_that.welcomeText,_that.type,_that.isActive,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String? parentRegisterId,  String code,  String name,  String welcomeText,  DisplayDeviceType type,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _DisplayDeviceModel():
return $default(_that.id,_that.companyId,_that.parentRegisterId,_that.code,_that.name,_that.welcomeText,_that.type,_that.isActive,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String? parentRegisterId,  String code,  String name,  String welcomeText,  DisplayDeviceType type,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _DisplayDeviceModel() when $default != null:
return $default(_that.id,_that.companyId,_that.parentRegisterId,_that.code,_that.name,_that.welcomeText,_that.type,_that.isActive,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _DisplayDeviceModel implements DisplayDeviceModel {
  const _DisplayDeviceModel({required this.id, required this.companyId, this.parentRegisterId, required this.code, this.name = '', this.welcomeText = '', this.type = DisplayDeviceType.customerDisplay, this.isActive = true, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String? parentRegisterId;
@override final  String code;
@override@JsonKey() final  String name;
@override@JsonKey() final  String welcomeText;
@override@JsonKey() final  DisplayDeviceType type;
@override@JsonKey() final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of DisplayDeviceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisplayDeviceModelCopyWith<_DisplayDeviceModel> get copyWith => __$DisplayDeviceModelCopyWithImpl<_DisplayDeviceModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplayDeviceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.parentRegisterId, parentRegisterId) || other.parentRegisterId == parentRegisterId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.welcomeText, welcomeText) || other.welcomeText == welcomeText)&&(identical(other.type, type) || other.type == type)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,parentRegisterId,code,name,welcomeText,type,isActive,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'DisplayDeviceModel(id: $id, companyId: $companyId, parentRegisterId: $parentRegisterId, code: $code, name: $name, welcomeText: $welcomeText, type: $type, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$DisplayDeviceModelCopyWith<$Res> implements $DisplayDeviceModelCopyWith<$Res> {
  factory _$DisplayDeviceModelCopyWith(_DisplayDeviceModel value, $Res Function(_DisplayDeviceModel) _then) = __$DisplayDeviceModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String? parentRegisterId, String code, String name, String welcomeText, DisplayDeviceType type, bool isActive, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$DisplayDeviceModelCopyWithImpl<$Res>
    implements _$DisplayDeviceModelCopyWith<$Res> {
  __$DisplayDeviceModelCopyWithImpl(this._self, this._then);

  final _DisplayDeviceModel _self;
  final $Res Function(_DisplayDeviceModel) _then;

/// Create a copy of DisplayDeviceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? parentRegisterId = freezed,Object? code = null,Object? name = null,Object? welcomeText = null,Object? type = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_DisplayDeviceModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,parentRegisterId: freezed == parentRegisterId ? _self.parentRegisterId : parentRegisterId // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,welcomeText: null == welcomeText ? _self.welcomeText : welcomeText // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DisplayDeviceType,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
