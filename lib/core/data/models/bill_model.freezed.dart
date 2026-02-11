// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BillModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get sectionId => throw _privateConstructorUsedError;
  String? get tableId => throw _privateConstructorUsedError;
  String get openedByUserId => throw _privateConstructorUsedError;
  String get billNumber => throw _privateConstructorUsedError;
  int get numberOfGuests => throw _privateConstructorUsedError;
  bool get isTakeaway => throw _privateConstructorUsedError;
  BillStatus get status => throw _privateConstructorUsedError;
  String get currencyId => throw _privateConstructorUsedError;
  int get subtotalGross => throw _privateConstructorUsedError;
  int get subtotalNet => throw _privateConstructorUsedError;
  int get discountAmount => throw _privateConstructorUsedError;
  DiscountType? get discountType => throw _privateConstructorUsedError;
  int get taxTotal => throw _privateConstructorUsedError;
  int get totalGross => throw _privateConstructorUsedError;
  int get roundingAmount => throw _privateConstructorUsedError;
  int get paidAmount => throw _privateConstructorUsedError;
  int get loyaltyPointsUsed => throw _privateConstructorUsedError;
  int get loyaltyDiscountAmount => throw _privateConstructorUsedError;
  int get voucherDiscountAmount => throw _privateConstructorUsedError;
  String? get voucherId => throw _privateConstructorUsedError;
  DateTime get openedAt => throw _privateConstructorUsedError;
  DateTime? get closedAt => throw _privateConstructorUsedError;
  int? get mapPosX => throw _privateConstructorUsedError;
  int? get mapPosY => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of BillModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BillModelCopyWith<BillModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillModelCopyWith<$Res> {
  factory $BillModelCopyWith(BillModel value, $Res Function(BillModel) then) =
      _$BillModelCopyWithImpl<$Res, BillModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String? customerId,
    String? sectionId,
    String? tableId,
    String openedByUserId,
    String billNumber,
    int numberOfGuests,
    bool isTakeaway,
    BillStatus status,
    String currencyId,
    int subtotalGross,
    int subtotalNet,
    int discountAmount,
    DiscountType? discountType,
    int taxTotal,
    int totalGross,
    int roundingAmount,
    int paidAmount,
    int loyaltyPointsUsed,
    int loyaltyDiscountAmount,
    int voucherDiscountAmount,
    String? voucherId,
    DateTime openedAt,
    DateTime? closedAt,
    int? mapPosX,
    int? mapPosY,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$BillModelCopyWithImpl<$Res, $Val extends BillModel>
    implements $BillModelCopyWith<$Res> {
  _$BillModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BillModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? customerId = freezed,
    Object? sectionId = freezed,
    Object? tableId = freezed,
    Object? openedByUserId = null,
    Object? billNumber = null,
    Object? numberOfGuests = null,
    Object? isTakeaway = null,
    Object? status = null,
    Object? currencyId = null,
    Object? subtotalGross = null,
    Object? subtotalNet = null,
    Object? discountAmount = null,
    Object? discountType = freezed,
    Object? taxTotal = null,
    Object? totalGross = null,
    Object? roundingAmount = null,
    Object? paidAmount = null,
    Object? loyaltyPointsUsed = null,
    Object? loyaltyDiscountAmount = null,
    Object? voucherDiscountAmount = null,
    Object? voucherId = freezed,
    Object? openedAt = null,
    Object? closedAt = freezed,
    Object? mapPosX = freezed,
    Object? mapPosY = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            companyId: null == companyId
                ? _value.companyId
                : companyId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            sectionId: freezed == sectionId
                ? _value.sectionId
                : sectionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            tableId: freezed == tableId
                ? _value.tableId
                : tableId // ignore: cast_nullable_to_non_nullable
                      as String?,
            openedByUserId: null == openedByUserId
                ? _value.openedByUserId
                : openedByUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            billNumber: null == billNumber
                ? _value.billNumber
                : billNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            numberOfGuests: null == numberOfGuests
                ? _value.numberOfGuests
                : numberOfGuests // ignore: cast_nullable_to_non_nullable
                      as int,
            isTakeaway: null == isTakeaway
                ? _value.isTakeaway
                : isTakeaway // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BillStatus,
            currencyId: null == currencyId
                ? _value.currencyId
                : currencyId // ignore: cast_nullable_to_non_nullable
                      as String,
            subtotalGross: null == subtotalGross
                ? _value.subtotalGross
                : subtotalGross // ignore: cast_nullable_to_non_nullable
                      as int,
            subtotalNet: null == subtotalNet
                ? _value.subtotalNet
                : subtotalNet // ignore: cast_nullable_to_non_nullable
                      as int,
            discountAmount: null == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            discountType: freezed == discountType
                ? _value.discountType
                : discountType // ignore: cast_nullable_to_non_nullable
                      as DiscountType?,
            taxTotal: null == taxTotal
                ? _value.taxTotal
                : taxTotal // ignore: cast_nullable_to_non_nullable
                      as int,
            totalGross: null == totalGross
                ? _value.totalGross
                : totalGross // ignore: cast_nullable_to_non_nullable
                      as int,
            roundingAmount: null == roundingAmount
                ? _value.roundingAmount
                : roundingAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            paidAmount: null == paidAmount
                ? _value.paidAmount
                : paidAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            loyaltyPointsUsed: null == loyaltyPointsUsed
                ? _value.loyaltyPointsUsed
                : loyaltyPointsUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            loyaltyDiscountAmount: null == loyaltyDiscountAmount
                ? _value.loyaltyDiscountAmount
                : loyaltyDiscountAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            voucherDiscountAmount: null == voucherDiscountAmount
                ? _value.voucherDiscountAmount
                : voucherDiscountAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            voucherId: freezed == voucherId
                ? _value.voucherId
                : voucherId // ignore: cast_nullable_to_non_nullable
                      as String?,
            openedAt: null == openedAt
                ? _value.openedAt
                : openedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            closedAt: freezed == closedAt
                ? _value.closedAt
                : closedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            mapPosX: freezed == mapPosX
                ? _value.mapPosX
                : mapPosX // ignore: cast_nullable_to_non_nullable
                      as int?,
            mapPosY: freezed == mapPosY
                ? _value.mapPosY
                : mapPosY // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BillModelImplCopyWith<$Res>
    implements $BillModelCopyWith<$Res> {
  factory _$$BillModelImplCopyWith(
    _$BillModelImpl value,
    $Res Function(_$BillModelImpl) then,
  ) = __$$BillModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String? customerId,
    String? sectionId,
    String? tableId,
    String openedByUserId,
    String billNumber,
    int numberOfGuests,
    bool isTakeaway,
    BillStatus status,
    String currencyId,
    int subtotalGross,
    int subtotalNet,
    int discountAmount,
    DiscountType? discountType,
    int taxTotal,
    int totalGross,
    int roundingAmount,
    int paidAmount,
    int loyaltyPointsUsed,
    int loyaltyDiscountAmount,
    int voucherDiscountAmount,
    String? voucherId,
    DateTime openedAt,
    DateTime? closedAt,
    int? mapPosX,
    int? mapPosY,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$BillModelImplCopyWithImpl<$Res>
    extends _$BillModelCopyWithImpl<$Res, _$BillModelImpl>
    implements _$$BillModelImplCopyWith<$Res> {
  __$$BillModelImplCopyWithImpl(
    _$BillModelImpl _value,
    $Res Function(_$BillModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BillModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? customerId = freezed,
    Object? sectionId = freezed,
    Object? tableId = freezed,
    Object? openedByUserId = null,
    Object? billNumber = null,
    Object? numberOfGuests = null,
    Object? isTakeaway = null,
    Object? status = null,
    Object? currencyId = null,
    Object? subtotalGross = null,
    Object? subtotalNet = null,
    Object? discountAmount = null,
    Object? discountType = freezed,
    Object? taxTotal = null,
    Object? totalGross = null,
    Object? roundingAmount = null,
    Object? paidAmount = null,
    Object? loyaltyPointsUsed = null,
    Object? loyaltyDiscountAmount = null,
    Object? voucherDiscountAmount = null,
    Object? voucherId = freezed,
    Object? openedAt = null,
    Object? closedAt = freezed,
    Object? mapPosX = freezed,
    Object? mapPosY = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$BillModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        sectionId: freezed == sectionId
            ? _value.sectionId
            : sectionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        tableId: freezed == tableId
            ? _value.tableId
            : tableId // ignore: cast_nullable_to_non_nullable
                  as String?,
        openedByUserId: null == openedByUserId
            ? _value.openedByUserId
            : openedByUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        billNumber: null == billNumber
            ? _value.billNumber
            : billNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        numberOfGuests: null == numberOfGuests
            ? _value.numberOfGuests
            : numberOfGuests // ignore: cast_nullable_to_non_nullable
                  as int,
        isTakeaway: null == isTakeaway
            ? _value.isTakeaway
            : isTakeaway // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BillStatus,
        currencyId: null == currencyId
            ? _value.currencyId
            : currencyId // ignore: cast_nullable_to_non_nullable
                  as String,
        subtotalGross: null == subtotalGross
            ? _value.subtotalGross
            : subtotalGross // ignore: cast_nullable_to_non_nullable
                  as int,
        subtotalNet: null == subtotalNet
            ? _value.subtotalNet
            : subtotalNet // ignore: cast_nullable_to_non_nullable
                  as int,
        discountAmount: null == discountAmount
            ? _value.discountAmount
            : discountAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        discountType: freezed == discountType
            ? _value.discountType
            : discountType // ignore: cast_nullable_to_non_nullable
                  as DiscountType?,
        taxTotal: null == taxTotal
            ? _value.taxTotal
            : taxTotal // ignore: cast_nullable_to_non_nullable
                  as int,
        totalGross: null == totalGross
            ? _value.totalGross
            : totalGross // ignore: cast_nullable_to_non_nullable
                  as int,
        roundingAmount: null == roundingAmount
            ? _value.roundingAmount
            : roundingAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        paidAmount: null == paidAmount
            ? _value.paidAmount
            : paidAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        loyaltyPointsUsed: null == loyaltyPointsUsed
            ? _value.loyaltyPointsUsed
            : loyaltyPointsUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        loyaltyDiscountAmount: null == loyaltyDiscountAmount
            ? _value.loyaltyDiscountAmount
            : loyaltyDiscountAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        voucherDiscountAmount: null == voucherDiscountAmount
            ? _value.voucherDiscountAmount
            : voucherDiscountAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        voucherId: freezed == voucherId
            ? _value.voucherId
            : voucherId // ignore: cast_nullable_to_non_nullable
                  as String?,
        openedAt: null == openedAt
            ? _value.openedAt
            : openedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        closedAt: freezed == closedAt
            ? _value.closedAt
            : closedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        mapPosX: freezed == mapPosX
            ? _value.mapPosX
            : mapPosX // ignore: cast_nullable_to_non_nullable
                  as int?,
        mapPosY: freezed == mapPosY
            ? _value.mapPosY
            : mapPosY // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$BillModelImpl implements _BillModel {
  const _$BillModelImpl({
    required this.id,
    required this.companyId,
    this.customerId,
    this.sectionId,
    this.tableId,
    required this.openedByUserId,
    required this.billNumber,
    this.numberOfGuests = 0,
    this.isTakeaway = false,
    required this.status,
    required this.currencyId,
    this.subtotalGross = 0,
    this.subtotalNet = 0,
    this.discountAmount = 0,
    this.discountType,
    this.taxTotal = 0,
    this.totalGross = 0,
    this.roundingAmount = 0,
    this.paidAmount = 0,
    this.loyaltyPointsUsed = 0,
    this.loyaltyDiscountAmount = 0,
    this.voucherDiscountAmount = 0,
    this.voucherId,
    required this.openedAt,
    this.closedAt,
    this.mapPosX,
    this.mapPosY,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String? customerId;
  @override
  final String? sectionId;
  @override
  final String? tableId;
  @override
  final String openedByUserId;
  @override
  final String billNumber;
  @override
  @JsonKey()
  final int numberOfGuests;
  @override
  @JsonKey()
  final bool isTakeaway;
  @override
  final BillStatus status;
  @override
  final String currencyId;
  @override
  @JsonKey()
  final int subtotalGross;
  @override
  @JsonKey()
  final int subtotalNet;
  @override
  @JsonKey()
  final int discountAmount;
  @override
  final DiscountType? discountType;
  @override
  @JsonKey()
  final int taxTotal;
  @override
  @JsonKey()
  final int totalGross;
  @override
  @JsonKey()
  final int roundingAmount;
  @override
  @JsonKey()
  final int paidAmount;
  @override
  @JsonKey()
  final int loyaltyPointsUsed;
  @override
  @JsonKey()
  final int loyaltyDiscountAmount;
  @override
  @JsonKey()
  final int voucherDiscountAmount;
  @override
  final String? voucherId;
  @override
  final DateTime openedAt;
  @override
  final DateTime? closedAt;
  @override
  final int? mapPosX;
  @override
  final int? mapPosY;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'BillModel(id: $id, companyId: $companyId, customerId: $customerId, sectionId: $sectionId, tableId: $tableId, openedByUserId: $openedByUserId, billNumber: $billNumber, numberOfGuests: $numberOfGuests, isTakeaway: $isTakeaway, status: $status, currencyId: $currencyId, subtotalGross: $subtotalGross, subtotalNet: $subtotalNet, discountAmount: $discountAmount, discountType: $discountType, taxTotal: $taxTotal, totalGross: $totalGross, roundingAmount: $roundingAmount, paidAmount: $paidAmount, loyaltyPointsUsed: $loyaltyPointsUsed, loyaltyDiscountAmount: $loyaltyDiscountAmount, voucherDiscountAmount: $voucherDiscountAmount, voucherId: $voucherId, openedAt: $openedAt, closedAt: $closedAt, mapPosX: $mapPosX, mapPosY: $mapPosY, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.sectionId, sectionId) ||
                other.sectionId == sectionId) &&
            (identical(other.tableId, tableId) || other.tableId == tableId) &&
            (identical(other.openedByUserId, openedByUserId) ||
                other.openedByUserId == openedByUserId) &&
            (identical(other.billNumber, billNumber) ||
                other.billNumber == billNumber) &&
            (identical(other.numberOfGuests, numberOfGuests) ||
                other.numberOfGuests == numberOfGuests) &&
            (identical(other.isTakeaway, isTakeaway) ||
                other.isTakeaway == isTakeaway) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currencyId, currencyId) ||
                other.currencyId == currencyId) &&
            (identical(other.subtotalGross, subtotalGross) ||
                other.subtotalGross == subtotalGross) &&
            (identical(other.subtotalNet, subtotalNet) ||
                other.subtotalNet == subtotalNet) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.taxTotal, taxTotal) ||
                other.taxTotal == taxTotal) &&
            (identical(other.totalGross, totalGross) ||
                other.totalGross == totalGross) &&
            (identical(other.roundingAmount, roundingAmount) ||
                other.roundingAmount == roundingAmount) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.loyaltyPointsUsed, loyaltyPointsUsed) ||
                other.loyaltyPointsUsed == loyaltyPointsUsed) &&
            (identical(other.loyaltyDiscountAmount, loyaltyDiscountAmount) ||
                other.loyaltyDiscountAmount == loyaltyDiscountAmount) &&
            (identical(other.voucherDiscountAmount, voucherDiscountAmount) ||
                other.voucherDiscountAmount == voucherDiscountAmount) &&
            (identical(other.voucherId, voucherId) ||
                other.voucherId == voucherId) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.mapPosX, mapPosX) || other.mapPosX == mapPosX) &&
            (identical(other.mapPosY, mapPosY) || other.mapPosY == mapPosY) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    companyId,
    customerId,
    sectionId,
    tableId,
    openedByUserId,
    billNumber,
    numberOfGuests,
    isTakeaway,
    status,
    currencyId,
    subtotalGross,
    subtotalNet,
    discountAmount,
    discountType,
    taxTotal,
    totalGross,
    roundingAmount,
    paidAmount,
    loyaltyPointsUsed,
    loyaltyDiscountAmount,
    voucherDiscountAmount,
    voucherId,
    openedAt,
    closedAt,
    mapPosX,
    mapPosY,
    createdAt,
    updatedAt,
    deletedAt,
  ]);

  /// Create a copy of BillModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BillModelImplCopyWith<_$BillModelImpl> get copyWith =>
      __$$BillModelImplCopyWithImpl<_$BillModelImpl>(this, _$identity);
}

abstract class _BillModel implements BillModel {
  const factory _BillModel({
    required final String id,
    required final String companyId,
    final String? customerId,
    final String? sectionId,
    final String? tableId,
    required final String openedByUserId,
    required final String billNumber,
    final int numberOfGuests,
    final bool isTakeaway,
    required final BillStatus status,
    required final String currencyId,
    final int subtotalGross,
    final int subtotalNet,
    final int discountAmount,
    final DiscountType? discountType,
    final int taxTotal,
    final int totalGross,
    final int roundingAmount,
    final int paidAmount,
    final int loyaltyPointsUsed,
    final int loyaltyDiscountAmount,
    final int voucherDiscountAmount,
    final String? voucherId,
    required final DateTime openedAt,
    final DateTime? closedAt,
    final int? mapPosX,
    final int? mapPosY,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$BillModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String? get customerId;
  @override
  String? get sectionId;
  @override
  String? get tableId;
  @override
  String get openedByUserId;
  @override
  String get billNumber;
  @override
  int get numberOfGuests;
  @override
  bool get isTakeaway;
  @override
  BillStatus get status;
  @override
  String get currencyId;
  @override
  int get subtotalGross;
  @override
  int get subtotalNet;
  @override
  int get discountAmount;
  @override
  DiscountType? get discountType;
  @override
  int get taxTotal;
  @override
  int get totalGross;
  @override
  int get roundingAmount;
  @override
  int get paidAmount;
  @override
  int get loyaltyPointsUsed;
  @override
  int get loyaltyDiscountAmount;
  @override
  int get voucherDiscountAmount;
  @override
  String? get voucherId;
  @override
  DateTime get openedAt;
  @override
  DateTime? get closedAt;
  @override
  int? get mapPosX;
  @override
  int? get mapPosY;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of BillModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BillModelImplCopyWith<_$BillModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
