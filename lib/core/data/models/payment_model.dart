import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';

@freezed
abstract class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String id,
    required String companyId,
    required String billId,
    String? registerId,
    String? registerSessionId,
    String? userId,
    required String paymentMethodId,
    required int amount,
    required DateTime paidAt,
    required String currencyId,
    @Default(0) int tipIncludedAmount,
    String? notes,
    String? transactionId,
    String? paymentProvider,
    String? cardLast4,
    String? authorizationCode,
    String? foreignCurrencyId,
    int? foreignAmount,
    double? exchangeRate,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _PaymentModel;
}
