// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompanySettingsModel {

 String get id; String get companyId; bool get requirePinOnSwitch; int? get autoLockTimeoutMinutes; int get loyaltyEarnRate; int get loyaltyPointValue; String get locale; NegativeStockPolicy get negativeStockPolicy; int get maxItemDiscountPercent; int get maxBillDiscountPercent;// TODO: Add UI for editing these thresholds in company settings screen.
 int get billAgeWarningMinutes; int get billAgeDangerMinutes; int get billAgeCriticalMinutes; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of CompanySettingsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanySettingsModelCopyWith<CompanySettingsModel> get copyWith => _$CompanySettingsModelCopyWithImpl<CompanySettingsModel>(this as CompanySettingsModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanySettingsModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.requirePinOnSwitch, requirePinOnSwitch) || other.requirePinOnSwitch == requirePinOnSwitch)&&(identical(other.autoLockTimeoutMinutes, autoLockTimeoutMinutes) || other.autoLockTimeoutMinutes == autoLockTimeoutMinutes)&&(identical(other.loyaltyEarnRate, loyaltyEarnRate) || other.loyaltyEarnRate == loyaltyEarnRate)&&(identical(other.loyaltyPointValue, loyaltyPointValue) || other.loyaltyPointValue == loyaltyPointValue)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.negativeStockPolicy, negativeStockPolicy) || other.negativeStockPolicy == negativeStockPolicy)&&(identical(other.maxItemDiscountPercent, maxItemDiscountPercent) || other.maxItemDiscountPercent == maxItemDiscountPercent)&&(identical(other.maxBillDiscountPercent, maxBillDiscountPercent) || other.maxBillDiscountPercent == maxBillDiscountPercent)&&(identical(other.billAgeWarningMinutes, billAgeWarningMinutes) || other.billAgeWarningMinutes == billAgeWarningMinutes)&&(identical(other.billAgeDangerMinutes, billAgeDangerMinutes) || other.billAgeDangerMinutes == billAgeDangerMinutes)&&(identical(other.billAgeCriticalMinutes, billAgeCriticalMinutes) || other.billAgeCriticalMinutes == billAgeCriticalMinutes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,requirePinOnSwitch,autoLockTimeoutMinutes,loyaltyEarnRate,loyaltyPointValue,locale,negativeStockPolicy,maxItemDiscountPercent,maxBillDiscountPercent,billAgeWarningMinutes,billAgeDangerMinutes,billAgeCriticalMinutes,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'CompanySettingsModel(id: $id, companyId: $companyId, requirePinOnSwitch: $requirePinOnSwitch, autoLockTimeoutMinutes: $autoLockTimeoutMinutes, loyaltyEarnRate: $loyaltyEarnRate, loyaltyPointValue: $loyaltyPointValue, locale: $locale, negativeStockPolicy: $negativeStockPolicy, maxItemDiscountPercent: $maxItemDiscountPercent, maxBillDiscountPercent: $maxBillDiscountPercent, billAgeWarningMinutes: $billAgeWarningMinutes, billAgeDangerMinutes: $billAgeDangerMinutes, billAgeCriticalMinutes: $billAgeCriticalMinutes, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $CompanySettingsModelCopyWith<$Res>  {
  factory $CompanySettingsModelCopyWith(CompanySettingsModel value, $Res Function(CompanySettingsModel) _then) = _$CompanySettingsModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, bool requirePinOnSwitch, int? autoLockTimeoutMinutes, int loyaltyEarnRate, int loyaltyPointValue, String locale, NegativeStockPolicy negativeStockPolicy, int maxItemDiscountPercent, int maxBillDiscountPercent, int billAgeWarningMinutes, int billAgeDangerMinutes, int billAgeCriticalMinutes, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$CompanySettingsModelCopyWithImpl<$Res>
    implements $CompanySettingsModelCopyWith<$Res> {
  _$CompanySettingsModelCopyWithImpl(this._self, this._then);

  final CompanySettingsModel _self;
  final $Res Function(CompanySettingsModel) _then;

/// Create a copy of CompanySettingsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? requirePinOnSwitch = null,Object? autoLockTimeoutMinutes = freezed,Object? loyaltyEarnRate = null,Object? loyaltyPointValue = null,Object? locale = null,Object? negativeStockPolicy = null,Object? maxItemDiscountPercent = null,Object? maxBillDiscountPercent = null,Object? billAgeWarningMinutes = null,Object? billAgeDangerMinutes = null,Object? billAgeCriticalMinutes = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,requirePinOnSwitch: null == requirePinOnSwitch ? _self.requirePinOnSwitch : requirePinOnSwitch // ignore: cast_nullable_to_non_nullable
as bool,autoLockTimeoutMinutes: freezed == autoLockTimeoutMinutes ? _self.autoLockTimeoutMinutes : autoLockTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int?,loyaltyEarnRate: null == loyaltyEarnRate ? _self.loyaltyEarnRate : loyaltyEarnRate // ignore: cast_nullable_to_non_nullable
as int,loyaltyPointValue: null == loyaltyPointValue ? _self.loyaltyPointValue : loyaltyPointValue // ignore: cast_nullable_to_non_nullable
as int,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,negativeStockPolicy: null == negativeStockPolicy ? _self.negativeStockPolicy : negativeStockPolicy // ignore: cast_nullable_to_non_nullable
as NegativeStockPolicy,maxItemDiscountPercent: null == maxItemDiscountPercent ? _self.maxItemDiscountPercent : maxItemDiscountPercent // ignore: cast_nullable_to_non_nullable
as int,maxBillDiscountPercent: null == maxBillDiscountPercent ? _self.maxBillDiscountPercent : maxBillDiscountPercent // ignore: cast_nullable_to_non_nullable
as int,billAgeWarningMinutes: null == billAgeWarningMinutes ? _self.billAgeWarningMinutes : billAgeWarningMinutes // ignore: cast_nullable_to_non_nullable
as int,billAgeDangerMinutes: null == billAgeDangerMinutes ? _self.billAgeDangerMinutes : billAgeDangerMinutes // ignore: cast_nullable_to_non_nullable
as int,billAgeCriticalMinutes: null == billAgeCriticalMinutes ? _self.billAgeCriticalMinutes : billAgeCriticalMinutes // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanySettingsModel].
extension CompanySettingsModelPatterns on CompanySettingsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanySettingsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanySettingsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanySettingsModel value)  $default,){
final _that = this;
switch (_that) {
case _CompanySettingsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanySettingsModel value)?  $default,){
final _that = this;
switch (_that) {
case _CompanySettingsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  bool requirePinOnSwitch,  int? autoLockTimeoutMinutes,  int loyaltyEarnRate,  int loyaltyPointValue,  String locale,  NegativeStockPolicy negativeStockPolicy,  int maxItemDiscountPercent,  int maxBillDiscountPercent,  int billAgeWarningMinutes,  int billAgeDangerMinutes,  int billAgeCriticalMinutes,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanySettingsModel() when $default != null:
return $default(_that.id,_that.companyId,_that.requirePinOnSwitch,_that.autoLockTimeoutMinutes,_that.loyaltyEarnRate,_that.loyaltyPointValue,_that.locale,_that.negativeStockPolicy,_that.maxItemDiscountPercent,_that.maxBillDiscountPercent,_that.billAgeWarningMinutes,_that.billAgeDangerMinutes,_that.billAgeCriticalMinutes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  bool requirePinOnSwitch,  int? autoLockTimeoutMinutes,  int loyaltyEarnRate,  int loyaltyPointValue,  String locale,  NegativeStockPolicy negativeStockPolicy,  int maxItemDiscountPercent,  int maxBillDiscountPercent,  int billAgeWarningMinutes,  int billAgeDangerMinutes,  int billAgeCriticalMinutes,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _CompanySettingsModel():
return $default(_that.id,_that.companyId,_that.requirePinOnSwitch,_that.autoLockTimeoutMinutes,_that.loyaltyEarnRate,_that.loyaltyPointValue,_that.locale,_that.negativeStockPolicy,_that.maxItemDiscountPercent,_that.maxBillDiscountPercent,_that.billAgeWarningMinutes,_that.billAgeDangerMinutes,_that.billAgeCriticalMinutes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  bool requirePinOnSwitch,  int? autoLockTimeoutMinutes,  int loyaltyEarnRate,  int loyaltyPointValue,  String locale,  NegativeStockPolicy negativeStockPolicy,  int maxItemDiscountPercent,  int maxBillDiscountPercent,  int billAgeWarningMinutes,  int billAgeDangerMinutes,  int billAgeCriticalMinutes,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _CompanySettingsModel() when $default != null:
return $default(_that.id,_that.companyId,_that.requirePinOnSwitch,_that.autoLockTimeoutMinutes,_that.loyaltyEarnRate,_that.loyaltyPointValue,_that.locale,_that.negativeStockPolicy,_that.maxItemDiscountPercent,_that.maxBillDiscountPercent,_that.billAgeWarningMinutes,_that.billAgeDangerMinutes,_that.billAgeCriticalMinutes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CompanySettingsModel implements CompanySettingsModel {
  const _CompanySettingsModel({required this.id, required this.companyId, this.requirePinOnSwitch = true, this.autoLockTimeoutMinutes, this.loyaltyEarnRate = 0, this.loyaltyPointValue = 0, this.locale = 'cs', this.negativeStockPolicy = NegativeStockPolicy.allow, this.maxItemDiscountPercent = 2000, this.maxBillDiscountPercent = 2000, this.billAgeWarningMinutes = 15, this.billAgeDangerMinutes = 30, this.billAgeCriticalMinutes = 45, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override@JsonKey() final  bool requirePinOnSwitch;
@override final  int? autoLockTimeoutMinutes;
@override@JsonKey() final  int loyaltyEarnRate;
@override@JsonKey() final  int loyaltyPointValue;
@override@JsonKey() final  String locale;
@override@JsonKey() final  NegativeStockPolicy negativeStockPolicy;
@override@JsonKey() final  int maxItemDiscountPercent;
@override@JsonKey() final  int maxBillDiscountPercent;
// TODO: Add UI for editing these thresholds in company settings screen.
@override@JsonKey() final  int billAgeWarningMinutes;
@override@JsonKey() final  int billAgeDangerMinutes;
@override@JsonKey() final  int billAgeCriticalMinutes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of CompanySettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanySettingsModelCopyWith<_CompanySettingsModel> get copyWith => __$CompanySettingsModelCopyWithImpl<_CompanySettingsModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanySettingsModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.requirePinOnSwitch, requirePinOnSwitch) || other.requirePinOnSwitch == requirePinOnSwitch)&&(identical(other.autoLockTimeoutMinutes, autoLockTimeoutMinutes) || other.autoLockTimeoutMinutes == autoLockTimeoutMinutes)&&(identical(other.loyaltyEarnRate, loyaltyEarnRate) || other.loyaltyEarnRate == loyaltyEarnRate)&&(identical(other.loyaltyPointValue, loyaltyPointValue) || other.loyaltyPointValue == loyaltyPointValue)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.negativeStockPolicy, negativeStockPolicy) || other.negativeStockPolicy == negativeStockPolicy)&&(identical(other.maxItemDiscountPercent, maxItemDiscountPercent) || other.maxItemDiscountPercent == maxItemDiscountPercent)&&(identical(other.maxBillDiscountPercent, maxBillDiscountPercent) || other.maxBillDiscountPercent == maxBillDiscountPercent)&&(identical(other.billAgeWarningMinutes, billAgeWarningMinutes) || other.billAgeWarningMinutes == billAgeWarningMinutes)&&(identical(other.billAgeDangerMinutes, billAgeDangerMinutes) || other.billAgeDangerMinutes == billAgeDangerMinutes)&&(identical(other.billAgeCriticalMinutes, billAgeCriticalMinutes) || other.billAgeCriticalMinutes == billAgeCriticalMinutes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,requirePinOnSwitch,autoLockTimeoutMinutes,loyaltyEarnRate,loyaltyPointValue,locale,negativeStockPolicy,maxItemDiscountPercent,maxBillDiscountPercent,billAgeWarningMinutes,billAgeDangerMinutes,billAgeCriticalMinutes,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'CompanySettingsModel(id: $id, companyId: $companyId, requirePinOnSwitch: $requirePinOnSwitch, autoLockTimeoutMinutes: $autoLockTimeoutMinutes, loyaltyEarnRate: $loyaltyEarnRate, loyaltyPointValue: $loyaltyPointValue, locale: $locale, negativeStockPolicy: $negativeStockPolicy, maxItemDiscountPercent: $maxItemDiscountPercent, maxBillDiscountPercent: $maxBillDiscountPercent, billAgeWarningMinutes: $billAgeWarningMinutes, billAgeDangerMinutes: $billAgeDangerMinutes, billAgeCriticalMinutes: $billAgeCriticalMinutes, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$CompanySettingsModelCopyWith<$Res> implements $CompanySettingsModelCopyWith<$Res> {
  factory _$CompanySettingsModelCopyWith(_CompanySettingsModel value, $Res Function(_CompanySettingsModel) _then) = __$CompanySettingsModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, bool requirePinOnSwitch, int? autoLockTimeoutMinutes, int loyaltyEarnRate, int loyaltyPointValue, String locale, NegativeStockPolicy negativeStockPolicy, int maxItemDiscountPercent, int maxBillDiscountPercent, int billAgeWarningMinutes, int billAgeDangerMinutes, int billAgeCriticalMinutes, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$CompanySettingsModelCopyWithImpl<$Res>
    implements _$CompanySettingsModelCopyWith<$Res> {
  __$CompanySettingsModelCopyWithImpl(this._self, this._then);

  final _CompanySettingsModel _self;
  final $Res Function(_CompanySettingsModel) _then;

/// Create a copy of CompanySettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? requirePinOnSwitch = null,Object? autoLockTimeoutMinutes = freezed,Object? loyaltyEarnRate = null,Object? loyaltyPointValue = null,Object? locale = null,Object? negativeStockPolicy = null,Object? maxItemDiscountPercent = null,Object? maxBillDiscountPercent = null,Object? billAgeWarningMinutes = null,Object? billAgeDangerMinutes = null,Object? billAgeCriticalMinutes = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_CompanySettingsModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,requirePinOnSwitch: null == requirePinOnSwitch ? _self.requirePinOnSwitch : requirePinOnSwitch // ignore: cast_nullable_to_non_nullable
as bool,autoLockTimeoutMinutes: freezed == autoLockTimeoutMinutes ? _self.autoLockTimeoutMinutes : autoLockTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int?,loyaltyEarnRate: null == loyaltyEarnRate ? _self.loyaltyEarnRate : loyaltyEarnRate // ignore: cast_nullable_to_non_nullable
as int,loyaltyPointValue: null == loyaltyPointValue ? _self.loyaltyPointValue : loyaltyPointValue // ignore: cast_nullable_to_non_nullable
as int,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,negativeStockPolicy: null == negativeStockPolicy ? _self.negativeStockPolicy : negativeStockPolicy // ignore: cast_nullable_to_non_nullable
as NegativeStockPolicy,maxItemDiscountPercent: null == maxItemDiscountPercent ? _self.maxItemDiscountPercent : maxItemDiscountPercent // ignore: cast_nullable_to_non_nullable
as int,maxBillDiscountPercent: null == maxBillDiscountPercent ? _self.maxBillDiscountPercent : maxBillDiscountPercent // ignore: cast_nullable_to_non_nullable
as int,billAgeWarningMinutes: null == billAgeWarningMinutes ? _self.billAgeWarningMinutes : billAgeWarningMinutes // ignore: cast_nullable_to_non_nullable
as int,billAgeDangerMinutes: null == billAgeDangerMinutes ? _self.billAgeDangerMinutes : billAgeDangerMinutes // ignore: cast_nullable_to_non_nullable
as int,billAgeCriticalMinutes: null == billAgeCriticalMinutes ? _self.billAgeCriticalMinutes : billAgeCriticalMinutes // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
