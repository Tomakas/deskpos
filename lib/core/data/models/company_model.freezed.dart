// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompanyModel {

 String get id; String get name; CompanyStatus get status; String? get businessId; String? get address; String? get phone; String? get email; String? get vatNumber; String? get country; String? get city; String? get postalCode; String? get timezone; BusinessType? get businessType; String get defaultCurrencyId; String get authUserId; bool get isDemo; DateTime? get demoExpiresAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of CompanyModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyModelCopyWith<CompanyModel> get copyWith => _$CompanyModelCopyWithImpl<CompanyModel>(this as CompanyModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.businessType, businessType) || other.businessType == businessType)&&(identical(other.defaultCurrencyId, defaultCurrencyId) || other.defaultCurrencyId == defaultCurrencyId)&&(identical(other.authUserId, authUserId) || other.authUserId == authUserId)&&(identical(other.isDemo, isDemo) || other.isDemo == isDemo)&&(identical(other.demoExpiresAt, demoExpiresAt) || other.demoExpiresAt == demoExpiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,status,businessId,address,phone,email,vatNumber,country,city,postalCode,timezone,businessType,defaultCurrencyId,authUserId,isDemo,demoExpiresAt,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'CompanyModel(id: $id, name: $name, status: $status, businessId: $businessId, address: $address, phone: $phone, email: $email, vatNumber: $vatNumber, country: $country, city: $city, postalCode: $postalCode, timezone: $timezone, businessType: $businessType, defaultCurrencyId: $defaultCurrencyId, authUserId: $authUserId, isDemo: $isDemo, demoExpiresAt: $demoExpiresAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $CompanyModelCopyWith<$Res>  {
  factory $CompanyModelCopyWith(CompanyModel value, $Res Function(CompanyModel) _then) = _$CompanyModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, CompanyStatus status, String? businessId, String? address, String? phone, String? email, String? vatNumber, String? country, String? city, String? postalCode, String? timezone, BusinessType? businessType, String defaultCurrencyId, String authUserId, bool isDemo, DateTime? demoExpiresAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$CompanyModelCopyWithImpl<$Res>
    implements $CompanyModelCopyWith<$Res> {
  _$CompanyModelCopyWithImpl(this._self, this._then);

  final CompanyModel _self;
  final $Res Function(CompanyModel) _then;

/// Create a copy of CompanyModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? status = null,Object? businessId = freezed,Object? address = freezed,Object? phone = freezed,Object? email = freezed,Object? vatNumber = freezed,Object? country = freezed,Object? city = freezed,Object? postalCode = freezed,Object? timezone = freezed,Object? businessType = freezed,Object? defaultCurrencyId = null,Object? authUserId = null,Object? isDemo = null,Object? demoExpiresAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CompanyStatus,businessId: freezed == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,businessType: freezed == businessType ? _self.businessType : businessType // ignore: cast_nullable_to_non_nullable
as BusinessType?,defaultCurrencyId: null == defaultCurrencyId ? _self.defaultCurrencyId : defaultCurrencyId // ignore: cast_nullable_to_non_nullable
as String,authUserId: null == authUserId ? _self.authUserId : authUserId // ignore: cast_nullable_to_non_nullable
as String,isDemo: null == isDemo ? _self.isDemo : isDemo // ignore: cast_nullable_to_non_nullable
as bool,demoExpiresAt: freezed == demoExpiresAt ? _self.demoExpiresAt : demoExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanyModel].
extension CompanyModelPatterns on CompanyModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanyModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanyModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanyModel value)  $default,){
final _that = this;
switch (_that) {
case _CompanyModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanyModel value)?  $default,){
final _that = this;
switch (_that) {
case _CompanyModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  CompanyStatus status,  String? businessId,  String? address,  String? phone,  String? email,  String? vatNumber,  String? country,  String? city,  String? postalCode,  String? timezone,  BusinessType? businessType,  String defaultCurrencyId,  String authUserId,  bool isDemo,  DateTime? demoExpiresAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanyModel() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.businessId,_that.address,_that.phone,_that.email,_that.vatNumber,_that.country,_that.city,_that.postalCode,_that.timezone,_that.businessType,_that.defaultCurrencyId,_that.authUserId,_that.isDemo,_that.demoExpiresAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  CompanyStatus status,  String? businessId,  String? address,  String? phone,  String? email,  String? vatNumber,  String? country,  String? city,  String? postalCode,  String? timezone,  BusinessType? businessType,  String defaultCurrencyId,  String authUserId,  bool isDemo,  DateTime? demoExpiresAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _CompanyModel():
return $default(_that.id,_that.name,_that.status,_that.businessId,_that.address,_that.phone,_that.email,_that.vatNumber,_that.country,_that.city,_that.postalCode,_that.timezone,_that.businessType,_that.defaultCurrencyId,_that.authUserId,_that.isDemo,_that.demoExpiresAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  CompanyStatus status,  String? businessId,  String? address,  String? phone,  String? email,  String? vatNumber,  String? country,  String? city,  String? postalCode,  String? timezone,  BusinessType? businessType,  String defaultCurrencyId,  String authUserId,  bool isDemo,  DateTime? demoExpiresAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _CompanyModel() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.businessId,_that.address,_that.phone,_that.email,_that.vatNumber,_that.country,_that.city,_that.postalCode,_that.timezone,_that.businessType,_that.defaultCurrencyId,_that.authUserId,_that.isDemo,_that.demoExpiresAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CompanyModel implements CompanyModel {
  const _CompanyModel({required this.id, required this.name, required this.status, this.businessId, this.address, this.phone, this.email, this.vatNumber, this.country, this.city, this.postalCode, this.timezone, this.businessType, required this.defaultCurrencyId, required this.authUserId, this.isDemo = false, this.demoExpiresAt, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String name;
@override final  CompanyStatus status;
@override final  String? businessId;
@override final  String? address;
@override final  String? phone;
@override final  String? email;
@override final  String? vatNumber;
@override final  String? country;
@override final  String? city;
@override final  String? postalCode;
@override final  String? timezone;
@override final  BusinessType? businessType;
@override final  String defaultCurrencyId;
@override final  String authUserId;
@override@JsonKey() final  bool isDemo;
@override final  DateTime? demoExpiresAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of CompanyModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyModelCopyWith<_CompanyModel> get copyWith => __$CompanyModelCopyWithImpl<_CompanyModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.businessType, businessType) || other.businessType == businessType)&&(identical(other.defaultCurrencyId, defaultCurrencyId) || other.defaultCurrencyId == defaultCurrencyId)&&(identical(other.authUserId, authUserId) || other.authUserId == authUserId)&&(identical(other.isDemo, isDemo) || other.isDemo == isDemo)&&(identical(other.demoExpiresAt, demoExpiresAt) || other.demoExpiresAt == demoExpiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,status,businessId,address,phone,email,vatNumber,country,city,postalCode,timezone,businessType,defaultCurrencyId,authUserId,isDemo,demoExpiresAt,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'CompanyModel(id: $id, name: $name, status: $status, businessId: $businessId, address: $address, phone: $phone, email: $email, vatNumber: $vatNumber, country: $country, city: $city, postalCode: $postalCode, timezone: $timezone, businessType: $businessType, defaultCurrencyId: $defaultCurrencyId, authUserId: $authUserId, isDemo: $isDemo, demoExpiresAt: $demoExpiresAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$CompanyModelCopyWith<$Res> implements $CompanyModelCopyWith<$Res> {
  factory _$CompanyModelCopyWith(_CompanyModel value, $Res Function(_CompanyModel) _then) = __$CompanyModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, CompanyStatus status, String? businessId, String? address, String? phone, String? email, String? vatNumber, String? country, String? city, String? postalCode, String? timezone, BusinessType? businessType, String defaultCurrencyId, String authUserId, bool isDemo, DateTime? demoExpiresAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$CompanyModelCopyWithImpl<$Res>
    implements _$CompanyModelCopyWith<$Res> {
  __$CompanyModelCopyWithImpl(this._self, this._then);

  final _CompanyModel _self;
  final $Res Function(_CompanyModel) _then;

/// Create a copy of CompanyModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? status = null,Object? businessId = freezed,Object? address = freezed,Object? phone = freezed,Object? email = freezed,Object? vatNumber = freezed,Object? country = freezed,Object? city = freezed,Object? postalCode = freezed,Object? timezone = freezed,Object? businessType = freezed,Object? defaultCurrencyId = null,Object? authUserId = null,Object? isDemo = null,Object? demoExpiresAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_CompanyModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CompanyStatus,businessId: freezed == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,businessType: freezed == businessType ? _self.businessType : businessType // ignore: cast_nullable_to_non_nullable
as BusinessType?,defaultCurrencyId: null == defaultCurrencyId ? _self.defaultCurrencyId : defaultCurrencyId // ignore: cast_nullable_to_non_nullable
as String,authUserId: null == authUserId ? _self.authUserId : authUserId // ignore: cast_nullable_to_non_nullable
as String,isDemo: null == isDemo ? _self.isDemo : isDemo // ignore: cast_nullable_to_non_nullable
as bool,demoExpiresAt: freezed == demoExpiresAt ? _self.demoExpiresAt : demoExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
