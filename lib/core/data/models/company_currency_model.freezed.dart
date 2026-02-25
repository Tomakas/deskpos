// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_currency_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompanyCurrencyModel {

 String get id; String get companyId; String get currencyId; double get exchangeRate; bool get isActive; int get sortOrder; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of CompanyCurrencyModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyCurrencyModelCopyWith<CompanyCurrencyModel> get copyWith => _$CompanyCurrencyModelCopyWithImpl<CompanyCurrencyModel>(this as CompanyCurrencyModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyCurrencyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.currencyId, currencyId) || other.currencyId == currencyId)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,currencyId,exchangeRate,isActive,sortOrder,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'CompanyCurrencyModel(id: $id, companyId: $companyId, currencyId: $currencyId, exchangeRate: $exchangeRate, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $CompanyCurrencyModelCopyWith<$Res>  {
  factory $CompanyCurrencyModelCopyWith(CompanyCurrencyModel value, $Res Function(CompanyCurrencyModel) _then) = _$CompanyCurrencyModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String currencyId, double exchangeRate, bool isActive, int sortOrder, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$CompanyCurrencyModelCopyWithImpl<$Res>
    implements $CompanyCurrencyModelCopyWith<$Res> {
  _$CompanyCurrencyModelCopyWithImpl(this._self, this._then);

  final CompanyCurrencyModel _self;
  final $Res Function(CompanyCurrencyModel) _then;

/// Create a copy of CompanyCurrencyModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? currencyId = null,Object? exchangeRate = null,Object? isActive = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,currencyId: null == currencyId ? _self.currencyId : currencyId // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanyCurrencyModel].
extension CompanyCurrencyModelPatterns on CompanyCurrencyModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanyCurrencyModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanyCurrencyModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanyCurrencyModel value)  $default,){
final _that = this;
switch (_that) {
case _CompanyCurrencyModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanyCurrencyModel value)?  $default,){
final _that = this;
switch (_that) {
case _CompanyCurrencyModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String currencyId,  double exchangeRate,  bool isActive,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanyCurrencyModel() when $default != null:
return $default(_that.id,_that.companyId,_that.currencyId,_that.exchangeRate,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String currencyId,  double exchangeRate,  bool isActive,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _CompanyCurrencyModel():
return $default(_that.id,_that.companyId,_that.currencyId,_that.exchangeRate,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String currencyId,  double exchangeRate,  bool isActive,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _CompanyCurrencyModel() when $default != null:
return $default(_that.id,_that.companyId,_that.currencyId,_that.exchangeRate,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CompanyCurrencyModel implements CompanyCurrencyModel {
  const _CompanyCurrencyModel({required this.id, required this.companyId, required this.currencyId, required this.exchangeRate, this.isActive = true, this.sortOrder = 0, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String currencyId;
@override final  double exchangeRate;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  int sortOrder;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of CompanyCurrencyModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyCurrencyModelCopyWith<_CompanyCurrencyModel> get copyWith => __$CompanyCurrencyModelCopyWithImpl<_CompanyCurrencyModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyCurrencyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.currencyId, currencyId) || other.currencyId == currencyId)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,currencyId,exchangeRate,isActive,sortOrder,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'CompanyCurrencyModel(id: $id, companyId: $companyId, currencyId: $currencyId, exchangeRate: $exchangeRate, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$CompanyCurrencyModelCopyWith<$Res> implements $CompanyCurrencyModelCopyWith<$Res> {
  factory _$CompanyCurrencyModelCopyWith(_CompanyCurrencyModel value, $Res Function(_CompanyCurrencyModel) _then) = __$CompanyCurrencyModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String currencyId, double exchangeRate, bool isActive, int sortOrder, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$CompanyCurrencyModelCopyWithImpl<$Res>
    implements _$CompanyCurrencyModelCopyWith<$Res> {
  __$CompanyCurrencyModelCopyWithImpl(this._self, this._then);

  final _CompanyCurrencyModel _self;
  final $Res Function(_CompanyCurrencyModel) _then;

/// Create a copy of CompanyCurrencyModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? currencyId = null,Object? exchangeRate = null,Object? isActive = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_CompanyCurrencyModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,currencyId: null == currencyId ? _self.currencyId : currencyId // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
