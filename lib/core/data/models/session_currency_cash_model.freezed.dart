// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_currency_cash_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionCurrencyCashModel {

 String get id; String get companyId; String get registerSessionId; String get currencyId; int get openingCash; int? get closingCash; int? get expectedCash; int? get difference; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SessionCurrencyCashModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionCurrencyCashModelCopyWith<SessionCurrencyCashModel> get copyWith => _$SessionCurrencyCashModelCopyWithImpl<SessionCurrencyCashModel>(this as SessionCurrencyCashModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionCurrencyCashModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.registerSessionId, registerSessionId) || other.registerSessionId == registerSessionId)&&(identical(other.currencyId, currencyId) || other.currencyId == currencyId)&&(identical(other.openingCash, openingCash) || other.openingCash == openingCash)&&(identical(other.closingCash, closingCash) || other.closingCash == closingCash)&&(identical(other.expectedCash, expectedCash) || other.expectedCash == expectedCash)&&(identical(other.difference, difference) || other.difference == difference)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,registerSessionId,currencyId,openingCash,closingCash,expectedCash,difference,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SessionCurrencyCashModel(id: $id, companyId: $companyId, registerSessionId: $registerSessionId, currencyId: $currencyId, openingCash: $openingCash, closingCash: $closingCash, expectedCash: $expectedCash, difference: $difference, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SessionCurrencyCashModelCopyWith<$Res>  {
  factory $SessionCurrencyCashModelCopyWith(SessionCurrencyCashModel value, $Res Function(SessionCurrencyCashModel) _then) = _$SessionCurrencyCashModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String registerSessionId, String currencyId, int openingCash, int? closingCash, int? expectedCash, int? difference, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SessionCurrencyCashModelCopyWithImpl<$Res>
    implements $SessionCurrencyCashModelCopyWith<$Res> {
  _$SessionCurrencyCashModelCopyWithImpl(this._self, this._then);

  final SessionCurrencyCashModel _self;
  final $Res Function(SessionCurrencyCashModel) _then;

/// Create a copy of SessionCurrencyCashModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? registerSessionId = null,Object? currencyId = null,Object? openingCash = null,Object? closingCash = freezed,Object? expectedCash = freezed,Object? difference = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,registerSessionId: null == registerSessionId ? _self.registerSessionId : registerSessionId // ignore: cast_nullable_to_non_nullable
as String,currencyId: null == currencyId ? _self.currencyId : currencyId // ignore: cast_nullable_to_non_nullable
as String,openingCash: null == openingCash ? _self.openingCash : openingCash // ignore: cast_nullable_to_non_nullable
as int,closingCash: freezed == closingCash ? _self.closingCash : closingCash // ignore: cast_nullable_to_non_nullable
as int?,expectedCash: freezed == expectedCash ? _self.expectedCash : expectedCash // ignore: cast_nullable_to_non_nullable
as int?,difference: freezed == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionCurrencyCashModel].
extension SessionCurrencyCashModelPatterns on SessionCurrencyCashModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionCurrencyCashModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionCurrencyCashModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionCurrencyCashModel value)  $default,){
final _that = this;
switch (_that) {
case _SessionCurrencyCashModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionCurrencyCashModel value)?  $default,){
final _that = this;
switch (_that) {
case _SessionCurrencyCashModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String registerSessionId,  String currencyId,  int openingCash,  int? closingCash,  int? expectedCash,  int? difference,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionCurrencyCashModel() when $default != null:
return $default(_that.id,_that.companyId,_that.registerSessionId,_that.currencyId,_that.openingCash,_that.closingCash,_that.expectedCash,_that.difference,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String registerSessionId,  String currencyId,  int openingCash,  int? closingCash,  int? expectedCash,  int? difference,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SessionCurrencyCashModel():
return $default(_that.id,_that.companyId,_that.registerSessionId,_that.currencyId,_that.openingCash,_that.closingCash,_that.expectedCash,_that.difference,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String registerSessionId,  String currencyId,  int openingCash,  int? closingCash,  int? expectedCash,  int? difference,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionCurrencyCashModel() when $default != null:
return $default(_that.id,_that.companyId,_that.registerSessionId,_that.currencyId,_that.openingCash,_that.closingCash,_that.expectedCash,_that.difference,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SessionCurrencyCashModel implements SessionCurrencyCashModel {
  const _SessionCurrencyCashModel({required this.id, required this.companyId, required this.registerSessionId, required this.currencyId, this.openingCash = 0, this.closingCash, this.expectedCash, this.difference, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String registerSessionId;
@override final  String currencyId;
@override@JsonKey() final  int openingCash;
@override final  int? closingCash;
@override final  int? expectedCash;
@override final  int? difference;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SessionCurrencyCashModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionCurrencyCashModelCopyWith<_SessionCurrencyCashModel> get copyWith => __$SessionCurrencyCashModelCopyWithImpl<_SessionCurrencyCashModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionCurrencyCashModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.registerSessionId, registerSessionId) || other.registerSessionId == registerSessionId)&&(identical(other.currencyId, currencyId) || other.currencyId == currencyId)&&(identical(other.openingCash, openingCash) || other.openingCash == openingCash)&&(identical(other.closingCash, closingCash) || other.closingCash == closingCash)&&(identical(other.expectedCash, expectedCash) || other.expectedCash == expectedCash)&&(identical(other.difference, difference) || other.difference == difference)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,companyId,registerSessionId,currencyId,openingCash,closingCash,expectedCash,difference,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SessionCurrencyCashModel(id: $id, companyId: $companyId, registerSessionId: $registerSessionId, currencyId: $currencyId, openingCash: $openingCash, closingCash: $closingCash, expectedCash: $expectedCash, difference: $difference, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SessionCurrencyCashModelCopyWith<$Res> implements $SessionCurrencyCashModelCopyWith<$Res> {
  factory _$SessionCurrencyCashModelCopyWith(_SessionCurrencyCashModel value, $Res Function(_SessionCurrencyCashModel) _then) = __$SessionCurrencyCashModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String registerSessionId, String currencyId, int openingCash, int? closingCash, int? expectedCash, int? difference, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SessionCurrencyCashModelCopyWithImpl<$Res>
    implements _$SessionCurrencyCashModelCopyWith<$Res> {
  __$SessionCurrencyCashModelCopyWithImpl(this._self, this._then);

  final _SessionCurrencyCashModel _self;
  final $Res Function(_SessionCurrencyCashModel) _then;

/// Create a copy of SessionCurrencyCashModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? registerSessionId = null,Object? currencyId = null,Object? openingCash = null,Object? closingCash = freezed,Object? expectedCash = freezed,Object? difference = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SessionCurrencyCashModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,registerSessionId: null == registerSessionId ? _self.registerSessionId : registerSessionId // ignore: cast_nullable_to_non_nullable
as String,currencyId: null == currencyId ? _self.currencyId : currencyId // ignore: cast_nullable_to_non_nullable
as String,openingCash: null == openingCash ? _self.openingCash : openingCash // ignore: cast_nullable_to_non_nullable
as int,closingCash: freezed == closingCash ? _self.closingCash : closingCash // ignore: cast_nullable_to_non_nullable
as int?,expectedCash: freezed == expectedCash ? _self.expectedCash : expectedCash // ignore: cast_nullable_to_non_nullable
as int?,difference: freezed == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
