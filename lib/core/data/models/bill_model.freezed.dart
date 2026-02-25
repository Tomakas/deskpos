// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BillModel {

 String get id; String get companyId; String? get customerId; String? get customerName; String? get sectionId; String? get tableId; String? get registerId; String? get lastRegisterId; String? get registerSessionId; String get openedByUserId; String get billNumber; int get numberOfGuests; bool get isTakeaway; BillStatus get status; String get currencyId; int get subtotalGross; int get subtotalNet; int get discountAmount; DiscountType? get discountType; int get taxTotal; int get totalGross; int get roundingAmount; int get paidAmount; int get loyaltyPointsUsed; int get loyaltyDiscountAmount; int get loyaltyPointsEarned; int get voucherDiscountAmount; String? get voucherId; DateTime get openedAt; DateTime? get closedAt; int? get mapPosX; int? get mapPosY; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of BillModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillModelCopyWith<BillModel> get copyWith => _$BillModelCopyWithImpl<BillModel>(this as BillModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.tableId, tableId) || other.tableId == tableId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.lastRegisterId, lastRegisterId) || other.lastRegisterId == lastRegisterId)&&(identical(other.registerSessionId, registerSessionId) || other.registerSessionId == registerSessionId)&&(identical(other.openedByUserId, openedByUserId) || other.openedByUserId == openedByUserId)&&(identical(other.billNumber, billNumber) || other.billNumber == billNumber)&&(identical(other.numberOfGuests, numberOfGuests) || other.numberOfGuests == numberOfGuests)&&(identical(other.isTakeaway, isTakeaway) || other.isTakeaway == isTakeaway)&&(identical(other.status, status) || other.status == status)&&(identical(other.currencyId, currencyId) || other.currencyId == currencyId)&&(identical(other.subtotalGross, subtotalGross) || other.subtotalGross == subtotalGross)&&(identical(other.subtotalNet, subtotalNet) || other.subtotalNet == subtotalNet)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.totalGross, totalGross) || other.totalGross == totalGross)&&(identical(other.roundingAmount, roundingAmount) || other.roundingAmount == roundingAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.loyaltyPointsUsed, loyaltyPointsUsed) || other.loyaltyPointsUsed == loyaltyPointsUsed)&&(identical(other.loyaltyDiscountAmount, loyaltyDiscountAmount) || other.loyaltyDiscountAmount == loyaltyDiscountAmount)&&(identical(other.loyaltyPointsEarned, loyaltyPointsEarned) || other.loyaltyPointsEarned == loyaltyPointsEarned)&&(identical(other.voucherDiscountAmount, voucherDiscountAmount) || other.voucherDiscountAmount == voucherDiscountAmount)&&(identical(other.voucherId, voucherId) || other.voucherId == voucherId)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.mapPosX, mapPosX) || other.mapPosX == mapPosX)&&(identical(other.mapPosY, mapPosY) || other.mapPosY == mapPosY)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,customerId,customerName,sectionId,tableId,registerId,lastRegisterId,registerSessionId,openedByUserId,billNumber,numberOfGuests,isTakeaway,status,currencyId,subtotalGross,subtotalNet,discountAmount,discountType,taxTotal,totalGross,roundingAmount,paidAmount,loyaltyPointsUsed,loyaltyDiscountAmount,loyaltyPointsEarned,voucherDiscountAmount,voucherId,openedAt,closedAt,mapPosX,mapPosY,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'BillModel(id: $id, companyId: $companyId, customerId: $customerId, customerName: $customerName, sectionId: $sectionId, tableId: $tableId, registerId: $registerId, lastRegisterId: $lastRegisterId, registerSessionId: $registerSessionId, openedByUserId: $openedByUserId, billNumber: $billNumber, numberOfGuests: $numberOfGuests, isTakeaway: $isTakeaway, status: $status, currencyId: $currencyId, subtotalGross: $subtotalGross, subtotalNet: $subtotalNet, discountAmount: $discountAmount, discountType: $discountType, taxTotal: $taxTotal, totalGross: $totalGross, roundingAmount: $roundingAmount, paidAmount: $paidAmount, loyaltyPointsUsed: $loyaltyPointsUsed, loyaltyDiscountAmount: $loyaltyDiscountAmount, loyaltyPointsEarned: $loyaltyPointsEarned, voucherDiscountAmount: $voucherDiscountAmount, voucherId: $voucherId, openedAt: $openedAt, closedAt: $closedAt, mapPosX: $mapPosX, mapPosY: $mapPosY, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $BillModelCopyWith<$Res>  {
  factory $BillModelCopyWith(BillModel value, $Res Function(BillModel) _then) = _$BillModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String? customerId, String? customerName, String? sectionId, String? tableId, String? registerId, String? lastRegisterId, String? registerSessionId, String openedByUserId, String billNumber, int numberOfGuests, bool isTakeaway, BillStatus status, String currencyId, int subtotalGross, int subtotalNet, int discountAmount, DiscountType? discountType, int taxTotal, int totalGross, int roundingAmount, int paidAmount, int loyaltyPointsUsed, int loyaltyDiscountAmount, int loyaltyPointsEarned, int voucherDiscountAmount, String? voucherId, DateTime openedAt, DateTime? closedAt, int? mapPosX, int? mapPosY, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$BillModelCopyWithImpl<$Res>
    implements $BillModelCopyWith<$Res> {
  _$BillModelCopyWithImpl(this._self, this._then);

  final BillModel _self;
  final $Res Function(BillModel) _then;

/// Create a copy of BillModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? customerId = freezed,Object? customerName = freezed,Object? sectionId = freezed,Object? tableId = freezed,Object? registerId = freezed,Object? lastRegisterId = freezed,Object? registerSessionId = freezed,Object? openedByUserId = null,Object? billNumber = null,Object? numberOfGuests = null,Object? isTakeaway = null,Object? status = null,Object? currencyId = null,Object? subtotalGross = null,Object? subtotalNet = null,Object? discountAmount = null,Object? discountType = freezed,Object? taxTotal = null,Object? totalGross = null,Object? roundingAmount = null,Object? paidAmount = null,Object? loyaltyPointsUsed = null,Object? loyaltyDiscountAmount = null,Object? loyaltyPointsEarned = null,Object? voucherDiscountAmount = null,Object? voucherId = freezed,Object? openedAt = null,Object? closedAt = freezed,Object? mapPosX = freezed,Object? mapPosY = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,tableId: freezed == tableId ? _self.tableId : tableId // ignore: cast_nullable_to_non_nullable
as String?,registerId: freezed == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String?,lastRegisterId: freezed == lastRegisterId ? _self.lastRegisterId : lastRegisterId // ignore: cast_nullable_to_non_nullable
as String?,registerSessionId: freezed == registerSessionId ? _self.registerSessionId : registerSessionId // ignore: cast_nullable_to_non_nullable
as String?,openedByUserId: null == openedByUserId ? _self.openedByUserId : openedByUserId // ignore: cast_nullable_to_non_nullable
as String,billNumber: null == billNumber ? _self.billNumber : billNumber // ignore: cast_nullable_to_non_nullable
as String,numberOfGuests: null == numberOfGuests ? _self.numberOfGuests : numberOfGuests // ignore: cast_nullable_to_non_nullable
as int,isTakeaway: null == isTakeaway ? _self.isTakeaway : isTakeaway // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillStatus,currencyId: null == currencyId ? _self.currencyId : currencyId // ignore: cast_nullable_to_non_nullable
as String,subtotalGross: null == subtotalGross ? _self.subtotalGross : subtotalGross // ignore: cast_nullable_to_non_nullable
as int,subtotalNet: null == subtotalNet ? _self.subtotalNet : subtotalNet // ignore: cast_nullable_to_non_nullable
as int,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as int,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as DiscountType?,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as int,totalGross: null == totalGross ? _self.totalGross : totalGross // ignore: cast_nullable_to_non_nullable
as int,roundingAmount: null == roundingAmount ? _self.roundingAmount : roundingAmount // ignore: cast_nullable_to_non_nullable
as int,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as int,loyaltyPointsUsed: null == loyaltyPointsUsed ? _self.loyaltyPointsUsed : loyaltyPointsUsed // ignore: cast_nullable_to_non_nullable
as int,loyaltyDiscountAmount: null == loyaltyDiscountAmount ? _self.loyaltyDiscountAmount : loyaltyDiscountAmount // ignore: cast_nullable_to_non_nullable
as int,loyaltyPointsEarned: null == loyaltyPointsEarned ? _self.loyaltyPointsEarned : loyaltyPointsEarned // ignore: cast_nullable_to_non_nullable
as int,voucherDiscountAmount: null == voucherDiscountAmount ? _self.voucherDiscountAmount : voucherDiscountAmount // ignore: cast_nullable_to_non_nullable
as int,voucherId: freezed == voucherId ? _self.voucherId : voucherId // ignore: cast_nullable_to_non_nullable
as String?,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mapPosX: freezed == mapPosX ? _self.mapPosX : mapPosX // ignore: cast_nullable_to_non_nullable
as int?,mapPosY: freezed == mapPosY ? _self.mapPosY : mapPosY // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BillModel].
extension BillModelPatterns on BillModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillModel value)  $default,){
final _that = this;
switch (_that) {
case _BillModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillModel value)?  $default,){
final _that = this;
switch (_that) {
case _BillModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String? customerId,  String? customerName,  String? sectionId,  String? tableId,  String? registerId,  String? lastRegisterId,  String? registerSessionId,  String openedByUserId,  String billNumber,  int numberOfGuests,  bool isTakeaway,  BillStatus status,  String currencyId,  int subtotalGross,  int subtotalNet,  int discountAmount,  DiscountType? discountType,  int taxTotal,  int totalGross,  int roundingAmount,  int paidAmount,  int loyaltyPointsUsed,  int loyaltyDiscountAmount,  int loyaltyPointsEarned,  int voucherDiscountAmount,  String? voucherId,  DateTime openedAt,  DateTime? closedAt,  int? mapPosX,  int? mapPosY,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillModel() when $default != null:
return $default(_that.id,_that.companyId,_that.customerId,_that.customerName,_that.sectionId,_that.tableId,_that.registerId,_that.lastRegisterId,_that.registerSessionId,_that.openedByUserId,_that.billNumber,_that.numberOfGuests,_that.isTakeaway,_that.status,_that.currencyId,_that.subtotalGross,_that.subtotalNet,_that.discountAmount,_that.discountType,_that.taxTotal,_that.totalGross,_that.roundingAmount,_that.paidAmount,_that.loyaltyPointsUsed,_that.loyaltyDiscountAmount,_that.loyaltyPointsEarned,_that.voucherDiscountAmount,_that.voucherId,_that.openedAt,_that.closedAt,_that.mapPosX,_that.mapPosY,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String? customerId,  String? customerName,  String? sectionId,  String? tableId,  String? registerId,  String? lastRegisterId,  String? registerSessionId,  String openedByUserId,  String billNumber,  int numberOfGuests,  bool isTakeaway,  BillStatus status,  String currencyId,  int subtotalGross,  int subtotalNet,  int discountAmount,  DiscountType? discountType,  int taxTotal,  int totalGross,  int roundingAmount,  int paidAmount,  int loyaltyPointsUsed,  int loyaltyDiscountAmount,  int loyaltyPointsEarned,  int voucherDiscountAmount,  String? voucherId,  DateTime openedAt,  DateTime? closedAt,  int? mapPosX,  int? mapPosY,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _BillModel():
return $default(_that.id,_that.companyId,_that.customerId,_that.customerName,_that.sectionId,_that.tableId,_that.registerId,_that.lastRegisterId,_that.registerSessionId,_that.openedByUserId,_that.billNumber,_that.numberOfGuests,_that.isTakeaway,_that.status,_that.currencyId,_that.subtotalGross,_that.subtotalNet,_that.discountAmount,_that.discountType,_that.taxTotal,_that.totalGross,_that.roundingAmount,_that.paidAmount,_that.loyaltyPointsUsed,_that.loyaltyDiscountAmount,_that.loyaltyPointsEarned,_that.voucherDiscountAmount,_that.voucherId,_that.openedAt,_that.closedAt,_that.mapPosX,_that.mapPosY,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String? customerId,  String? customerName,  String? sectionId,  String? tableId,  String? registerId,  String? lastRegisterId,  String? registerSessionId,  String openedByUserId,  String billNumber,  int numberOfGuests,  bool isTakeaway,  BillStatus status,  String currencyId,  int subtotalGross,  int subtotalNet,  int discountAmount,  DiscountType? discountType,  int taxTotal,  int totalGross,  int roundingAmount,  int paidAmount,  int loyaltyPointsUsed,  int loyaltyDiscountAmount,  int loyaltyPointsEarned,  int voucherDiscountAmount,  String? voucherId,  DateTime openedAt,  DateTime? closedAt,  int? mapPosX,  int? mapPosY,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _BillModel() when $default != null:
return $default(_that.id,_that.companyId,_that.customerId,_that.customerName,_that.sectionId,_that.tableId,_that.registerId,_that.lastRegisterId,_that.registerSessionId,_that.openedByUserId,_that.billNumber,_that.numberOfGuests,_that.isTakeaway,_that.status,_that.currencyId,_that.subtotalGross,_that.subtotalNet,_that.discountAmount,_that.discountType,_that.taxTotal,_that.totalGross,_that.roundingAmount,_that.paidAmount,_that.loyaltyPointsUsed,_that.loyaltyDiscountAmount,_that.loyaltyPointsEarned,_that.voucherDiscountAmount,_that.voucherId,_that.openedAt,_that.closedAt,_that.mapPosX,_that.mapPosY,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _BillModel implements BillModel {
  const _BillModel({required this.id, required this.companyId, this.customerId, this.customerName, this.sectionId, this.tableId, this.registerId, this.lastRegisterId, this.registerSessionId, required this.openedByUserId, required this.billNumber, this.numberOfGuests = 0, this.isTakeaway = false, required this.status, required this.currencyId, this.subtotalGross = 0, this.subtotalNet = 0, this.discountAmount = 0, this.discountType, this.taxTotal = 0, this.totalGross = 0, this.roundingAmount = 0, this.paidAmount = 0, this.loyaltyPointsUsed = 0, this.loyaltyDiscountAmount = 0, this.loyaltyPointsEarned = 0, this.voucherDiscountAmount = 0, this.voucherId, required this.openedAt, this.closedAt, this.mapPosX, this.mapPosY, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String companyId;
@override final  String? customerId;
@override final  String? customerName;
@override final  String? sectionId;
@override final  String? tableId;
@override final  String? registerId;
@override final  String? lastRegisterId;
@override final  String? registerSessionId;
@override final  String openedByUserId;
@override final  String billNumber;
@override@JsonKey() final  int numberOfGuests;
@override@JsonKey() final  bool isTakeaway;
@override final  BillStatus status;
@override final  String currencyId;
@override@JsonKey() final  int subtotalGross;
@override@JsonKey() final  int subtotalNet;
@override@JsonKey() final  int discountAmount;
@override final  DiscountType? discountType;
@override@JsonKey() final  int taxTotal;
@override@JsonKey() final  int totalGross;
@override@JsonKey() final  int roundingAmount;
@override@JsonKey() final  int paidAmount;
@override@JsonKey() final  int loyaltyPointsUsed;
@override@JsonKey() final  int loyaltyDiscountAmount;
@override@JsonKey() final  int loyaltyPointsEarned;
@override@JsonKey() final  int voucherDiscountAmount;
@override final  String? voucherId;
@override final  DateTime openedAt;
@override final  DateTime? closedAt;
@override final  int? mapPosX;
@override final  int? mapPosY;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of BillModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillModelCopyWith<_BillModel> get copyWith => __$BillModelCopyWithImpl<_BillModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.tableId, tableId) || other.tableId == tableId)&&(identical(other.registerId, registerId) || other.registerId == registerId)&&(identical(other.lastRegisterId, lastRegisterId) || other.lastRegisterId == lastRegisterId)&&(identical(other.registerSessionId, registerSessionId) || other.registerSessionId == registerSessionId)&&(identical(other.openedByUserId, openedByUserId) || other.openedByUserId == openedByUserId)&&(identical(other.billNumber, billNumber) || other.billNumber == billNumber)&&(identical(other.numberOfGuests, numberOfGuests) || other.numberOfGuests == numberOfGuests)&&(identical(other.isTakeaway, isTakeaway) || other.isTakeaway == isTakeaway)&&(identical(other.status, status) || other.status == status)&&(identical(other.currencyId, currencyId) || other.currencyId == currencyId)&&(identical(other.subtotalGross, subtotalGross) || other.subtotalGross == subtotalGross)&&(identical(other.subtotalNet, subtotalNet) || other.subtotalNet == subtotalNet)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.totalGross, totalGross) || other.totalGross == totalGross)&&(identical(other.roundingAmount, roundingAmount) || other.roundingAmount == roundingAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.loyaltyPointsUsed, loyaltyPointsUsed) || other.loyaltyPointsUsed == loyaltyPointsUsed)&&(identical(other.loyaltyDiscountAmount, loyaltyDiscountAmount) || other.loyaltyDiscountAmount == loyaltyDiscountAmount)&&(identical(other.loyaltyPointsEarned, loyaltyPointsEarned) || other.loyaltyPointsEarned == loyaltyPointsEarned)&&(identical(other.voucherDiscountAmount, voucherDiscountAmount) || other.voucherDiscountAmount == voucherDiscountAmount)&&(identical(other.voucherId, voucherId) || other.voucherId == voucherId)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.mapPosX, mapPosX) || other.mapPosX == mapPosX)&&(identical(other.mapPosY, mapPosY) || other.mapPosY == mapPosY)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,customerId,customerName,sectionId,tableId,registerId,lastRegisterId,registerSessionId,openedByUserId,billNumber,numberOfGuests,isTakeaway,status,currencyId,subtotalGross,subtotalNet,discountAmount,discountType,taxTotal,totalGross,roundingAmount,paidAmount,loyaltyPointsUsed,loyaltyDiscountAmount,loyaltyPointsEarned,voucherDiscountAmount,voucherId,openedAt,closedAt,mapPosX,mapPosY,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'BillModel(id: $id, companyId: $companyId, customerId: $customerId, customerName: $customerName, sectionId: $sectionId, tableId: $tableId, registerId: $registerId, lastRegisterId: $lastRegisterId, registerSessionId: $registerSessionId, openedByUserId: $openedByUserId, billNumber: $billNumber, numberOfGuests: $numberOfGuests, isTakeaway: $isTakeaway, status: $status, currencyId: $currencyId, subtotalGross: $subtotalGross, subtotalNet: $subtotalNet, discountAmount: $discountAmount, discountType: $discountType, taxTotal: $taxTotal, totalGross: $totalGross, roundingAmount: $roundingAmount, paidAmount: $paidAmount, loyaltyPointsUsed: $loyaltyPointsUsed, loyaltyDiscountAmount: $loyaltyDiscountAmount, loyaltyPointsEarned: $loyaltyPointsEarned, voucherDiscountAmount: $voucherDiscountAmount, voucherId: $voucherId, openedAt: $openedAt, closedAt: $closedAt, mapPosX: $mapPosX, mapPosY: $mapPosY, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$BillModelCopyWith<$Res> implements $BillModelCopyWith<$Res> {
  factory _$BillModelCopyWith(_BillModel value, $Res Function(_BillModel) _then) = __$BillModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String? customerId, String? customerName, String? sectionId, String? tableId, String? registerId, String? lastRegisterId, String? registerSessionId, String openedByUserId, String billNumber, int numberOfGuests, bool isTakeaway, BillStatus status, String currencyId, int subtotalGross, int subtotalNet, int discountAmount, DiscountType? discountType, int taxTotal, int totalGross, int roundingAmount, int paidAmount, int loyaltyPointsUsed, int loyaltyDiscountAmount, int loyaltyPointsEarned, int voucherDiscountAmount, String? voucherId, DateTime openedAt, DateTime? closedAt, int? mapPosX, int? mapPosY, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$BillModelCopyWithImpl<$Res>
    implements _$BillModelCopyWith<$Res> {
  __$BillModelCopyWithImpl(this._self, this._then);

  final _BillModel _self;
  final $Res Function(_BillModel) _then;

/// Create a copy of BillModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? customerId = freezed,Object? customerName = freezed,Object? sectionId = freezed,Object? tableId = freezed,Object? registerId = freezed,Object? lastRegisterId = freezed,Object? registerSessionId = freezed,Object? openedByUserId = null,Object? billNumber = null,Object? numberOfGuests = null,Object? isTakeaway = null,Object? status = null,Object? currencyId = null,Object? subtotalGross = null,Object? subtotalNet = null,Object? discountAmount = null,Object? discountType = freezed,Object? taxTotal = null,Object? totalGross = null,Object? roundingAmount = null,Object? paidAmount = null,Object? loyaltyPointsUsed = null,Object? loyaltyDiscountAmount = null,Object? loyaltyPointsEarned = null,Object? voucherDiscountAmount = null,Object? voucherId = freezed,Object? openedAt = null,Object? closedAt = freezed,Object? mapPosX = freezed,Object? mapPosY = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_BillModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,tableId: freezed == tableId ? _self.tableId : tableId // ignore: cast_nullable_to_non_nullable
as String?,registerId: freezed == registerId ? _self.registerId : registerId // ignore: cast_nullable_to_non_nullable
as String?,lastRegisterId: freezed == lastRegisterId ? _self.lastRegisterId : lastRegisterId // ignore: cast_nullable_to_non_nullable
as String?,registerSessionId: freezed == registerSessionId ? _self.registerSessionId : registerSessionId // ignore: cast_nullable_to_non_nullable
as String?,openedByUserId: null == openedByUserId ? _self.openedByUserId : openedByUserId // ignore: cast_nullable_to_non_nullable
as String,billNumber: null == billNumber ? _self.billNumber : billNumber // ignore: cast_nullable_to_non_nullable
as String,numberOfGuests: null == numberOfGuests ? _self.numberOfGuests : numberOfGuests // ignore: cast_nullable_to_non_nullable
as int,isTakeaway: null == isTakeaway ? _self.isTakeaway : isTakeaway // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillStatus,currencyId: null == currencyId ? _self.currencyId : currencyId // ignore: cast_nullable_to_non_nullable
as String,subtotalGross: null == subtotalGross ? _self.subtotalGross : subtotalGross // ignore: cast_nullable_to_non_nullable
as int,subtotalNet: null == subtotalNet ? _self.subtotalNet : subtotalNet // ignore: cast_nullable_to_non_nullable
as int,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as int,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as DiscountType?,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as int,totalGross: null == totalGross ? _self.totalGross : totalGross // ignore: cast_nullable_to_non_nullable
as int,roundingAmount: null == roundingAmount ? _self.roundingAmount : roundingAmount // ignore: cast_nullable_to_non_nullable
as int,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as int,loyaltyPointsUsed: null == loyaltyPointsUsed ? _self.loyaltyPointsUsed : loyaltyPointsUsed // ignore: cast_nullable_to_non_nullable
as int,loyaltyDiscountAmount: null == loyaltyDiscountAmount ? _self.loyaltyDiscountAmount : loyaltyDiscountAmount // ignore: cast_nullable_to_non_nullable
as int,loyaltyPointsEarned: null == loyaltyPointsEarned ? _self.loyaltyPointsEarned : loyaltyPointsEarned // ignore: cast_nullable_to_non_nullable
as int,voucherDiscountAmount: null == voucherDiscountAmount ? _self.voucherDiscountAmount : voucherDiscountAmount // ignore: cast_nullable_to_non_nullable
as int,voucherId: freezed == voucherId ? _self.voucherId : voucherId // ignore: cast_nullable_to_non_nullable
as String?,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mapPosX: freezed == mapPosX ? _self.mapPosX : mapPosX // ignore: cast_nullable_to_non_nullable
as int?,mapPosY: freezed == mapPosY ? _self.mapPosY : mapPosY // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
