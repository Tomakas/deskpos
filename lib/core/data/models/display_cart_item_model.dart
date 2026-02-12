import 'package:freezed_annotation/freezed_annotation.dart';

part 'display_cart_item_model.freezed.dart';

@freezed
class DisplayCartItemModel with _$DisplayCartItemModel {
  const factory DisplayCartItemModel({
    required int id,
    required String registerId,
    required String itemName,
    required double quantity,
    required int unitPrice,
    String? notes,
    required int sortOrder,
  }) = _DisplayCartItemModel;
}
