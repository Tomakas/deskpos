// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_registration_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeviceRegistrationModel {

 String get id; String get companyId; String get registerId; DateTime get createdAt;
/// Create a copy of DeviceRegistrationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceRegistrationModelCopyWith<DeviceRegistrationModel> get copyWith => _$DeviceRegistrationModelCopyWithImpl<DeviceRegistrationModel>(this as DeviceRegistrationModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceRegistrationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,registerId,createdAt);

@override
String toString() {
  return 'DeviceRegistrationModel(id: $id, companyId: $companyId, registerId: $registerId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DeviceRegistrationModelCopyWith<$Res>  {
  factory $DeviceRegistrationModelCopyWith(DeviceRegistrationModel value, $Res Function(DeviceRegistrationModel) _then) = _$DeviceRegistrationModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String registerId, DateTime createdAt
});




}
/// @nodoc
class _$DeviceRegistrationModelCopyWithImpl<$Res>
    implements $DeviceRegistrationModelCopyWith<$Res> {
  _$DeviceRegistrationModelCopyWithImpl(this._self, this._then);

  final DeviceRegistrationModel _self;
  final $Res Function(DeviceRegistrationModel) _then;

/// Create a copy of DeviceRegistrationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? registerId = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,registerId: null == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceRegistrationModel].
extension DeviceRegistrationModelPatterns on DeviceRegistrationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceRegistrationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceRegistrationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceRegistrationModel value)  $default,){
final _that = this;
switch (_that) {
case _DeviceRegistrationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceRegistrationModel value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceRegistrationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String registerId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceRegistrationModel() when $default != null:
return $default(_that.id,_that.companyId,_that.registerId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String registerId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DeviceRegistrationModel():
return $default(_that.id,_that.companyId,_that.registerId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String registerId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DeviceRegistrationModel() when $default != null:
return $default(_that.id,_that.companyId,_that.registerId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _DeviceRegistrationModel implements DeviceRegistrationModel {
  const _DeviceRegistrationModel({required this.id, required this.companyId, required this.registerId, required this.createdAt});
  

@override final  String id;
@override final  String companyId;
@override final  String registerId;
@override final  DateTime createdAt;

/// Create a copy of DeviceRegistrationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceRegistrationModelCopyWith<_DeviceRegistrationModel> get copyWith => __$DeviceRegistrationModelCopyWithImpl<_DeviceRegistrationModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceRegistrationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,registerId,createdAt);

@override
String toString() {
  return 'DeviceRegistrationModel(id: $id, companyId: $companyId, registerId: $registerId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DeviceRegistrationModelCopyWith<$Res> implements $DeviceRegistrationModelCopyWith<$Res> {
  factory _$DeviceRegistrationModelCopyWith(_DeviceRegistrationModel value, $Res Function(_DeviceRegistrationModel) _then) = __$DeviceRegistrationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String registerId, DateTime createdAt
});




}
/// @nodoc
class __$DeviceRegistrationModelCopyWithImpl<$Res>
    implements _$DeviceRegistrationModelCopyWith<$Res> {
  __$DeviceRegistrationModelCopyWithImpl(this._self, this._then);

  final _DeviceRegistrationModel _self;
  final $Res Function(_DeviceRegistrationModel) _then;

/// Create a copy of DeviceRegistrationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? registerId = null,Object? createdAt = null,}) {
  return _then(_DeviceRegistrationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,registerId: null == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
