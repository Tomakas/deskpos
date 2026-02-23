// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OrderItemModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get itemId => throw _privateConstructorUsedError;
  String get itemName => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  int get salePriceAtt => throw _privateConstructorUsedError;
  int get saleTaxRateAtt => throw _privateConstructorUsedError;
  int get saleTaxAmount => throw _privateConstructorUsedError;
  UnitType get unit => throw _privateConstructorUsedError;
  int get discount => throw _privateConstructorUsedError;
  DiscountType? get discountType => throw _privateConstructorUsedError;
  int get voucherDiscount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  PrepStatus get status => throw _privateConstructorUsedError;
  DateTime? get prepStartedAt => throw _privateConstructorUsedError;
  DateTime? get readyAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemModelCopyWith<OrderItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemModelCopyWith<$Res> {
  factory $OrderItemModelCopyWith(
    OrderItemModel value,
    $Res Function(OrderItemModel) then,
  ) = _$OrderItemModelCopyWithImpl<$Res, OrderItemModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String orderId,
    String itemId,
    String itemName,
    double quantity,
    int salePriceAtt,
    int saleTaxRateAtt,
    int saleTaxAmount,
    UnitType unit,
    int discount,
    DiscountType? discountType,
    int voucherDiscount,
    String? notes,
    PrepStatus status,
    DateTime? prepStartedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$OrderItemModelCopyWithImpl<$Res, $Val extends OrderItemModel>
    implements $OrderItemModelCopyWith<$Res> {
  _$OrderItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? orderId = null,
    Object? itemId = null,
    Object? itemName = null,
    Object? quantity = null,
    Object? salePriceAtt = null,
    Object? saleTaxRateAtt = null,
    Object? saleTaxAmount = null,
    Object? unit = null,
    Object? discount = null,
    Object? discountType = freezed,
    Object? voucherDiscount = null,
    Object? notes = freezed,
    Object? status = null,
    Object? prepStartedAt = freezed,
    Object? readyAt = freezed,
    Object? deliveredAt = freezed,
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
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            itemId: null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String,
            itemName: null == itemName
                ? _value.itemName
                : itemName // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            salePriceAtt: null == salePriceAtt
                ? _value.salePriceAtt
                : salePriceAtt // ignore: cast_nullable_to_non_nullable
                      as int,
            saleTaxRateAtt: null == saleTaxRateAtt
                ? _value.saleTaxRateAtt
                : saleTaxRateAtt // ignore: cast_nullable_to_non_nullable
                      as int,
            saleTaxAmount: null == saleTaxAmount
                ? _value.saleTaxAmount
                : saleTaxAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as UnitType,
            discount: null == discount
                ? _value.discount
                : discount // ignore: cast_nullable_to_non_nullable
                      as int,
            discountType: freezed == discountType
                ? _value.discountType
                : discountType // ignore: cast_nullable_to_non_nullable
                      as DiscountType?,
            voucherDiscount: null == voucherDiscount
                ? _value.voucherDiscount
                : voucherDiscount // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PrepStatus,
            prepStartedAt: freezed == prepStartedAt
                ? _value.prepStartedAt
                : prepStartedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            readyAt: freezed == readyAt
                ? _value.readyAt
                : readyAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deliveredAt: freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$OrderItemModelImplCopyWith<$Res>
    implements $OrderItemModelCopyWith<$Res> {
  factory _$$OrderItemModelImplCopyWith(
    _$OrderItemModelImpl value,
    $Res Function(_$OrderItemModelImpl) then,
  ) = __$$OrderItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String orderId,
    String itemId,
    String itemName,
    double quantity,
    int salePriceAtt,
    int saleTaxRateAtt,
    int saleTaxAmount,
    UnitType unit,
    int discount,
    DiscountType? discountType,
    int voucherDiscount,
    String? notes,
    PrepStatus status,
    DateTime? prepStartedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$OrderItemModelImplCopyWithImpl<$Res>
    extends _$OrderItemModelCopyWithImpl<$Res, _$OrderItemModelImpl>
    implements _$$OrderItemModelImplCopyWith<$Res> {
  __$$OrderItemModelImplCopyWithImpl(
    _$OrderItemModelImpl _value,
    $Res Function(_$OrderItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? orderId = null,
    Object? itemId = null,
    Object? itemName = null,
    Object? quantity = null,
    Object? salePriceAtt = null,
    Object? saleTaxRateAtt = null,
    Object? saleTaxAmount = null,
    Object? unit = null,
    Object? discount = null,
    Object? discountType = freezed,
    Object? voucherDiscount = null,
    Object? notes = freezed,
    Object? status = null,
    Object? prepStartedAt = freezed,
    Object? readyAt = freezed,
    Object? deliveredAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$OrderItemModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        itemId: null == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        salePriceAtt: null == salePriceAtt
            ? _value.salePriceAtt
            : salePriceAtt // ignore: cast_nullable_to_non_nullable
                  as int,
        saleTaxRateAtt: null == saleTaxRateAtt
            ? _value.saleTaxRateAtt
            : saleTaxRateAtt // ignore: cast_nullable_to_non_nullable
                  as int,
        saleTaxAmount: null == saleTaxAmount
            ? _value.saleTaxAmount
            : saleTaxAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as UnitType,
        discount: null == discount
            ? _value.discount
            : discount // ignore: cast_nullable_to_non_nullable
                  as int,
        discountType: freezed == discountType
            ? _value.discountType
            : discountType // ignore: cast_nullable_to_non_nullable
                  as DiscountType?,
        voucherDiscount: null == voucherDiscount
            ? _value.voucherDiscount
            : voucherDiscount // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PrepStatus,
        prepStartedAt: freezed == prepStartedAt
            ? _value.prepStartedAt
            : prepStartedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        readyAt: freezed == readyAt
            ? _value.readyAt
            : readyAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deliveredAt: freezed == deliveredAt
            ? _value.deliveredAt
            : deliveredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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

class _$OrderItemModelImpl implements _OrderItemModel {
  const _$OrderItemModelImpl({
    required this.id,
    required this.companyId,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.salePriceAtt,
    required this.saleTaxRateAtt,
    required this.saleTaxAmount,
    this.unit = UnitType.ks,
    this.discount = 0,
    this.discountType,
    this.voucherDiscount = 0,
    this.notes,
    required this.status,
    this.prepStartedAt,
    this.readyAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String orderId;
  @override
  final String itemId;
  @override
  final String itemName;
  @override
  final double quantity;
  @override
  final int salePriceAtt;
  @override
  final int saleTaxRateAtt;
  @override
  final int saleTaxAmount;
  @override
  @JsonKey()
  final UnitType unit;
  @override
  @JsonKey()
  final int discount;
  @override
  final DiscountType? discountType;
  @override
  @JsonKey()
  final int voucherDiscount;
  @override
  final String? notes;
  @override
  final PrepStatus status;
  @override
  final DateTime? prepStartedAt;
  @override
  final DateTime? readyAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'OrderItemModel(id: $id, companyId: $companyId, orderId: $orderId, itemId: $itemId, itemName: $itemName, quantity: $quantity, salePriceAtt: $salePriceAtt, saleTaxRateAtt: $saleTaxRateAtt, saleTaxAmount: $saleTaxAmount, unit: $unit, discount: $discount, discountType: $discountType, voucherDiscount: $voucherDiscount, notes: $notes, status: $status, prepStartedAt: $prepStartedAt, readyAt: $readyAt, deliveredAt: $deliveredAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.salePriceAtt, salePriceAtt) ||
                other.salePriceAtt == salePriceAtt) &&
            (identical(other.saleTaxRateAtt, saleTaxRateAtt) ||
                other.saleTaxRateAtt == saleTaxRateAtt) &&
            (identical(other.saleTaxAmount, saleTaxAmount) ||
                other.saleTaxAmount == saleTaxAmount) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.voucherDiscount, voucherDiscount) ||
                other.voucherDiscount == voucherDiscount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.prepStartedAt, prepStartedAt) ||
                other.prepStartedAt == prepStartedAt) &&
            (identical(other.readyAt, readyAt) || other.readyAt == readyAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
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
    orderId,
    itemId,
    itemName,
    quantity,
    salePriceAtt,
    saleTaxRateAtt,
    saleTaxAmount,
    unit,
    discount,
    discountType,
    voucherDiscount,
    notes,
    status,
    prepStartedAt,
    readyAt,
    deliveredAt,
    createdAt,
    updatedAt,
    deletedAt,
  ]);

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemModelImplCopyWith<_$OrderItemModelImpl> get copyWith =>
      __$$OrderItemModelImplCopyWithImpl<_$OrderItemModelImpl>(
        this,
        _$identity,
      );
}

abstract class _OrderItemModel implements OrderItemModel {
  const factory _OrderItemModel({
    required final String id,
    required final String companyId,
    required final String orderId,
    required final String itemId,
    required final String itemName,
    required final double quantity,
    required final int salePriceAtt,
    required final int saleTaxRateAtt,
    required final int saleTaxAmount,
    final UnitType unit,
    final int discount,
    final DiscountType? discountType,
    final int voucherDiscount,
    final String? notes,
    required final PrepStatus status,
    final DateTime? prepStartedAt,
    final DateTime? readyAt,
    final DateTime? deliveredAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$OrderItemModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get orderId;
  @override
  String get itemId;
  @override
  String get itemName;
  @override
  double get quantity;
  @override
  int get salePriceAtt;
  @override
  int get saleTaxRateAtt;
  @override
  int get saleTaxAmount;
  @override
  UnitType get unit;
  @override
  int get discount;
  @override
  DiscountType? get discountType;
  @override
  int get voucherDiscount;
  @override
  String? get notes;
  @override
  PrepStatus get status;
  @override
  DateTime? get prepStartedAt;
  @override
  DateTime? get readyAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemModelImplCopyWith<_$OrderItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
