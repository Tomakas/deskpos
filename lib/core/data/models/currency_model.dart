import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency_model.freezed.dart';

@freezed
abstract class CurrencyModel with _$CurrencyModel {
  const factory CurrencyModel({
    required String id,
    required String code,
    required String symbol,
    required String name,
    required int decimalPlaces,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _CurrencyModel;
}
