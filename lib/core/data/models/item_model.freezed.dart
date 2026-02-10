// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ItemModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  ItemType get itemType => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  int get unitPrice => throw _privateConstructorUsedError;
  String? get saleTaxRateId => throw _privateConstructorUsedError;
  bool get isSellable => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  UnitType get unit => throw _privateConstructorUsedError;
  String? get altSku => throw _privateConstructorUsedError;
  int? get purchasePrice => throw _privateConstructorUsedError;
  String? get purchaseTaxRateId => throw _privateConstructorUsedError;
  bool get isOnSale => throw _privateConstructorUsedError;
  bool get isStockTracked => throw _privateConstructorUsedError;
  String? get manufacturerId => throw _privateConstructorUsedError;
  String? get supplierId => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemModelCopyWith<ItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemModelCopyWith<$Res> {
  factory $ItemModelCopyWith(ItemModel value, $Res Function(ItemModel) then) =
      _$ItemModelCopyWithImpl<$Res, ItemModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String? categoryId,
    String name,
    String? description,
    ItemType itemType,
    String? sku,
    int unitPrice,
    String? saleTaxRateId,
    bool isSellable,
    bool isActive,
    UnitType unit,
    String? altSku,
    int? purchasePrice,
    String? purchaseTaxRateId,
    bool isOnSale,
    bool isStockTracked,
    String? manufacturerId,
    String? supplierId,
    String? parentId,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$ItemModelCopyWithImpl<$Res, $Val extends ItemModel>
    implements $ItemModelCopyWith<$Res> {
  _$ItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? categoryId = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? itemType = null,
    Object? sku = freezed,
    Object? unitPrice = null,
    Object? saleTaxRateId = freezed,
    Object? isSellable = null,
    Object? isActive = null,
    Object? unit = null,
    Object? altSku = freezed,
    Object? purchasePrice = freezed,
    Object? purchaseTaxRateId = freezed,
    Object? isOnSale = null,
    Object? isStockTracked = null,
    Object? manufacturerId = freezed,
    Object? supplierId = freezed,
    Object? parentId = freezed,
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
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            itemType: null == itemType
                ? _value.itemType
                : itemType // ignore: cast_nullable_to_non_nullable
                      as ItemType,
            sku: freezed == sku
                ? _value.sku
                : sku // ignore: cast_nullable_to_non_nullable
                      as String?,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            saleTaxRateId: freezed == saleTaxRateId
                ? _value.saleTaxRateId
                : saleTaxRateId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isSellable: null == isSellable
                ? _value.isSellable
                : isSellable // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as UnitType,
            altSku: freezed == altSku
                ? _value.altSku
                : altSku // ignore: cast_nullable_to_non_nullable
                      as String?,
            purchasePrice: freezed == purchasePrice
                ? _value.purchasePrice
                : purchasePrice // ignore: cast_nullable_to_non_nullable
                      as int?,
            purchaseTaxRateId: freezed == purchaseTaxRateId
                ? _value.purchaseTaxRateId
                : purchaseTaxRateId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isOnSale: null == isOnSale
                ? _value.isOnSale
                : isOnSale // ignore: cast_nullable_to_non_nullable
                      as bool,
            isStockTracked: null == isStockTracked
                ? _value.isStockTracked
                : isStockTracked // ignore: cast_nullable_to_non_nullable
                      as bool,
            manufacturerId: freezed == manufacturerId
                ? _value.manufacturerId
                : manufacturerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            supplierId: freezed == supplierId
                ? _value.supplierId
                : supplierId // ignore: cast_nullable_to_non_nullable
                      as String?,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$ItemModelImplCopyWith<$Res>
    implements $ItemModelCopyWith<$Res> {
  factory _$$ItemModelImplCopyWith(
    _$ItemModelImpl value,
    $Res Function(_$ItemModelImpl) then,
  ) = __$$ItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String? categoryId,
    String name,
    String? description,
    ItemType itemType,
    String? sku,
    int unitPrice,
    String? saleTaxRateId,
    bool isSellable,
    bool isActive,
    UnitType unit,
    String? altSku,
    int? purchasePrice,
    String? purchaseTaxRateId,
    bool isOnSale,
    bool isStockTracked,
    String? manufacturerId,
    String? supplierId,
    String? parentId,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$ItemModelImplCopyWithImpl<$Res>
    extends _$ItemModelCopyWithImpl<$Res, _$ItemModelImpl>
    implements _$$ItemModelImplCopyWith<$Res> {
  __$$ItemModelImplCopyWithImpl(
    _$ItemModelImpl _value,
    $Res Function(_$ItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? categoryId = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? itemType = null,
    Object? sku = freezed,
    Object? unitPrice = null,
    Object? saleTaxRateId = freezed,
    Object? isSellable = null,
    Object? isActive = null,
    Object? unit = null,
    Object? altSku = freezed,
    Object? purchasePrice = freezed,
    Object? purchaseTaxRateId = freezed,
    Object? isOnSale = null,
    Object? isStockTracked = null,
    Object? manufacturerId = freezed,
    Object? supplierId = freezed,
    Object? parentId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$ItemModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        itemType: null == itemType
            ? _value.itemType
            : itemType // ignore: cast_nullable_to_non_nullable
                  as ItemType,
        sku: freezed == sku
            ? _value.sku
            : sku // ignore: cast_nullable_to_non_nullable
                  as String?,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        saleTaxRateId: freezed == saleTaxRateId
            ? _value.saleTaxRateId
            : saleTaxRateId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isSellable: null == isSellable
            ? _value.isSellable
            : isSellable // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as UnitType,
        altSku: freezed == altSku
            ? _value.altSku
            : altSku // ignore: cast_nullable_to_non_nullable
                  as String?,
        purchasePrice: freezed == purchasePrice
            ? _value.purchasePrice
            : purchasePrice // ignore: cast_nullable_to_non_nullable
                  as int?,
        purchaseTaxRateId: freezed == purchaseTaxRateId
            ? _value.purchaseTaxRateId
            : purchaseTaxRateId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isOnSale: null == isOnSale
            ? _value.isOnSale
            : isOnSale // ignore: cast_nullable_to_non_nullable
                  as bool,
        isStockTracked: null == isStockTracked
            ? _value.isStockTracked
            : isStockTracked // ignore: cast_nullable_to_non_nullable
                  as bool,
        manufacturerId: freezed == manufacturerId
            ? _value.manufacturerId
            : manufacturerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        supplierId: freezed == supplierId
            ? _value.supplierId
            : supplierId // ignore: cast_nullable_to_non_nullable
                  as String?,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
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

class _$ItemModelImpl implements _ItemModel {
  const _$ItemModelImpl({
    required this.id,
    required this.companyId,
    this.categoryId,
    required this.name,
    this.description,
    required this.itemType,
    this.sku,
    required this.unitPrice,
    this.saleTaxRateId,
    this.isSellable = true,
    this.isActive = true,
    required this.unit,
    this.altSku,
    this.purchasePrice,
    this.purchaseTaxRateId,
    this.isOnSale = true,
    this.isStockTracked = false,
    this.manufacturerId,
    this.supplierId,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String? categoryId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final ItemType itemType;
  @override
  final String? sku;
  @override
  final int unitPrice;
  @override
  final String? saleTaxRateId;
  @override
  @JsonKey()
  final bool isSellable;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final UnitType unit;
  @override
  final String? altSku;
  @override
  final int? purchasePrice;
  @override
  final String? purchaseTaxRateId;
  @override
  @JsonKey()
  final bool isOnSale;
  @override
  @JsonKey()
  final bool isStockTracked;
  @override
  final String? manufacturerId;
  @override
  final String? supplierId;
  @override
  final String? parentId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'ItemModel(id: $id, companyId: $companyId, categoryId: $categoryId, name: $name, description: $description, itemType: $itemType, sku: $sku, unitPrice: $unitPrice, saleTaxRateId: $saleTaxRateId, isSellable: $isSellable, isActive: $isActive, unit: $unit, altSku: $altSku, purchasePrice: $purchasePrice, purchaseTaxRateId: $purchaseTaxRateId, isOnSale: $isOnSale, isStockTracked: $isStockTracked, manufacturerId: $manufacturerId, supplierId: $supplierId, parentId: $parentId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.itemType, itemType) ||
                other.itemType == itemType) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.saleTaxRateId, saleTaxRateId) ||
                other.saleTaxRateId == saleTaxRateId) &&
            (identical(other.isSellable, isSellable) ||
                other.isSellable == isSellable) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.altSku, altSku) || other.altSku == altSku) &&
            (identical(other.purchasePrice, purchasePrice) ||
                other.purchasePrice == purchasePrice) &&
            (identical(other.purchaseTaxRateId, purchaseTaxRateId) ||
                other.purchaseTaxRateId == purchaseTaxRateId) &&
            (identical(other.isOnSale, isOnSale) ||
                other.isOnSale == isOnSale) &&
            (identical(other.isStockTracked, isStockTracked) ||
                other.isStockTracked == isStockTracked) &&
            (identical(other.manufacturerId, manufacturerId) ||
                other.manufacturerId == manufacturerId) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
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
    categoryId,
    name,
    description,
    itemType,
    sku,
    unitPrice,
    saleTaxRateId,
    isSellable,
    isActive,
    unit,
    altSku,
    purchasePrice,
    purchaseTaxRateId,
    isOnSale,
    isStockTracked,
    manufacturerId,
    supplierId,
    parentId,
    createdAt,
    updatedAt,
    deletedAt,
  ]);

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemModelImplCopyWith<_$ItemModelImpl> get copyWith =>
      __$$ItemModelImplCopyWithImpl<_$ItemModelImpl>(this, _$identity);
}

abstract class _ItemModel implements ItemModel {
  const factory _ItemModel({
    required final String id,
    required final String companyId,
    final String? categoryId,
    required final String name,
    final String? description,
    required final ItemType itemType,
    final String? sku,
    required final int unitPrice,
    final String? saleTaxRateId,
    final bool isSellable,
    final bool isActive,
    required final UnitType unit,
    final String? altSku,
    final int? purchasePrice,
    final String? purchaseTaxRateId,
    final bool isOnSale,
    final bool isStockTracked,
    final String? manufacturerId,
    final String? supplierId,
    final String? parentId,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$ItemModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String? get categoryId;
  @override
  String get name;
  @override
  String? get description;
  @override
  ItemType get itemType;
  @override
  String? get sku;
  @override
  int get unitPrice;
  @override
  String? get saleTaxRateId;
  @override
  bool get isSellable;
  @override
  bool get isActive;
  @override
  UnitType get unit;
  @override
  String? get altSku;
  @override
  int? get purchasePrice;
  @override
  String? get purchaseTaxRateId;
  @override
  bool get isOnSale;
  @override
  bool get isStockTracked;
  @override
  String? get manufacturerId;
  @override
  String? get supplierId;
  @override
  String? get parentId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemModelImplCopyWith<_$ItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
