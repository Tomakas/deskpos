// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_element_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapElementModel {

 String get id; String get companyId; String? get sectionId; int get gridRow; int get gridCol; int get gridWidth; int get gridHeight; String? get label; String? get color; int? get fontSize; int get fillStyle; int get borderStyle; TableShape get shape; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of MapElementModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapElementModelCopyWith<MapElementModel> get copyWith => _$MapElementModelCopyWithImpl<MapElementModel>(this as MapElementModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapElementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.gridRow, gridRow) || other.gridRow == gridRow)&&(identical(other.gridCol, gridCol) || other.gridCol == gridCol)&&(identical(other.gridWidth, gridWidth) || other.gridWidth == gridWidth)&&(identical(other.gridHeight, gridHeight) || other.gridHeight == gridHeight)&&(identical(other.label, label) || other.label == label)&&(identical(other.color, color) || other.color == color)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.fillStyle, fillStyle) || other.fillStyle == fillStyle)&&(identical(other.borderStyle, borderStyle) || other.borderStyle == borderStyle)&&(identical(other.shape, shape) || other.shape == shape)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,sectionId,gridRow,gridCol,gridWidth,gridHeight,label,color,fontSize,fillStyle,borderStyle,shape,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'MapElementModel(id: $id, companyId: $companyId, sectionId: $sectionId, gridRow: $gridRow, gridCol: $gridCol, gridWidth: $gridWidth, gridHeight: $gridHeight, label: $label, color: $color, fontSize: $fontSize, fillStyle: $fillStyle, borderStyle: $borderStyle, shape: $shape, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $MapElementModelCopyWith<$Res>  {
  factory $MapElementModelCopyWith(MapElementModel value, $Res Function(MapElementModel) _then) = _$MapElementModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String? sectionId, int gridRow, int gridCol, int gridWidth, int gridHeight, String? label, String? color, int? fontSize, int fillStyle, int borderStyle, TableShape shape, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$MapElementModelCopyWithImpl<$Res>
    implements $MapElementModelCopyWith<$Res> {
  _$MapElementModelCopyWithImpl(this._self, this._then);

  final MapElementModel _self;
  final $Res Function(MapElementModel) _then;

/// Create a copy of MapElementModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? sectionId = freezed,Object? gridRow = null,Object? gridCol = null,Object? gridWidth = null,Object? gridHeight = null,Object? label = freezed,Object? color = freezed,Object? fontSize = freezed,Object? fillStyle = null,Object? borderStyle = null,Object? shape = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,gridRow: null == gridRow ? _self.gridRow : gridRow // ignore: cast_nullable_to_non_nullable
as int,gridCol: null == gridCol ? _self.gridCol : gridCol // ignore: cast_nullable_to_non_nullable
as int,gridWidth: null == gridWidth ? _self.gridWidth : gridWidth // ignore: cast_nullable_to_non_nullable
as int,gridHeight: null == gridHeight ? _self.gridHeight : gridHeight // ignore: cast_nullable_to_non_nullable
as int,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,fontSize: freezed == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as int?,fillStyle: null == fillStyle ? _self.fillStyle : fillStyle // ignore: cast_nullable_to_non_nullable
as int,borderStyle: null == borderStyle ? _self.borderStyle : borderStyle // ignore: cast_nullable_to_non_nullable
as int,shape: null == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as TableShape,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MapElementModel].
extension MapElementModelPatterns on MapElementModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapElementModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapElementModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapElementModel value)  $default,){
final _that = this;
switch (_that) {
case _MapElementModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapElementModel value)?  $default,){
final _that = this;
switch (_that) {
case _MapElementModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String? sectionId,  int gridRow,  int gridCol,  int gridWidth,  int gridHeight,  String? label,  String? color,  int? fontSize,  int fillStyle,  int borderStyle,  TableShape shape,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapElementModel() when $default != null:
return $default(_that.id,_that.companyId,_that.sectionId,_that.gridRow,_that.gridCol,_that.gridWidth,_that.gridHeight,_that.label,_that.color,_that.fontSize,_that.fillStyle,_that.borderStyle,_that.shape,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String? sectionId,  int gridRow,  int gridCol,  int gridWidth,  int gridHeight,  String? label,  String? color,  int? fontSize,  int fillStyle,  int borderStyle,  TableShape shape,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _MapElementModel():
return $default(_that.id,_that.companyId,_that.sectionId,_that.gridRow,_that.gridCol,_that.gridWidth,_that.gridHeight,_that.label,_that.color,_that.fontSize,_that.fillStyle,_that.borderStyle,_that.shape,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String? sectionId,  int gridRow,  int gridCol,  int gridWidth,  int gridHeight,  String? label,  String? color,  int? fontSize,  int fillStyle,  int borderStyle,  TableShape shape,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _MapElementModel() when $default != null:
return $default(_that.id,_that.companyId,_that.sectionId,_that.gridRow,_that.gridCol,_that.gridWidth,_that.gridHeight,_that.label,_that.color,_that.fontSize,_that.fillStyle,_that.borderStyle,_that.shape,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _MapElementModel implements MapElementModel {
  const _MapElementModel({required this.id, required this.companyId, this.sectionId, this.gridRow = 0, this.gridCol = 0, this.gridWidth = 2, this.gridHeight = 2, this.label, this.color, this.fontSize, this.fillStyle = 1, this.borderStyle = 1, this.shape = TableShape.rectangle, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String? sectionId;
@override@JsonKey() final  int gridRow;
@override@JsonKey() final  int gridCol;
@override@JsonKey() final  int gridWidth;
@override@JsonKey() final  int gridHeight;
@override final  String? label;
@override final  String? color;
@override final  int? fontSize;
@override@JsonKey() final  int fillStyle;
@override@JsonKey() final  int borderStyle;
@override@JsonKey() final  TableShape shape;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of MapElementModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapElementModelCopyWith<_MapElementModel> get copyWith => __$MapElementModelCopyWithImpl<_MapElementModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapElementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.gridRow, gridRow) || other.gridRow == gridRow)&&(identical(other.gridCol, gridCol) || other.gridCol == gridCol)&&(identical(other.gridWidth, gridWidth) || other.gridWidth == gridWidth)&&(identical(other.gridHeight, gridHeight) || other.gridHeight == gridHeight)&&(identical(other.label, label) || other.label == label)&&(identical(other.color, color) || other.color == color)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.fillStyle, fillStyle) || other.fillStyle == fillStyle)&&(identical(other.borderStyle, borderStyle) || other.borderStyle == borderStyle)&&(identical(other.shape, shape) || other.shape == shape)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,sectionId,gridRow,gridCol,gridWidth,gridHeight,label,color,fontSize,fillStyle,borderStyle,shape,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'MapElementModel(id: $id, companyId: $companyId, sectionId: $sectionId, gridRow: $gridRow, gridCol: $gridCol, gridWidth: $gridWidth, gridHeight: $gridHeight, label: $label, color: $color, fontSize: $fontSize, fillStyle: $fillStyle, borderStyle: $borderStyle, shape: $shape, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$MapElementModelCopyWith<$Res> implements $MapElementModelCopyWith<$Res> {
  factory _$MapElementModelCopyWith(_MapElementModel value, $Res Function(_MapElementModel) _then) = __$MapElementModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String? sectionId, int gridRow, int gridCol, int gridWidth, int gridHeight, String? label, String? color, int? fontSize, int fillStyle, int borderStyle, TableShape shape, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$MapElementModelCopyWithImpl<$Res>
    implements _$MapElementModelCopyWith<$Res> {
  __$MapElementModelCopyWithImpl(this._self, this._then);

  final _MapElementModel _self;
  final $Res Function(_MapElementModel) _then;

/// Create a copy of MapElementModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? sectionId = freezed,Object? gridRow = null,Object? gridCol = null,Object? gridWidth = null,Object? gridHeight = null,Object? label = freezed,Object? color = freezed,Object? fontSize = freezed,Object? fillStyle = null,Object? borderStyle = null,Object? shape = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_MapElementModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,gridRow: null == gridRow ? _self.gridRow : gridRow // ignore: cast_nullable_to_non_nullable
as int,gridCol: null == gridCol ? _self.gridCol : gridCol // ignore: cast_nullable_to_non_nullable
as int,gridWidth: null == gridWidth ? _self.gridWidth : gridWidth // ignore: cast_nullable_to_non_nullable
as int,gridHeight: null == gridHeight ? _self.gridHeight : gridHeight // ignore: cast_nullable_to_non_nullable
as int,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,fontSize: freezed == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as int?,fillStyle: null == fillStyle ? _self.fillStyle : fillStyle // ignore: cast_nullable_to_non_nullable
as int,borderStyle: null == borderStyle ? _self.borderStyle : borderStyle // ignore: cast_nullable_to_non_nullable
as int,shape: null == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as TableShape,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
