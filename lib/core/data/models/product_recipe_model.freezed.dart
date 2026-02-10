// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_recipe_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductRecipeModel {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get parentProductId => throw _privateConstructorUsedError;
  String get componentProductId => throw _privateConstructorUsedError;
  double get quantityRequired => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Create a copy of ProductRecipeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductRecipeModelCopyWith<ProductRecipeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductRecipeModelCopyWith<$Res> {
  factory $ProductRecipeModelCopyWith(
    ProductRecipeModel value,
    $Res Function(ProductRecipeModel) then,
  ) = _$ProductRecipeModelCopyWithImpl<$Res, ProductRecipeModel>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String parentProductId,
    String componentProductId,
    double quantityRequired,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$ProductRecipeModelCopyWithImpl<$Res, $Val extends ProductRecipeModel>
    implements $ProductRecipeModelCopyWith<$Res> {
  _$ProductRecipeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductRecipeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? parentProductId = null,
    Object? componentProductId = null,
    Object? quantityRequired = null,
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
            parentProductId: null == parentProductId
                ? _value.parentProductId
                : parentProductId // ignore: cast_nullable_to_non_nullable
                      as String,
            componentProductId: null == componentProductId
                ? _value.componentProductId
                : componentProductId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantityRequired: null == quantityRequired
                ? _value.quantityRequired
                : quantityRequired // ignore: cast_nullable_to_non_nullable
                      as double,
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
abstract class _$$ProductRecipeModelImplCopyWith<$Res>
    implements $ProductRecipeModelCopyWith<$Res> {
  factory _$$ProductRecipeModelImplCopyWith(
    _$ProductRecipeModelImpl value,
    $Res Function(_$ProductRecipeModelImpl) then,
  ) = __$$ProductRecipeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String parentProductId,
    String componentProductId,
    double quantityRequired,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$ProductRecipeModelImplCopyWithImpl<$Res>
    extends _$ProductRecipeModelCopyWithImpl<$Res, _$ProductRecipeModelImpl>
    implements _$$ProductRecipeModelImplCopyWith<$Res> {
  __$$ProductRecipeModelImplCopyWithImpl(
    _$ProductRecipeModelImpl _value,
    $Res Function(_$ProductRecipeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductRecipeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? parentProductId = null,
    Object? componentProductId = null,
    Object? quantityRequired = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$ProductRecipeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        parentProductId: null == parentProductId
            ? _value.parentProductId
            : parentProductId // ignore: cast_nullable_to_non_nullable
                  as String,
        componentProductId: null == componentProductId
            ? _value.componentProductId
            : componentProductId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantityRequired: null == quantityRequired
            ? _value.quantityRequired
            : quantityRequired // ignore: cast_nullable_to_non_nullable
                  as double,
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

class _$ProductRecipeModelImpl implements _ProductRecipeModel {
  const _$ProductRecipeModelImpl({
    required this.id,
    required this.companyId,
    required this.parentProductId,
    required this.componentProductId,
    required this.quantityRequired,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String parentProductId;
  @override
  final String componentProductId;
  @override
  final double quantityRequired;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'ProductRecipeModel(id: $id, companyId: $companyId, parentProductId: $parentProductId, componentProductId: $componentProductId, quantityRequired: $quantityRequired, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductRecipeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.parentProductId, parentProductId) ||
                other.parentProductId == parentProductId) &&
            (identical(other.componentProductId, componentProductId) ||
                other.componentProductId == componentProductId) &&
            (identical(other.quantityRequired, quantityRequired) ||
                other.quantityRequired == quantityRequired) &&
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
    parentProductId,
    componentProductId,
    quantityRequired,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of ProductRecipeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductRecipeModelImplCopyWith<_$ProductRecipeModelImpl> get copyWith =>
      __$$ProductRecipeModelImplCopyWithImpl<_$ProductRecipeModelImpl>(
        this,
        _$identity,
      );
}

abstract class _ProductRecipeModel implements ProductRecipeModel {
  const factory _ProductRecipeModel({
    required final String id,
    required final String companyId,
    required final String parentProductId,
    required final String componentProductId,
    required final double quantityRequired,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$ProductRecipeModelImpl;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get parentProductId;
  @override
  String get componentProductId;
  @override
  double get quantityRequired;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of ProductRecipeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductRecipeModelImplCopyWith<_$ProductRecipeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
