// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voucher_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoucherModel {

 String get id; String get companyId; String get code; VoucherType get type; VoucherStatus get status; int get value; DiscountType? get discountType; VoucherDiscountScope? get discountScope; String? get itemId; String? get categoryId; int? get minOrderValue; int get maxUses; int get usedCount; String? get customerId; DateTime? get expiresAt; DateTime? get redeemedAt; String? get redeemedOnBillId; String? get sourceBillId; String? get createdByUserId; String? get note; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoucherModelCopyWith<VoucherModel> get copyWith => _$VoucherModelCopyWithImpl<VoucherModel>(this as VoucherModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoucherModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.value, value) || other.value == value)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountScope, discountScope) || other.discountScope == discountScope)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.minOrderValue, minOrderValue) || other.minOrderValue == minOrderValue)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.usedCount, usedCount) || other.usedCount == usedCount)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.redeemedAt, redeemedAt) || other.redeemedAt == redeemedAt)&&(identical(other.redeemedOnBillId, redeemedOnBillId) || other.redeemedOnBillId == redeemedOnBillId)&&(identical(other.sourceBillId, sourceBillId) || other.sourceBillId == sourceBillId)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,code,type,status,value,discountType,discountScope,itemId,categoryId,minOrderValue,maxUses,usedCount,customerId,expiresAt,redeemedAt,redeemedOnBillId,sourceBillId,createdByUserId,note,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'VoucherModel(id: $id, companyId: $companyId, code: $code, type: $type, status: $status, value: $value, discountType: $discountType, discountScope: $discountScope, itemId: $itemId, categoryId: $categoryId, minOrderValue: $minOrderValue, maxUses: $maxUses, usedCount: $usedCount, customerId: $customerId, expiresAt: $expiresAt, redeemedAt: $redeemedAt, redeemedOnBillId: $redeemedOnBillId, sourceBillId: $sourceBillId, createdByUserId: $createdByUserId, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $VoucherModelCopyWith<$Res>  {
  factory $VoucherModelCopyWith(VoucherModel value, $Res Function(VoucherModel) _then) = _$VoucherModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String code, VoucherType type, VoucherStatus status, int value, DiscountType? discountType, VoucherDiscountScope? discountScope, String? itemId, String? categoryId, int? minOrderValue, int maxUses, int usedCount, String? customerId, DateTime? expiresAt, DateTime? redeemedAt, String? redeemedOnBillId, String? sourceBillId, String? createdByUserId, String? note, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$VoucherModelCopyWithImpl<$Res>
    implements $VoucherModelCopyWith<$Res> {
  _$VoucherModelCopyWithImpl(this._self, this._then);

  final VoucherModel _self;
  final $Res Function(VoucherModel) _then;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? code = null,Object? type = null,Object? status = null,Object? value = null,Object? discountType = freezed,Object? discountScope = freezed,Object? itemId = freezed,Object? categoryId = freezed,Object? minOrderValue = freezed,Object? maxUses = null,Object? usedCount = null,Object? customerId = freezed,Object? expiresAt = freezed,Object? redeemedAt = freezed,Object? redeemedOnBillId = freezed,Object? sourceBillId = freezed,Object? createdByUserId = freezed,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VoucherType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoucherStatus,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as DiscountType?,discountScope: freezed == discountScope ? _self.discountScope : discountScope // ignore: cast_nullable_to_non_nullable
as VoucherDiscountScope?,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,minOrderValue: freezed == minOrderValue ? _self.minOrderValue : minOrderValue // ignore: cast_nullable_to_non_nullable
as int?,maxUses: null == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int,usedCount: null == usedCount ? _self.usedCount : usedCount // ignore: cast_nullable_to_non_nullable
as int,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,redeemedAt: freezed == redeemedAt ? _self.redeemedAt : redeemedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,redeemedOnBillId: freezed == redeemedOnBillId ? _self.redeemedOnBillId : redeemedOnBillId // ignore: cast_nullable_to_non_nullable
as String?,sourceBillId: freezed == sourceBillId ? _self.sourceBillId : sourceBillId // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoucherModel].
extension VoucherModelPatterns on VoucherModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoucherModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoucherModel value)  $default,){
final _that = this;
switch (_that) {
case _VoucherModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoucherModel value)?  $default,){
final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String code,  VoucherType type,  VoucherStatus status,  int value,  DiscountType? discountType,  VoucherDiscountScope? discountScope,  String? itemId,  String? categoryId,  int? minOrderValue,  int maxUses,  int usedCount,  String? customerId,  DateTime? expiresAt,  DateTime? redeemedAt,  String? redeemedOnBillId,  String? sourceBillId,  String? createdByUserId,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
return $default(_that.id,_that.companyId,_that.code,_that.type,_that.status,_that.value,_that.discountType,_that.discountScope,_that.itemId,_that.categoryId,_that.minOrderValue,_that.maxUses,_that.usedCount,_that.customerId,_that.expiresAt,_that.redeemedAt,_that.redeemedOnBillId,_that.sourceBillId,_that.createdByUserId,_that.note,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String code,  VoucherType type,  VoucherStatus status,  int value,  DiscountType? discountType,  VoucherDiscountScope? discountScope,  String? itemId,  String? categoryId,  int? minOrderValue,  int maxUses,  int usedCount,  String? customerId,  DateTime? expiresAt,  DateTime? redeemedAt,  String? redeemedOnBillId,  String? sourceBillId,  String? createdByUserId,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _VoucherModel():
return $default(_that.id,_that.companyId,_that.code,_that.type,_that.status,_that.value,_that.discountType,_that.discountScope,_that.itemId,_that.categoryId,_that.minOrderValue,_that.maxUses,_that.usedCount,_that.customerId,_that.expiresAt,_that.redeemedAt,_that.redeemedOnBillId,_that.sourceBillId,_that.createdByUserId,_that.note,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String code,  VoucherType type,  VoucherStatus status,  int value,  DiscountType? discountType,  VoucherDiscountScope? discountScope,  String? itemId,  String? categoryId,  int? minOrderValue,  int maxUses,  int usedCount,  String? customerId,  DateTime? expiresAt,  DateTime? redeemedAt,  String? redeemedOnBillId,  String? sourceBillId,  String? createdByUserId,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
return $default(_that.id,_that.companyId,_that.code,_that.type,_that.status,_that.value,_that.discountType,_that.discountScope,_that.itemId,_that.categoryId,_that.minOrderValue,_that.maxUses,_that.usedCount,_that.customerId,_that.expiresAt,_that.redeemedAt,_that.redeemedOnBillId,_that.sourceBillId,_that.createdByUserId,_that.note,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _VoucherModel implements VoucherModel {
  const _VoucherModel({required this.id, required this.companyId, required this.code, required this.type, required this.status, required this.value, this.discountType, this.discountScope, this.itemId, this.categoryId, this.minOrderValue, this.maxUses = 1, this.usedCount = 0, this.customerId, this.expiresAt, this.redeemedAt, this.redeemedOnBillId, this.sourceBillId, this.createdByUserId, this.note, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String code;
@override final  VoucherType type;
@override final  VoucherStatus status;
@override final  int value;
@override final  DiscountType? discountType;
@override final  VoucherDiscountScope? discountScope;
@override final  String? itemId;
@override final  String? categoryId;
@override final  int? minOrderValue;
@override@JsonKey() final  int maxUses;
@override@JsonKey() final  int usedCount;
@override final  String? customerId;
@override final  DateTime? expiresAt;
@override final  DateTime? redeemedAt;
@override final  String? redeemedOnBillId;
@override final  String? sourceBillId;
@override final  String? createdByUserId;
@override final  String? note;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoucherModelCopyWith<_VoucherModel> get copyWith => __$VoucherModelCopyWithImpl<_VoucherModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoucherModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.value, value) || other.value == value)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountScope, discountScope) || other.discountScope == discountScope)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.minOrderValue, minOrderValue) || other.minOrderValue == minOrderValue)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.usedCount, usedCount) || other.usedCount == usedCount)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.redeemedAt, redeemedAt) || other.redeemedAt == redeemedAt)&&(identical(other.redeemedOnBillId, redeemedOnBillId) || other.redeemedOnBillId == redeemedOnBillId)&&(identical(other.sourceBillId, sourceBillId) || other.sourceBillId == sourceBillId)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,code,type,status,value,discountType,discountScope,itemId,categoryId,minOrderValue,maxUses,usedCount,customerId,expiresAt,redeemedAt,redeemedOnBillId,sourceBillId,createdByUserId,note,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'VoucherModel(id: $id, companyId: $companyId, code: $code, type: $type, status: $status, value: $value, discountType: $discountType, discountScope: $discountScope, itemId: $itemId, categoryId: $categoryId, minOrderValue: $minOrderValue, maxUses: $maxUses, usedCount: $usedCount, customerId: $customerId, expiresAt: $expiresAt, redeemedAt: $redeemedAt, redeemedOnBillId: $redeemedOnBillId, sourceBillId: $sourceBillId, createdByUserId: $createdByUserId, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$VoucherModelCopyWith<$Res> implements $VoucherModelCopyWith<$Res> {
  factory _$VoucherModelCopyWith(_VoucherModel value, $Res Function(_VoucherModel) _then) = __$VoucherModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String code, VoucherType type, VoucherStatus status, int value, DiscountType? discountType, VoucherDiscountScope? discountScope, String? itemId, String? categoryId, int? minOrderValue, int maxUses, int usedCount, String? customerId, DateTime? expiresAt, DateTime? redeemedAt, String? redeemedOnBillId, String? sourceBillId, String? createdByUserId, String? note, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$VoucherModelCopyWithImpl<$Res>
    implements _$VoucherModelCopyWith<$Res> {
  __$VoucherModelCopyWithImpl(this._self, this._then);

  final _VoucherModel _self;
  final $Res Function(_VoucherModel) _then;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? code = null,Object? type = null,Object? status = null,Object? value = null,Object? discountType = freezed,Object? discountScope = freezed,Object? itemId = freezed,Object? categoryId = freezed,Object? minOrderValue = freezed,Object? maxUses = null,Object? usedCount = null,Object? customerId = freezed,Object? expiresAt = freezed,Object? redeemedAt = freezed,Object? redeemedOnBillId = freezed,Object? sourceBillId = freezed,Object? createdByUserId = freezed,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_VoucherModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VoucherType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoucherStatus,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as DiscountType?,discountScope: freezed == discountScope ? _self.discountScope : discountScope // ignore: cast_nullable_to_non_nullable
as VoucherDiscountScope?,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,minOrderValue: freezed == minOrderValue ? _self.minOrderValue : minOrderValue // ignore: cast_nullable_to_non_nullable
as int?,maxUses: null == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int,usedCount: null == usedCount ? _self.usedCount : usedCount // ignore: cast_nullable_to_non_nullable
as int,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,redeemedAt: freezed == redeemedAt ? _self.redeemedAt : redeemedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,redeemedOnBillId: freezed == redeemedOnBillId ? _self.redeemedOnBillId : redeemedOnBillId // ignore: cast_nullable_to_non_nullable
as String?,sourceBillId: freezed == sourceBillId ? _self.sourceBillId : sourceBillId // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
