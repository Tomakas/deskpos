// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterModel {

 String get id; String get companyId; String get code; String get name; int get registerNumber; String? get parentRegisterId; bool get isMain; bool get isActive; HardwareType get type; bool get allowCash; bool get allowCard; bool get allowTransfer; bool get allowCredit; bool get allowVoucher; bool get allowOther; bool get allowRefunds; String? get boundDeviceId; String? get activeBillId; int get gridRows; int get gridCols; String? get displayCartJson; SellMode get sellMode; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of RegisterModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterModelCopyWith<RegisterModel> get copyWith => _$RegisterModelCopyWithImpl<RegisterModel>(this as RegisterModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.registerNumber, registerNumber) || other.registerNumber == registerNumber)&&(identical(other.parentRegisterId, parentRegisterId) || other.parentRegisterId == parentRegisterId)&&(identical(other.isMain, isMain) || other.isMain == isMain)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.type, type) || other.type == type)&&(identical(other.allowCash, allowCash) || other.allowCash == allowCash)&&(identical(other.allowCard, allowCard) || other.allowCard == allowCard)&&(identical(other.allowTransfer, allowTransfer) || other.allowTransfer == allowTransfer)&&(identical(other.allowCredit, allowCredit) || other.allowCredit == allowCredit)&&(identical(other.allowVoucher, allowVoucher) || other.allowVoucher == allowVoucher)&&(identical(other.allowOther, allowOther) || other.allowOther == allowOther)&&(identical(other.allowRefunds, allowRefunds) || other.allowRefunds == allowRefunds)&&(identical(other.boundDeviceId, boundDeviceId) || other.boundDeviceId == boundDeviceId)&&(identical(other.activeBillId, activeBillId) || other.activeBillId == activeBillId)&&(identical(other.gridRows, gridRows) || other.gridRows == gridRows)&&(identical(other.gridCols, gridCols) || other.gridCols == gridCols)&&(identical(other.displayCartJson, displayCartJson) || other.displayCartJson == displayCartJson)&&(identical(other.sellMode, sellMode) || other.sellMode == sellMode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,code,name,registerNumber,parentRegisterId,isMain,isActive,type,allowCash,allowCard,allowTransfer,allowCredit,allowVoucher,allowOther,allowRefunds,boundDeviceId,activeBillId,gridRows,gridCols,displayCartJson,sellMode,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'RegisterModel(id: $id, companyId: $companyId, code: $code, name: $name, registerNumber: $registerNumber, parentRegisterId: $parentRegisterId, isMain: $isMain, isActive: $isActive, type: $type, allowCash: $allowCash, allowCard: $allowCard, allowTransfer: $allowTransfer, allowCredit: $allowCredit, allowVoucher: $allowVoucher, allowOther: $allowOther, allowRefunds: $allowRefunds, boundDeviceId: $boundDeviceId, activeBillId: $activeBillId, gridRows: $gridRows, gridCols: $gridCols, displayCartJson: $displayCartJson, sellMode: $sellMode, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $RegisterModelCopyWith<$Res>  {
  factory $RegisterModelCopyWith(RegisterModel value, $Res Function(RegisterModel) _then) = _$RegisterModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String code, String name, int registerNumber, String? parentRegisterId, bool isMain, bool isActive, HardwareType type, bool allowCash, bool allowCard, bool allowTransfer, bool allowCredit, bool allowVoucher, bool allowOther, bool allowRefunds, String? boundDeviceId, String? activeBillId, int gridRows, int gridCols, String? displayCartJson, SellMode sellMode, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$RegisterModelCopyWithImpl<$Res>
    implements $RegisterModelCopyWith<$Res> {
  _$RegisterModelCopyWithImpl(this._self, this._then);

  final RegisterModel _self;
  final $Res Function(RegisterModel) _then;

/// Create a copy of RegisterModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? code = null,Object? name = null,Object? registerNumber = null,Object? parentRegisterId = freezed,Object? isMain = null,Object? isActive = null,Object? type = null,Object? allowCash = null,Object? allowCard = null,Object? allowTransfer = null,Object? allowCredit = null,Object? allowVoucher = null,Object? allowOther = null,Object? allowRefunds = null,Object? boundDeviceId = freezed,Object? activeBillId = freezed,Object? gridRows = null,Object? gridCols = null,Object? displayCartJson = freezed,Object? sellMode = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,registerNumber: null == registerNumber ? _self.registerNumber : registerNumber // ignore: cast_nullable_to_non_nullable
as int,parentRegisterId: freezed == parentRegisterId ? _self.parentRegisterId : parentRegisterId // ignore: cast_nullable_to_non_nullable
as String?,isMain: null == isMain ? _self.isMain : isMain // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HardwareType,allowCash: null == allowCash ? _self.allowCash : allowCash // ignore: cast_nullable_to_non_nullable
as bool,allowCard: null == allowCard ? _self.allowCard : allowCard // ignore: cast_nullable_to_non_nullable
as bool,allowTransfer: null == allowTransfer ? _self.allowTransfer : allowTransfer // ignore: cast_nullable_to_non_nullable
as bool,allowCredit: null == allowCredit ? _self.allowCredit : allowCredit // ignore: cast_nullable_to_non_nullable
as bool,allowVoucher: null == allowVoucher ? _self.allowVoucher : allowVoucher // ignore: cast_nullable_to_non_nullable
as bool,allowOther: null == allowOther ? _self.allowOther : allowOther // ignore: cast_nullable_to_non_nullable
as bool,allowRefunds: null == allowRefunds ? _self.allowRefunds : allowRefunds // ignore: cast_nullable_to_non_nullable
as bool,boundDeviceId: freezed == boundDeviceId ? _self.boundDeviceId : boundDeviceId // ignore: cast_nullable_to_non_nullable
as String?,activeBillId: freezed == activeBillId ? _self.activeBillId : activeBillId // ignore: cast_nullable_to_non_nullable
as String?,gridRows: null == gridRows ? _self.gridRows : gridRows // ignore: cast_nullable_to_non_nullable
as int,gridCols: null == gridCols ? _self.gridCols : gridCols // ignore: cast_nullable_to_non_nullable
as int,displayCartJson: freezed == displayCartJson ? _self.displayCartJson : displayCartJson // ignore: cast_nullable_to_non_nullable
as String?,sellMode: null == sellMode ? _self.sellMode : sellMode // ignore: cast_nullable_to_non_nullable
as SellMode,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterModel].
extension RegisterModelPatterns on RegisterModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterModel value)  $default,){
final _that = this;
switch (_that) {
case _RegisterModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterModel value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String code,  String name,  int registerNumber,  String? parentRegisterId,  bool isMain,  bool isActive,  HardwareType type,  bool allowCash,  bool allowCard,  bool allowTransfer,  bool allowCredit,  bool allowVoucher,  bool allowOther,  bool allowRefunds,  String? boundDeviceId,  String? activeBillId,  int gridRows,  int gridCols,  String? displayCartJson,  SellMode sellMode,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterModel() when $default != null:
return $default(_that.id,_that.companyId,_that.code,_that.name,_that.registerNumber,_that.parentRegisterId,_that.isMain,_that.isActive,_that.type,_that.allowCash,_that.allowCard,_that.allowTransfer,_that.allowCredit,_that.allowVoucher,_that.allowOther,_that.allowRefunds,_that.boundDeviceId,_that.activeBillId,_that.gridRows,_that.gridCols,_that.displayCartJson,_that.sellMode,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String code,  String name,  int registerNumber,  String? parentRegisterId,  bool isMain,  bool isActive,  HardwareType type,  bool allowCash,  bool allowCard,  bool allowTransfer,  bool allowCredit,  bool allowVoucher,  bool allowOther,  bool allowRefunds,  String? boundDeviceId,  String? activeBillId,  int gridRows,  int gridCols,  String? displayCartJson,  SellMode sellMode,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _RegisterModel():
return $default(_that.id,_that.companyId,_that.code,_that.name,_that.registerNumber,_that.parentRegisterId,_that.isMain,_that.isActive,_that.type,_that.allowCash,_that.allowCard,_that.allowTransfer,_that.allowCredit,_that.allowVoucher,_that.allowOther,_that.allowRefunds,_that.boundDeviceId,_that.activeBillId,_that.gridRows,_that.gridCols,_that.displayCartJson,_that.sellMode,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String code,  String name,  int registerNumber,  String? parentRegisterId,  bool isMain,  bool isActive,  HardwareType type,  bool allowCash,  bool allowCard,  bool allowTransfer,  bool allowCredit,  bool allowVoucher,  bool allowOther,  bool allowRefunds,  String? boundDeviceId,  String? activeBillId,  int gridRows,  int gridCols,  String? displayCartJson,  SellMode sellMode,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _RegisterModel() when $default != null:
return $default(_that.id,_that.companyId,_that.code,_that.name,_that.registerNumber,_that.parentRegisterId,_that.isMain,_that.isActive,_that.type,_that.allowCash,_that.allowCard,_that.allowTransfer,_that.allowCredit,_that.allowVoucher,_that.allowOther,_that.allowRefunds,_that.boundDeviceId,_that.activeBillId,_that.gridRows,_that.gridCols,_that.displayCartJson,_that.sellMode,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterModel implements RegisterModel {
  const _RegisterModel({required this.id, required this.companyId, required this.code, this.name = '', this.registerNumber = 1, this.parentRegisterId, this.isMain = false, this.isActive = true, required this.type, this.allowCash = true, this.allowCard = true, this.allowTransfer = true, this.allowCredit = true, this.allowVoucher = true, this.allowOther = true, this.allowRefunds = false, this.boundDeviceId, this.activeBillId, this.gridRows = 5, this.gridCols = 8, this.displayCartJson, this.sellMode = SellMode.gastro, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String code;
@override@JsonKey() final  String name;
@override@JsonKey() final  int registerNumber;
@override final  String? parentRegisterId;
@override@JsonKey() final  bool isMain;
@override@JsonKey() final  bool isActive;
@override final  HardwareType type;
@override@JsonKey() final  bool allowCash;
@override@JsonKey() final  bool allowCard;
@override@JsonKey() final  bool allowTransfer;
@override@JsonKey() final  bool allowCredit;
@override@JsonKey() final  bool allowVoucher;
@override@JsonKey() final  bool allowOther;
@override@JsonKey() final  bool allowRefunds;
@override final  String? boundDeviceId;
@override final  String? activeBillId;
@override@JsonKey() final  int gridRows;
@override@JsonKey() final  int gridCols;
@override final  String? displayCartJson;
@override@JsonKey() final  SellMode sellMode;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of RegisterModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterModelCopyWith<_RegisterModel> get copyWith => __$RegisterModelCopyWithImpl<_RegisterModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.registerNumber, registerNumber) || other.registerNumber == registerNumber)&&(identical(other.parentRegisterId, parentRegisterId) || other.parentRegisterId == parentRegisterId)&&(identical(other.isMain, isMain) || other.isMain == isMain)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.type, type) || other.type == type)&&(identical(other.allowCash, allowCash) || other.allowCash == allowCash)&&(identical(other.allowCard, allowCard) || other.allowCard == allowCard)&&(identical(other.allowTransfer, allowTransfer) || other.allowTransfer == allowTransfer)&&(identical(other.allowCredit, allowCredit) || other.allowCredit == allowCredit)&&(identical(other.allowVoucher, allowVoucher) || other.allowVoucher == allowVoucher)&&(identical(other.allowOther, allowOther) || other.allowOther == allowOther)&&(identical(other.allowRefunds, allowRefunds) || other.allowRefunds == allowRefunds)&&(identical(other.boundDeviceId, boundDeviceId) || other.boundDeviceId == boundDeviceId)&&(identical(other.activeBillId, activeBillId) || other.activeBillId == activeBillId)&&(identical(other.gridRows, gridRows) || other.gridRows == gridRows)&&(identical(other.gridCols, gridCols) || other.gridCols == gridCols)&&(identical(other.displayCartJson, displayCartJson) || other.displayCartJson == displayCartJson)&&(identical(other.sellMode, sellMode) || other.sellMode == sellMode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,code,name,registerNumber,parentRegisterId,isMain,isActive,type,allowCash,allowCard,allowTransfer,allowCredit,allowVoucher,allowOther,allowRefunds,boundDeviceId,activeBillId,gridRows,gridCols,displayCartJson,sellMode,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'RegisterModel(id: $id, companyId: $companyId, code: $code, name: $name, registerNumber: $registerNumber, parentRegisterId: $parentRegisterId, isMain: $isMain, isActive: $isActive, type: $type, allowCash: $allowCash, allowCard: $allowCard, allowTransfer: $allowTransfer, allowCredit: $allowCredit, allowVoucher: $allowVoucher, allowOther: $allowOther, allowRefunds: $allowRefunds, boundDeviceId: $boundDeviceId, activeBillId: $activeBillId, gridRows: $gridRows, gridCols: $gridCols, displayCartJson: $displayCartJson, sellMode: $sellMode, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$RegisterModelCopyWith<$Res> implements $RegisterModelCopyWith<$Res> {
  factory _$RegisterModelCopyWith(_RegisterModel value, $Res Function(_RegisterModel) _then) = __$RegisterModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String code, String name, int registerNumber, String? parentRegisterId, bool isMain, bool isActive, HardwareType type, bool allowCash, bool allowCard, bool allowTransfer, bool allowCredit, bool allowVoucher, bool allowOther, bool allowRefunds, String? boundDeviceId, String? activeBillId, int gridRows, int gridCols, String? displayCartJson, SellMode sellMode, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$RegisterModelCopyWithImpl<$Res>
    implements _$RegisterModelCopyWith<$Res> {
  __$RegisterModelCopyWithImpl(this._self, this._then);

  final _RegisterModel _self;
  final $Res Function(_RegisterModel) _then;

/// Create a copy of RegisterModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? code = null,Object? name = null,Object? registerNumber = null,Object? parentRegisterId = freezed,Object? isMain = null,Object? isActive = null,Object? type = null,Object? allowCash = null,Object? allowCard = null,Object? allowTransfer = null,Object? allowCredit = null,Object? allowVoucher = null,Object? allowOther = null,Object? allowRefunds = null,Object? boundDeviceId = freezed,Object? activeBillId = freezed,Object? gridRows = null,Object? gridCols = null,Object? displayCartJson = freezed,Object? sellMode = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_RegisterModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,registerNumber: null == registerNumber ? _self.registerNumber : registerNumber // ignore: cast_nullable_to_non_nullable
as int,parentRegisterId: freezed == parentRegisterId ? _self.parentRegisterId : parentRegisterId // ignore: cast_nullable_to_non_nullable
as String?,isMain: null == isMain ? _self.isMain : isMain // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HardwareType,allowCash: null == allowCash ? _self.allowCash : allowCash // ignore: cast_nullable_to_non_nullable
as bool,allowCard: null == allowCard ? _self.allowCard : allowCard // ignore: cast_nullable_to_non_nullable
as bool,allowTransfer: null == allowTransfer ? _self.allowTransfer : allowTransfer // ignore: cast_nullable_to_non_nullable
as bool,allowCredit: null == allowCredit ? _self.allowCredit : allowCredit // ignore: cast_nullable_to_non_nullable
as bool,allowVoucher: null == allowVoucher ? _self.allowVoucher : allowVoucher // ignore: cast_nullable_to_non_nullable
as bool,allowOther: null == allowOther ? _self.allowOther : allowOther // ignore: cast_nullable_to_non_nullable
as bool,allowRefunds: null == allowRefunds ? _self.allowRefunds : allowRefunds // ignore: cast_nullable_to_non_nullable
as bool,boundDeviceId: freezed == boundDeviceId ? _self.boundDeviceId : boundDeviceId // ignore: cast_nullable_to_non_nullable
as String?,activeBillId: freezed == activeBillId ? _self.activeBillId : activeBillId // ignore: cast_nullable_to_non_nullable
as String?,gridRows: null == gridRows ? _self.gridRows : gridRows // ignore: cast_nullable_to_non_nullable
as int,gridCols: null == gridCols ? _self.gridCols : gridCols // ignore: cast_nullable_to_non_nullable
as int,displayCartJson: freezed == displayCartJson ? _self.displayCartJson : displayCartJson // ignore: cast_nullable_to_non_nullable
as String?,sellMode: null == sellMode ? _self.sellMode : sellMode // ignore: cast_nullable_to_non_nullable
as SellMode,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
