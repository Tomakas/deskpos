// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get billId => throw _privateConstructorUsedError;
  String get createdByUserId => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  PrepStatus get status => throw _privateConstructorUsedError;
  int get itemCount => throw _privateConstructorUsedError;
  int get subtotalGross => throw _privateConstructorUsedError;
  int get subtotalNet => throw _privateConstructorUsedError;
  int get taxTotal => throw _privateConstructorUsedError;
  bool get isStorno => throw _privateConstructorUsedError;
  String? get stornoSourceOrderId => throw _privateConstructorUsedError;
  DateTime? get prepStartedAt => throw _privateConstructorUsedError;
  DateTime? get readyAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
    OrderModel value,
    $Res Function(OrderModel) then,
  ) = _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String billId,
    String createdByUserId,
    String orderNumber,
    String? notes,
    PrepStatus status,
    int itemCount,
    int subtotalGross,
    int subtotalNet,
    int taxTotal,
    bool isStorno,
    String? stornoSourceOrderId,
    DateTime? prepStartedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? billId = null,
    Object? createdByUserId = null,
    Object? orderNumber = null,
    Object? notes = freezed,
    Object? status = null,
    Object? itemCount = null,
    Object? subtotalGross = null,
    Object? subtotalNet = null,
    Object? taxTotal = null,
    Object? isStorno = null,
    Object? stornoSourceOrderId = freezed,
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
            billId: null == billId
                ? _value.billId
                : billId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdByUserId: null == createdByUserId
                ? _value.createdByUserId
                : createdByUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            orderNumber: null == orderNumber
                ? _value.orderNumber
                : orderNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PrepStatus,
            itemCount: null == itemCount
                ? _value.itemCount
                : itemCount // ignore: cast_nullable_to_non_nullable
                      as int,
            subtotalGross: null == subtotalGross
                ? _value.subtotalGross
                : subtotalGross // ignore: cast_nullable_to_non_nullable
                      as int,
            subtotalNet: null == subtotalNet
                ? _value.subtotalNet
                : subtotalNet // ignore: cast_nullable_to_non_nullable
                      as int,
            taxTotal: null == taxTotal
                ? _value.taxTotal
                : taxTotal // ignore: cast_nullable_to_non_nullable
                      as int,
            isStorno: null == isStorno
                ? _value.isStorno
                : isStorno // ignore: cast_nullable_to_non_nullable
                      as bool,
            stornoSourceOrderId: freezed == stornoSourceOrderId
                ? _value.stornoSourceOrderId
                : stornoSourceOrderId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
    _$OrderModelImpl value,
    $Res Function(_$OrderModelImpl) then,
  ) = __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String billId,
    String createdByUserId,
    String orderNumber,
    String? notes,
    PrepStatus status,
    int itemCount,
    int subtotalGross,
    int subtotalNet,
    int taxTotal,
    bool isStorno,
    String? stornoSourceOrderId,
    DateTime? prepStartedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
    _$OrderModelImpl _value,
    $Res Function(_$OrderModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? billId = null,
    Object? createdByUserId = null,
    Object? orderNumber = null,
    Object? notes = freezed,
    Object? status = null,
    Object? itemCount = null,
    Object? subtotalGross = null,
    Object? subtotalNet = null,
    Object? taxTotal = null,
    Object? isStorno = null,
    Object? stornoSourceOrderId = freezed,
    Object? prepStartedAt = freezed,
    Object? readyAt = freezed,
    Object? deliveredAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$OrderModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        billId: null == billId
            ? _value.billId
            : billId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdByUserId: null == createdByUserId
            ? _value.createdByUserId
            : createdByUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        orderNumber: null == orderNumber
            ? _value.orderNumber
            : orderNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PrepStatus,
        itemCount: null == itemCount
            ? _value.itemCount
            : itemCount // ignore: cast_nullable_to_non_nullable
                  as int,
        subtotalGross: null == subtotalGross
            ? _value.subtotalGross
            : subtotalGross // ignore: cast_nullable_to_non_nullable
                  as int,
        subtotalNet: null == subtotalNet
            ? _value.subtotalNet
            : subtotalNet // ignore: cast_nullable_to_non_nullable
                  as int,
        taxTotal: null == taxTotal
            ? _value.taxTotal
            : taxTotal // ignore: cast_nullable_to_non_nullable
                  as int,
        isStorno: null == isStorno
            ? _value.isStorno
            : isStorno // ignore: cast_nullable_to_non_nullable
                  as bool,
        stornoSourceOrderId: freezed == stornoSourceOrderId
            ? _value.stornoSourceOrderId
            : stornoSourceOrderId // ignore: cast_nullable_to_non_nullable
                  as String?,
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

class _$OrderModelImpl implements _OrderModel {
  const _$OrderModelImpl({
    required this.id,
    required this.companyId,
    required this.billId,
    required this.createdByUserId,
    required this.orderNumber,
    this.notes,
    required this.status,
    this.itemCount = 0,
    this.subtotalGross = 0,
    this.subtotalNet = 0,
    this.taxTotal = 0,
    this.isStorno = false,
    this.stornoSourceOrderId,
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
  final String billId;
  @override
  final String createdByUserId;
  @override
  final String orderNumber;
  @override
  final String? notes;
  @override
  final PrepStatus status;
  @override
  @JsonKey()
  final int itemCount;
  @override
  @JsonKey()
  final int subtotalGross;
  @override
  @JsonKey()
  final int subtotalNet;
  @override
  @JsonKey()
  final int taxTotal;
  @override
  @JsonKey()
  final bool isStorno;
  @override
  final String? stornoSourceOrderId;
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
    return 'OrderModel(id: $id, companyId: $companyId, billId: $billId, createdByUserId: $createdByUserId, orderNumber: $orderNumber, notes: $notes, status: $status, itemCount: $itemCount, subtotalGross: $subtotalGross, subtotalNet: $subtotalNet, taxTotal: $taxTotal, isStorno: $isStorno, stornoSourceOrderId: $stornoSourceOrderId, prepStartedAt: $prepStartedAt, readyAt: $readyAt, deliveredAt: $deliveredAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.billId, billId) || other.billId == billId) &&
            (identical(other.createdByUserId, createdByUserId) ||
                other.createdByUserId == createdByUserId) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.itemCount, itemCount) ||
                other.itemCount == itemCount) &&
            (identical(other.subtotalGross, subtotalGross) ||
                other.subtotalGross == subtotalGross) &&
            (identical(other.subtotalNet, subtotalNet) ||
                other.subtotalNet == subtotalNet) &&
            (identical(other.taxTotal, taxTotal) ||
                other.taxTotal == taxTotal) &&
            (identical(other.isStorno, isStorno) ||
                other.isStorno == isStorno) &&
            (identical(other.stornoSourceOrderId, stornoSourceOrderId) ||
                other.stornoSourceOrderId == stornoSourceOrderId) &&
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
    billId,
    createdByUserId,
    orderNumber,
    notes,
    status,
    itemCount,
    subtotalGross,
    subtotalNet,
    taxTotal,
    isStorno,
    stornoSourceOrderId,
    prepStartedAt,
    readyAt,
    deliveredAt,
    createdAt,
    updatedAt,
    deletedAt,
  ]);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);
}

abstract class _OrderModel implements OrderModel {
  const factory _OrderModel({
    required final String id,
    required final String companyId,
    required final String billId,
    required final String createdByUserId,
    required final String orderNumber,
    final String? notes,
    required final PrepStatus status,
    final int itemCount,
    final int subtotalGross,
    final int subtotalNet,
    final int taxTotal,
    final bool isStorno,
    final String? stornoSourceOrderId,
    final DateTime? prepStartedAt,
    final DateTime? readyAt,
    final DateTime? deliveredAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$OrderModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get billId;
  @override
  String get createdByUserId;
  @override
  String get orderNumber;
  @override
  String? get notes;
  @override
  PrepStatus get status;
  @override
  int get itemCount;
  @override
  int get subtotalGross;
  @override
  int get subtotalNet;
  @override
  int get taxTotal;
  @override
  bool get isStorno;
  @override
  String? get stornoSourceOrderId;
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

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
