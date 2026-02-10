// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_document_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StockDocumentModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get warehouseId => throw _privateConstructorUsedError;
  String? get supplierId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get documentNumber => throw _privateConstructorUsedError;
  StockDocumentType get type => throw _privateConstructorUsedError;
  PurchasePriceStrategy? get purchasePriceStrategy =>
      throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  int get totalAmount => throw _privateConstructorUsedError;
  DateTime get documentDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of StockDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockDocumentModelCopyWith<StockDocumentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockDocumentModelCopyWith<$Res> {
  factory $StockDocumentModelCopyWith(
    StockDocumentModel value,
    $Res Function(StockDocumentModel) then,
  ) = _$StockDocumentModelCopyWithImpl<$Res, StockDocumentModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String warehouseId,
    String? supplierId,
    String userId,
    String documentNumber,
    StockDocumentType type,
    PurchasePriceStrategy? purchasePriceStrategy,
    String? note,
    int totalAmount,
    DateTime documentDate,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$StockDocumentModelCopyWithImpl<$Res, $Val extends StockDocumentModel>
    implements $StockDocumentModelCopyWith<$Res> {
  _$StockDocumentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? warehouseId = null,
    Object? supplierId = freezed,
    Object? userId = null,
    Object? documentNumber = null,
    Object? type = null,
    Object? purchasePriceStrategy = freezed,
    Object? note = freezed,
    Object? totalAmount = null,
    Object? documentDate = null,
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
            supplierId: freezed == supplierId
                ? _value.supplierId
                : supplierId // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            documentNumber: null == documentNumber
                ? _value.documentNumber
                : documentNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as StockDocumentType,
            purchasePriceStrategy: freezed == purchasePriceStrategy
                ? _value.purchasePriceStrategy
                : purchasePriceStrategy // ignore: cast_nullable_to_non_nullable
                      as PurchasePriceStrategy?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            documentDate: null == documentDate
                ? _value.documentDate
                : documentDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$StockDocumentModelImplCopyWith<$Res>
    implements $StockDocumentModelCopyWith<$Res> {
  factory _$$StockDocumentModelImplCopyWith(
    _$StockDocumentModelImpl value,
    $Res Function(_$StockDocumentModelImpl) then,
  ) = __$$StockDocumentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String warehouseId,
    String? supplierId,
    String userId,
    String documentNumber,
    StockDocumentType type,
    PurchasePriceStrategy? purchasePriceStrategy,
    String? note,
    int totalAmount,
    DateTime documentDate,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$StockDocumentModelImplCopyWithImpl<$Res>
    extends _$StockDocumentModelCopyWithImpl<$Res, _$StockDocumentModelImpl>
    implements _$$StockDocumentModelImplCopyWith<$Res> {
  __$$StockDocumentModelImplCopyWithImpl(
    _$StockDocumentModelImpl _value,
    $Res Function(_$StockDocumentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? warehouseId = null,
    Object? supplierId = freezed,
    Object? userId = null,
    Object? documentNumber = null,
    Object? type = null,
    Object? purchasePriceStrategy = freezed,
    Object? note = freezed,
    Object? totalAmount = null,
    Object? documentDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$StockDocumentModelImpl(
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
        supplierId: freezed == supplierId
            ? _value.supplierId
            : supplierId // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        documentNumber: null == documentNumber
            ? _value.documentNumber
            : documentNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as StockDocumentType,
        purchasePriceStrategy: freezed == purchasePriceStrategy
            ? _value.purchasePriceStrategy
            : purchasePriceStrategy // ignore: cast_nullable_to_non_nullable
                  as PurchasePriceStrategy?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        documentDate: null == documentDate
            ? _value.documentDate
            : documentDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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

class _$StockDocumentModelImpl implements _StockDocumentModel {
  const _$StockDocumentModelImpl({
    required this.id,
    required this.companyId,
    required this.warehouseId,
    this.supplierId,
    required this.userId,
    required this.documentNumber,
    required this.type,
    this.purchasePriceStrategy,
    this.note,
    this.totalAmount = 0,
    required this.documentDate,
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
  final String? supplierId;
  @override
  final String userId;
  @override
  final String documentNumber;
  @override
  final StockDocumentType type;
  @override
  final PurchasePriceStrategy? purchasePriceStrategy;
  @override
  final String? note;
  @override
  @JsonKey()
  final int totalAmount;
  @override
  final DateTime documentDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'StockDocumentModel(id: $id, companyId: $companyId, warehouseId: $warehouseId, supplierId: $supplierId, userId: $userId, documentNumber: $documentNumber, type: $type, purchasePriceStrategy: $purchasePriceStrategy, note: $note, totalAmount: $totalAmount, documentDate: $documentDate, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockDocumentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.documentNumber, documentNumber) ||
                other.documentNumber == documentNumber) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.purchasePriceStrategy, purchasePriceStrategy) ||
                other.purchasePriceStrategy == purchasePriceStrategy) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.documentDate, documentDate) ||
                other.documentDate == documentDate) &&
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
    supplierId,
    userId,
    documentNumber,
    type,
    purchasePriceStrategy,
    note,
    totalAmount,
    documentDate,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of StockDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockDocumentModelImplCopyWith<_$StockDocumentModelImpl> get copyWith =>
      __$$StockDocumentModelImplCopyWithImpl<_$StockDocumentModelImpl>(
        this,
        _$identity,
      );
}

abstract class _StockDocumentModel implements StockDocumentModel {
  const factory _StockDocumentModel({
    required final String id,
    required final String companyId,
    required final String warehouseId,
    final String? supplierId,
    required final String userId,
    required final String documentNumber,
    required final StockDocumentType type,
    final PurchasePriceStrategy? purchasePriceStrategy,
    final String? note,
    final int totalAmount,
    required final DateTime documentDate,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$StockDocumentModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get warehouseId;
  @override
  String? get supplierId;
  @override
  String get userId;
  @override
  String get documentNumber;
  @override
  StockDocumentType get type;
  @override
  PurchasePriceStrategy? get purchasePriceStrategy;
  @override
  String? get note;
  @override
  int get totalAmount;
  @override
  DateTime get documentDate;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of StockDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockDocumentModelImplCopyWith<_$StockDocumentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
