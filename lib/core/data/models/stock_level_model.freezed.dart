// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_level_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StockLevelModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get warehouseId => throw _privateConstructorUsedError;
  String get itemId => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  double? get minQuantity => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of StockLevelModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockLevelModelCopyWith<StockLevelModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockLevelModelCopyWith<$Res> {
  factory $StockLevelModelCopyWith(
    StockLevelModel value,
    $Res Function(StockLevelModel) then,
  ) = _$StockLevelModelCopyWithImpl<$Res, StockLevelModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String warehouseId,
    String itemId,
    double quantity,
    double? minQuantity,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$StockLevelModelCopyWithImpl<$Res, $Val extends StockLevelModel>
    implements $StockLevelModelCopyWith<$Res> {
  _$StockLevelModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockLevelModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? warehouseId = null,
    Object? itemId = null,
    Object? quantity = null,
    Object? minQuantity = freezed,
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
            warehouseId: null == warehouseId
                ? _value.warehouseId
                : warehouseId // ignore: cast_nullable_to_non_nullable
                      as String,
            itemId: null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            minQuantity: freezed == minQuantity
                ? _value.minQuantity
                : minQuantity // ignore: cast_nullable_to_non_nullable
                      as double?,
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
abstract class _$$StockLevelModelImplCopyWith<$Res>
    implements $StockLevelModelCopyWith<$Res> {
  factory _$$StockLevelModelImplCopyWith(
    _$StockLevelModelImpl value,
    $Res Function(_$StockLevelModelImpl) then,
  ) = __$$StockLevelModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String warehouseId,
    String itemId,
    double quantity,
    double? minQuantity,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$StockLevelModelImplCopyWithImpl<$Res>
    extends _$StockLevelModelCopyWithImpl<$Res, _$StockLevelModelImpl>
    implements _$$StockLevelModelImplCopyWith<$Res> {
  __$$StockLevelModelImplCopyWithImpl(
    _$StockLevelModelImpl _value,
    $Res Function(_$StockLevelModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockLevelModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? warehouseId = null,
    Object? itemId = null,
    Object? quantity = null,
    Object? minQuantity = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$StockLevelModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        warehouseId: null == warehouseId
            ? _value.warehouseId
            : warehouseId // ignore: cast_nullable_to_non_nullable
                  as String,
        itemId: null == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        minQuantity: freezed == minQuantity
            ? _value.minQuantity
            : minQuantity // ignore: cast_nullable_to_non_nullable
                  as double?,
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

class _$StockLevelModelImpl implements _StockLevelModel {
  const _$StockLevelModelImpl({
    required this.id,
    required this.companyId,
    required this.warehouseId,
    required this.itemId,
    this.quantity = 0.0,
    this.minQuantity,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String warehouseId;
  @override
  final String itemId;
  @override
  @JsonKey()
  final double quantity;
  @override
  final double? minQuantity;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'StockLevelModel(id: $id, companyId: $companyId, warehouseId: $warehouseId, itemId: $itemId, quantity: $quantity, minQuantity: $minQuantity, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockLevelModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.minQuantity, minQuantity) ||
                other.minQuantity == minQuantity) &&
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
    warehouseId,
    itemId,
    quantity,
    minQuantity,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of StockLevelModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockLevelModelImplCopyWith<_$StockLevelModelImpl> get copyWith =>
      __$$StockLevelModelImplCopyWithImpl<_$StockLevelModelImpl>(
        this,
        _$identity,
      );
}

abstract class _StockLevelModel implements StockLevelModel {
  const factory _StockLevelModel({
    required final String id,
    required final String companyId,
    required final String warehouseId,
    required final String itemId,
    final double quantity,
    final double? minQuantity,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$StockLevelModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get warehouseId;
  @override
  String get itemId;
  @override
  double get quantity;
  @override
  double? get minQuantity;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of StockLevelModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockLevelModelImplCopyWith<_$StockLevelModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
