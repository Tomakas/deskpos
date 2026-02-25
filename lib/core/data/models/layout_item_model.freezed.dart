// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'layout_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LayoutItemModel {

 String get id; String get companyId; String get registerId; int get page; int get gridRow; int get gridCol; LayoutItemType get type; String? get itemId; String? get categoryId; String? get label; String? get color; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of LayoutItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LayoutItemModelCopyWith<LayoutItemModel> get copyWith => _$LayoutItemModelCopyWithImpl<LayoutItemModel>(this as LayoutItemModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LayoutItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.page, page) || other.page == page)&&(identical(other.gridRow, gridRow) || other.gridRow == gridRow)&&(identical(other.gridCol, gridCol) || other.gridCol == gridCol)&&(identical(other.type, type) || other.type == type)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.label, label) || other.label == label)&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,registerId,page,gridRow,gridCol,type,itemId,categoryId,label,color,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'LayoutItemModel(id: $id, companyId: $companyId, registerId: $registerId, page: $page, gridRow: $gridRow, gridCol: $gridCol, type: $type, itemId: $itemId, categoryId: $categoryId, label: $label, color: $color, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $LayoutItemModelCopyWith<$Res>  {
  factory $LayoutItemModelCopyWith(LayoutItemModel value, $Res Function(LayoutItemModel) _then) = _$LayoutItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String registerId, int page, int gridRow, int gridCol, LayoutItemType type, String? itemId, String? categoryId, String? label, String? color, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$LayoutItemModelCopyWithImpl<$Res>
    implements $LayoutItemModelCopyWith<$Res> {
  _$LayoutItemModelCopyWithImpl(this._self, this._then);

  final LayoutItemModel _self;
  final $Res Function(LayoutItemModel) _then;

/// Create a copy of LayoutItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? registerId = null,Object? page = null,Object? gridRow = null,Object? gridCol = null,Object? type = null,Object? itemId = freezed,Object? categoryId = freezed,Object? label = freezed,Object? color = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,registerId: null == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,gridRow: null == gridRow ? _self.gridRow : gridRow // ignore: cast_nullable_to_non_nullable
as int,gridCol: null == gridCol ? _self.gridCol : gridCol // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LayoutItemType,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LayoutItemModel].
extension LayoutItemModelPatterns on LayoutItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LayoutItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LayoutItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LayoutItemModel value)  $default,){
final _that = this;
switch (_that) {
case _LayoutItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LayoutItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _LayoutItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String registerId,  int page,  int gridRow,  int gridCol,  LayoutItemType type,  String? itemId,  String? categoryId,  String? label,  String? color,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LayoutItemModel() when $default != null:
return $default(_that.id,_that.companyId,_that.registerId,_that.page,_that.gridRow,_that.gridCol,_that.type,_that.itemId,_that.categoryId,_that.label,_that.color,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String registerId,  int page,  int gridRow,  int gridCol,  LayoutItemType type,  String? itemId,  String? categoryId,  String? label,  String? color,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _LayoutItemModel():
return $default(_that.id,_that.companyId,_that.registerId,_that.page,_that.gridRow,_that.gridCol,_that.type,_that.itemId,_that.categoryId,_that.label,_that.color,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String registerId,  int page,  int gridRow,  int gridCol,  LayoutItemType type,  String? itemId,  String? categoryId,  String? label,  String? color,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _LayoutItemModel() when $default != null:
return $default(_that.id,_that.companyId,_that.registerId,_that.page,_that.gridRow,_that.gridCol,_that.type,_that.itemId,_that.categoryId,_that.label,_that.color,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _LayoutItemModel implements LayoutItemModel {
  const _LayoutItemModel({required this.id, required this.companyId, required this.registerId, this.page = 0, required this.gridRow, required this.gridCol, required this.type, this.itemId, this.categoryId, this.label, this.color, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String registerId;
@override@JsonKey() final  int page;
@override final  int gridRow;
@override final  int gridCol;
@override final  LayoutItemType type;
@override final  String? itemId;
@override final  String? categoryId;
@override final  String? label;
@override final  String? color;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of LayoutItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LayoutItemModelCopyWith<_LayoutItemModel> get copyWith => __$LayoutItemModelCopyWithImpl<_LayoutItemModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LayoutItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.page, page) || other.page == page)&&(identical(other.gridRow, gridRow) || other.gridRow == gridRow)&&(identical(other.gridCol, gridCol) || other.gridCol == gridCol)&&(identical(other.type, type) || other.type == type)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.label, label) || other.label == label)&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,registerId,page,gridRow,gridCol,type,itemId,categoryId,label,color,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'LayoutItemModel(id: $id, companyId: $companyId, registerId: $registerId, page: $page, gridRow: $gridRow, gridCol: $gridCol, type: $type, itemId: $itemId, categoryId: $categoryId, label: $label, color: $color, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$LayoutItemModelCopyWith<$Res> implements $LayoutItemModelCopyWith<$Res> {
  factory _$LayoutItemModelCopyWith(_LayoutItemModel value, $Res Function(_LayoutItemModel) _then) = __$LayoutItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String registerId, int page, int gridRow, int gridCol, LayoutItemType type, String? itemId, String? categoryId, String? label, String? color, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$LayoutItemModelCopyWithImpl<$Res>
    implements _$LayoutItemModelCopyWith<$Res> {
  __$LayoutItemModelCopyWithImpl(this._self, this._then);

  final _LayoutItemModel _self;
  final $Res Function(_LayoutItemModel) _then;

/// Create a copy of LayoutItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? registerId = null,Object? page = null,Object? gridRow = null,Object? gridCol = null,Object? type = null,Object? itemId = freezed,Object? categoryId = freezed,Object? label = freezed,Object? color = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_LayoutItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,registerId: null == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,gridRow: null == gridRow ? _self.gridRow : gridRow // ignore: cast_nullable_to_non_nullable
as int,gridCol: null == gridCol ? _self.gridCol : gridCol // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LayoutItemType,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
