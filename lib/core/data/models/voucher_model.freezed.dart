// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voucher_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VoucherModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  VoucherType get type => throw _privateConstructorUsedError;
  VoucherStatus get status => throw _privateConstructorUsedError;
  int get value => throw _privateConstructorUsedError;
  DiscountType? get discountType => throw _privateConstructorUsedError;
  VoucherDiscountScope? get discountScope => throw _privateConstructorUsedError;
  String? get itemId => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  int? get minOrderValue => throw _privateConstructorUsedError;
  int get maxUses => throw _privateConstructorUsedError;
  int get usedCount => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get redeemedAt => throw _privateConstructorUsedError;
  String? get redeemedOnBillId => throw _privateConstructorUsedError;
  String? get sourceBillId => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of VoucherModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoucherModelCopyWith<VoucherModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoucherModelCopyWith<$Res> {
  factory $VoucherModelCopyWith(
    VoucherModel value,
    $Res Function(VoucherModel) then,
  ) = _$VoucherModelCopyWithImpl<$Res, VoucherModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String code,
    VoucherType type,
    VoucherStatus status,
    int value,
    DiscountType? discountType,
    VoucherDiscountScope? discountScope,
    String? itemId,
    String? categoryId,
    int? minOrderValue,
    int maxUses,
    int usedCount,
    String? customerId,
    DateTime? expiresAt,
    DateTime? redeemedAt,
    String? redeemedOnBillId,
    String? sourceBillId,
    String? note,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$VoucherModelCopyWithImpl<$Res, $Val extends VoucherModel>
    implements $VoucherModelCopyWith<$Res> {
  _$VoucherModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoucherModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? code = null,
    Object? type = null,
    Object? status = null,
    Object? value = null,
    Object? discountType = freezed,
    Object? discountScope = freezed,
    Object? itemId = freezed,
    Object? categoryId = freezed,
    Object? minOrderValue = freezed,
    Object? maxUses = null,
    Object? usedCount = null,
    Object? customerId = freezed,
    Object? expiresAt = freezed,
    Object? redeemedAt = freezed,
    Object? redeemedOnBillId = freezed,
    Object? sourceBillId = freezed,
    Object? note = freezed,
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
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as VoucherType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as VoucherStatus,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as int,
            discountType: freezed == discountType
                ? _value.discountType
                : discountType // ignore: cast_nullable_to_non_nullable
                      as DiscountType?,
            discountScope: freezed == discountScope
                ? _value.discountScope
                : discountScope // ignore: cast_nullable_to_non_nullable
                      as VoucherDiscountScope?,
            itemId: freezed == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            minOrderValue: freezed == minOrderValue
                ? _value.minOrderValue
                : minOrderValue // ignore: cast_nullable_to_non_nullable
                      as int?,
            maxUses: null == maxUses
                ? _value.maxUses
                : maxUses // ignore: cast_nullable_to_non_nullable
                      as int,
            usedCount: null == usedCount
                ? _value.usedCount
                : usedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            customerId: freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            redeemedAt: freezed == redeemedAt
                ? _value.redeemedAt
                : redeemedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            redeemedOnBillId: freezed == redeemedOnBillId
                ? _value.redeemedOnBillId
                : redeemedOnBillId // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceBillId: freezed == sourceBillId
                ? _value.sourceBillId
                : sourceBillId // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
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
abstract class _$$VoucherModelImplCopyWith<$Res>
    implements $VoucherModelCopyWith<$Res> {
  factory _$$VoucherModelImplCopyWith(
    _$VoucherModelImpl value,
    $Res Function(_$VoucherModelImpl) then,
  ) = __$$VoucherModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String code,
    VoucherType type,
    VoucherStatus status,
    int value,
    DiscountType? discountType,
    VoucherDiscountScope? discountScope,
    String? itemId,
    String? categoryId,
    int? minOrderValue,
    int maxUses,
    int usedCount,
    String? customerId,
    DateTime? expiresAt,
    DateTime? redeemedAt,
    String? redeemedOnBillId,
    String? sourceBillId,
    String? note,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$VoucherModelImplCopyWithImpl<$Res>
    extends _$VoucherModelCopyWithImpl<$Res, _$VoucherModelImpl>
    implements _$$VoucherModelImplCopyWith<$Res> {
  __$$VoucherModelImplCopyWithImpl(
    _$VoucherModelImpl _value,
    $Res Function(_$VoucherModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VoucherModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? code = null,
    Object? type = null,
    Object? status = null,
    Object? value = null,
    Object? discountType = freezed,
    Object? discountScope = freezed,
    Object? itemId = freezed,
    Object? categoryId = freezed,
    Object? minOrderValue = freezed,
    Object? maxUses = null,
    Object? usedCount = null,
    Object? customerId = freezed,
    Object? expiresAt = freezed,
    Object? redeemedAt = freezed,
    Object? redeemedOnBillId = freezed,
    Object? sourceBillId = freezed,
    Object? note = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$VoucherModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as VoucherType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as VoucherStatus,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as int,
        discountType: freezed == discountType
            ? _value.discountType
            : discountType // ignore: cast_nullable_to_non_nullable
                  as DiscountType?,
        discountScope: freezed == discountScope
            ? _value.discountScope
            : discountScope // ignore: cast_nullable_to_non_nullable
                  as VoucherDiscountScope?,
        itemId: freezed == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        minOrderValue: freezed == minOrderValue
            ? _value.minOrderValue
            : minOrderValue // ignore: cast_nullable_to_non_nullable
                  as int?,
        maxUses: null == maxUses
            ? _value.maxUses
            : maxUses // ignore: cast_nullable_to_non_nullable
                  as int,
        usedCount: null == usedCount
            ? _value.usedCount
            : usedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        redeemedAt: freezed == redeemedAt
            ? _value.redeemedAt
            : redeemedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        redeemedOnBillId: freezed == redeemedOnBillId
            ? _value.redeemedOnBillId
            : redeemedOnBillId // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceBillId: freezed == sourceBillId
            ? _value.sourceBillId
            : sourceBillId // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
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

class _$VoucherModelImpl implements _VoucherModel {
  const _$VoucherModelImpl({
    required this.id,
    required this.companyId,
    required this.code,
    required this.type,
    required this.status,
    required this.value,
    this.discountType,
    this.discountScope,
    this.itemId,
    this.categoryId,
    this.minOrderValue,
    this.maxUses = 1,
    this.usedCount = 0,
    this.customerId,
    this.expiresAt,
    this.redeemedAt,
    this.redeemedOnBillId,
    this.sourceBillId,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String code;
  @override
  final VoucherType type;
  @override
  final VoucherStatus status;
  @override
  final int value;
  @override
  final DiscountType? discountType;
  @override
  final VoucherDiscountScope? discountScope;
  @override
  final String? itemId;
  @override
  final String? categoryId;
  @override
  final int? minOrderValue;
  @override
  @JsonKey()
  final int maxUses;
  @override
  @JsonKey()
  final int usedCount;
  @override
  final String? customerId;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime? redeemedAt;
  @override
  final String? redeemedOnBillId;
  @override
  final String? sourceBillId;
  @override
  final String? note;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'VoucherModel(id: $id, companyId: $companyId, code: $code, type: $type, status: $status, value: $value, discountType: $discountType, discountScope: $discountScope, itemId: $itemId, categoryId: $categoryId, minOrderValue: $minOrderValue, maxUses: $maxUses, usedCount: $usedCount, customerId: $customerId, expiresAt: $expiresAt, redeemedAt: $redeemedAt, redeemedOnBillId: $redeemedOnBillId, sourceBillId: $sourceBillId, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoucherModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.discountScope, discountScope) ||
                other.discountScope == discountScope) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.minOrderValue, minOrderValue) ||
                other.minOrderValue == minOrderValue) &&
            (identical(other.maxUses, maxUses) || other.maxUses == maxUses) &&
            (identical(other.usedCount, usedCount) ||
                other.usedCount == usedCount) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.redeemedAt, redeemedAt) ||
                other.redeemedAt == redeemedAt) &&
            (identical(other.redeemedOnBillId, redeemedOnBillId) ||
                other.redeemedOnBillId == redeemedOnBillId) &&
            (identical(other.sourceBillId, sourceBillId) ||
                other.sourceBillId == sourceBillId) &&
            (identical(other.note, note) || other.note == note) &&
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
    code,
    type,
    status,
    value,
    discountType,
    discountScope,
    itemId,
    categoryId,
    minOrderValue,
    maxUses,
    usedCount,
    customerId,
    expiresAt,
    redeemedAt,
    redeemedOnBillId,
    sourceBillId,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  ]);

  /// Create a copy of VoucherModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoucherModelImplCopyWith<_$VoucherModelImpl> get copyWith =>
      __$$VoucherModelImplCopyWithImpl<_$VoucherModelImpl>(this, _$identity);
}

abstract class _VoucherModel implements VoucherModel {
  const factory _VoucherModel({
    required final String id,
    required final String companyId,
    required final String code,
    required final VoucherType type,
    required final VoucherStatus status,
    required final int value,
    final DiscountType? discountType,
    final VoucherDiscountScope? discountScope,
    final String? itemId,
    final String? categoryId,
    final int? minOrderValue,
    final int maxUses,
    final int usedCount,
    final String? customerId,
    final DateTime? expiresAt,
    final DateTime? redeemedAt,
    final String? redeemedOnBillId,
    final String? sourceBillId,
    final String? note,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$VoucherModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get code;
  @override
  VoucherType get type;
  @override
  VoucherStatus get status;
  @override
  int get value;
  @override
  DiscountType? get discountType;
  @override
  VoucherDiscountScope? get discountScope;
  @override
  String? get itemId;
  @override
  String? get categoryId;
  @override
  int? get minOrderValue;
  @override
  int get maxUses;
  @override
  int get usedCount;
  @override
  String? get customerId;
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get redeemedAt;
  @override
  String? get redeemedOnBillId;
  @override
  String? get sourceBillId;
  @override
  String? get note;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of VoucherModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoucherModelImplCopyWith<_$VoucherModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
