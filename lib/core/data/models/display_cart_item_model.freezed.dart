// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'display_cart_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DisplayCartItemModel {
  int get id => throw _privateConstructorUsedError;
  String get registerId => throw _privateConstructorUsedError;
  String get itemName => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  int get unitPrice => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  /// Create a copy of DisplayCartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisplayCartItemModelCopyWith<DisplayCartItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisplayCartItemModelCopyWith<$Res> {
  factory $DisplayCartItemModelCopyWith(
    DisplayCartItemModel value,
    $Res Function(DisplayCartItemModel) then,
  ) = _$DisplayCartItemModelCopyWithImpl<$Res, DisplayCartItemModel>;
  @useResult
  $Res call({
    int id,
    String registerId,
    String itemName,
    double quantity,
    int unitPrice,
    String? notes,
    int sortOrder,
  });
}

/// @nodoc
class _$DisplayCartItemModelCopyWithImpl<
  $Res,
  $Val extends DisplayCartItemModel
>
    implements $DisplayCartItemModelCopyWith<$Res> {
  _$DisplayCartItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DisplayCartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? registerId = null,
    Object? itemName = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? notes = freezed,
    Object? sortOrder = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            registerId: null == registerId
                ? _value.registerId
                : registerId // ignore: cast_nullable_to_non_nullable
                      as String,
            itemName: null == itemName
                ? _value.itemName
                : itemName // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DisplayCartItemModelImplCopyWith<$Res>
    implements $DisplayCartItemModelCopyWith<$Res> {
  factory _$$DisplayCartItemModelImplCopyWith(
    _$DisplayCartItemModelImpl value,
    $Res Function(_$DisplayCartItemModelImpl) then,
  ) = __$$DisplayCartItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String registerId,
    String itemName,
    double quantity,
    int unitPrice,
    String? notes,
    int sortOrder,
  });
}

/// @nodoc
class __$$DisplayCartItemModelImplCopyWithImpl<$Res>
    extends _$DisplayCartItemModelCopyWithImpl<$Res, _$DisplayCartItemModelImpl>
    implements _$$DisplayCartItemModelImplCopyWith<$Res> {
  __$$DisplayCartItemModelImplCopyWithImpl(
    _$DisplayCartItemModelImpl _value,
    $Res Function(_$DisplayCartItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DisplayCartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? registerId = null,
    Object? itemName = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? notes = freezed,
    Object? sortOrder = null,
  }) {
    return _then(
      _$DisplayCartItemModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        registerId: null == registerId
            ? _value.registerId
            : registerId // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DisplayCartItemModelImpl implements _DisplayCartItemModel {
  const _$DisplayCartItemModelImpl({
    required this.id,
    required this.registerId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    this.notes,
    required this.sortOrder,
  });

  @override
  final int id;
  @override
  final String registerId;
  @override
  final String itemName;
  @override
  final double quantity;
  @override
  final int unitPrice;
  @override
  final String? notes;
  @override
  final int sortOrder;

  @override
  String toString() {
    return 'DisplayCartItemModel(id: $id, registerId: $registerId, itemName: $itemName, quantity: $quantity, unitPrice: $unitPrice, notes: $notes, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisplayCartItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.registerId, registerId) ||
                other.registerId == registerId) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    registerId,
    itemName,
    quantity,
    unitPrice,
    notes,
    sortOrder,
  );

  /// Create a copy of DisplayCartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisplayCartItemModelImplCopyWith<_$DisplayCartItemModelImpl>
  get copyWith =>
      __$$DisplayCartItemModelImplCopyWithImpl<_$DisplayCartItemModelImpl>(
        this,
        _$identity,
      );
}

abstract class _DisplayCartItemModel implements DisplayCartItemModel {
  const factory _DisplayCartItemModel({
    required final int id,
    required final String registerId,
    required final String itemName,
    required final double quantity,
    required final int unitPrice,
    final String? notes,
    required final int sortOrder,
  }) = _$DisplayCartItemModelImpl;

  @override
  int get id;
  @override
  String get registerId;
  @override
  String get itemName;
  @override
  double get quantity;
  @override
  int get unitPrice;
  @override
  String? get notes;
  @override
  int get sortOrder;

  /// Create a copy of DisplayCartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisplayCartItemModelImplCopyWith<_$DisplayCartItemModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
