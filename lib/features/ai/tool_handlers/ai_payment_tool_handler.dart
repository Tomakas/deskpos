import 'dart:convert';

import '../../../core/data/repositories/payment_method_repository.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

/// Handles payment-domain AI tool calls.
class AiPaymentToolHandler {
  AiPaymentToolHandler({required PaymentMethodRepository paymentMethodRepo})
      : _paymentMethodRepo = paymentMethodRepo;

  final PaymentMethodRepository _paymentMethodRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        'list_payment_methods' => _listPaymentMethods(companyId),
        _ => AiCommandError('Unknown payment tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Payment tool handler error', tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  Future<AiCommandResult> _listPaymentMethods(String companyId) async {
    final methods = await _paymentMethodRepo.watchAll(companyId).first;
    final json = methods
        .take(1000)
        .map((m) => {
              'id': m.id,
              'name': m.name,
              'type': m.type.name,
              'is_active': m.isActive,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }
}
