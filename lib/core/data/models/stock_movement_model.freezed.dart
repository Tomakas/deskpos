// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_movement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StockMovementModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String? get stockDocumentId => throw _privateConstructorUsedError;
  String get itemId => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  int? get purchasePrice => throw _privateConstructorUsedError;
  StockMovementDirection get direction => throw _privateConstructorUsedError;
  PurchasePriceStrategy? get purchasePriceStrategy =>
      throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of StockMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockMovementModelCopyWith<StockMovementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockMovementModelCopyWith<$Res> {
  factory $StockMovementModelCopyWith(
    StockMovementModel value,
    $Res Function(StockMovementModel) then,
  ) = _$StockMovementModelCopyWithImpl<$Res, StockMovementModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String? stockDocumentId,
    String itemId,
    double quantity,
    int? purchasePrice,
    StockMovementDirection direction,
    PurchasePriceStrategy? purchasePriceStrategy,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$StockMovementModelCopyWithImpl<$Res, $Val extends StockMovementModel>
    implements $StockMovementModelCopyWith<$Res> {
  _$StockMovementModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? stockDocumentId = freezed,
    Object? itemId = null,
    Object? quantity = null,
    Object? purchasePrice = freezed,
    Object? direction = null,
    Object? purchasePriceStrategy = freezed,
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
            stockDocumentId: freezed == stockDocumentId
                ? _value.stockDocumentId
                : stockDocumentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            itemId: null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            purchasePrice: freezed == purchasePrice
                ? _value.purchasePrice
                : purchasePrice // ignore: cast_nullable_to_non_nullable
                      as int?,
            direction: null == direction
                ? _value.direction
                : direction // ignore: cast_nullable_to_non_nullable
                      as StockMovementDirection,
            purchasePriceStrategy: freezed == purchasePriceStrategy
                ? _value.purchasePriceStrategy
                : purchasePriceStrategy // ignore: cast_nullable_to_non_nullable
                      as PurchasePriceStrategy?,
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
abstract class _$$StockMovementModelImplCopyWith<$Res>
    implements $StockMovementModelCopyWith<$Res> {
  factory _$$StockMovementModelImplCopyWith(
    _$StockMovementModelImpl value,
    $Res Function(_$StockMovementModelImpl) then,
  ) = __$$StockMovementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String? stockDocumentId,
    String itemId,
    double quantity,
    int? purchasePrice,
    StockMovementDirection direction,
    PurchasePriceStrategy? purchasePriceStrategy,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$StockMovementModelImplCopyWithImpl<$Res>
    extends _$StockMovementModelCopyWithImpl<$Res, _$StockMovementModelImpl>
    implements _$$StockMovementModelImplCopyWith<$Res> {
  __$$StockMovementModelImplCopyWithImpl(
    _$StockMovementModelImpl _value,
    $Res Function(_$StockMovementModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? stockDocumentId = freezed,
    Object? itemId = null,
    Object? quantity = null,
    Object? purchasePrice = freezed,
    Object? direction = null,
    Object? purchasePriceStrategy = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$StockMovementModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        stockDocumentId: freezed == stockDocumentId
            ? _value.stockDocumentId
            : stockDocumentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        itemId: null == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        purchasePrice: freezed == purchasePrice
            ? _value.purchasePrice
            : purchasePrice // ignore: cast_nullable_to_non_nullable
                  as int?,
        direction: null == direction
            ? _value.direction
            : direction // ignore: cast_nullable_to_non_nullable
                  as StockMovementDirection,
        purchasePriceStrategy: freezed == purchasePriceStrategy
            ? _value.purchasePriceStrategy
            : purchasePriceStrategy // ignore: cast_nullable_to_non_nullable
                  as PurchasePriceStrategy?,
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

class _$StockMovementModelImpl implements _StockMovementModel {
  const _$StockMovementModelImpl({
    required this.id,
    required this.companyId,
    this.stockDocumentId,
    required this.itemId,
    required this.quantity,
    this.purchasePrice,
    required this.direction,
    this.purchasePriceStrategy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String? stockDocumentId;
  @override
  final String itemId;
  @override
  final double quantity;
  @override
  final int? purchasePrice;
  @override
  final StockMovementDirection direction;
  @override
  final PurchasePriceStrategy? purchasePriceStrategy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'StockMovementModel(id: $id, companyId: $companyId, stockDocumentId: $stockDocumentId, itemId: $itemId, quantity: $quantity, purchasePrice: $purchasePrice, direction: $direction, purchasePriceStrategy: $purchasePriceStrategy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockMovementModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.stockDocumentId, stockDocumentId) ||
                other.stockDocumentId == stockDocumentId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.purchasePrice, purchasePrice) ||
                other.purchasePrice == purchasePrice) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.purchasePriceStrategy, purchasePriceStrategy) ||
                other.purchasePriceStrategy == purchasePriceStrategy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    companyId,
    stockDocumentId,
    itemId,
    quantity,
    purchasePrice,
    direction,
    purchasePriceStrategy,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of StockMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockMovementModelImplCopyWith<_$StockMovementModelImpl> get copyWith =>
      __$$StockMovementModelImplCopyWithImpl<_$StockMovementModelImpl>(
        this,
        _$identity,
      );
}

abstract class _StockMovementModel implements StockMovementModel {
  const factory _StockMovementModel({
    required final String id,
    required final String companyId,
    final String? stockDocumentId,
    required final String itemId,
    required final double quantity,
    final int? purchasePrice,
    required final StockMovementDirection direction,
    final PurchasePriceStrategy? purchasePriceStrategy,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$StockMovementModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String? get stockDocumentId;
  @override
  String get itemId;
  @override
  double get quantity;
  @override
  int? get purchasePrice;
  @override
  StockMovementDirection get direction;
  @override
  PurchasePriceStrategy? get purchasePriceStrategy;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of StockMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockMovementModelImplCopyWith<_$StockMovementModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
