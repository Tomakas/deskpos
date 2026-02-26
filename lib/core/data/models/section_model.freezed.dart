// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'section_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SectionModel {

 String get id; String get companyId; String get name; String? get color; bool get isActive; bool get isDefault; int get sortOrder; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SectionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SectionModelCopyWith<SectionModel> get copyWith => _$SectionModelCopyWithImpl<SectionModel>(this as SectionModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SectionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,color,isActive,isDefault,sortOrder,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SectionModel(id: $id, companyId: $companyId, name: $name, color: $color, isActive: $isActive, isDefault: $isDefault, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SectionModelCopyWith<$Res>  {
  factory $SectionModelCopyWith(SectionModel value, $Res Function(SectionModel) _then) = _$SectionModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String name, String? color, bool isActive, bool isDefault, int sortOrder, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SectionModelCopyWithImpl<$Res>
    implements $SectionModelCopyWith<$Res> {
  _$SectionModelCopyWithImpl(this._self, this._then);

  final SectionModel _self;
  final $Res Function(SectionModel) _then;

/// Create a copy of SectionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? color = freezed,Object? isActive = null,Object? isDefault = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SectionModel].
extension SectionModelPatterns on SectionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SectionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SectionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SectionModel value)  $default,){
final _that = this;
switch (_that) {
case _SectionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SectionModel value)?  $default,){
final _that = this;
switch (_that) {
case _SectionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String? color,  bool isActive,  bool isDefault,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SectionModel() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.color,_that.isActive,_that.isDefault,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String name,  String? color,  bool isActive,  bool isDefault,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SectionModel():
return $default(_that.id,_that.companyId,_that.name,_that.color,_that.isActive,_that.isDefault,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String name,  String? color,  bool isActive,  bool isDefault,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SectionModel() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.color,_that.isActive,_that.isDefault,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SectionModel implements SectionModel {
  const _SectionModel({required this.id, required this.companyId, required this.name, this.color, this.isActive = true, this.isDefault = false, this.sortOrder = 0, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String name;
@override final  String? color;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isDefault;
@override@JsonKey() final  int sortOrder;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SectionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SectionModelCopyWith<_SectionModel> get copyWith => __$SectionModelCopyWithImpl<_SectionModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SectionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,color,isActive,isDefault,sortOrder,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SectionModel(id: $id, companyId: $companyId, name: $name, color: $color, isActive: $isActive, isDefault: $isDefault, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SectionModelCopyWith<$Res> implements $SectionModelCopyWith<$Res> {
  factory _$SectionModelCopyWith(_SectionModel value, $Res Function(_SectionModel) _then) = __$SectionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String name, String? color, bool isActive, bool isDefault, int sortOrder, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SectionModelCopyWithImpl<$Res>
    implements _$SectionModelCopyWith<$Res> {
  __$SectionModelCopyWithImpl(this._self, this._then);

  final _SectionModel _self;
  final $Res Function(_SectionModel) _then;

/// Create a copy of SectionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? color = freezed,Object? isActive = null,Object? isDefault = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SectionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
