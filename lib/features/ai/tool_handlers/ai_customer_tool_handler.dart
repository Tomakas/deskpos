import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/data/models/customer_model.dart';
import '../../../core/data/repositories/customer_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

const _uuid = Uuid();

/// Handles customer-domain AI tool calls.
class AiCustomerToolHandler {
  AiCustomerToolHandler({required CustomerRepository customerRepo})
      : _customerRepo = customerRepo;

  final CustomerRepository _customerRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId, {
    required String userId,
  }) async {
    try {
      return switch (toolName) {
        'list_customers' => _listCustomers(companyId),
        'search_customers' => _searchCustomers(args, companyId),
        'get_customer' => _getCustomer(args),
        'create_customer' => _createCustomer(args, companyId),
        'update_customer' => _updateCustomer(args),
        'delete_customer' => _deleteCustomer(args),
        'adjust_customer_points' =>
          _adjustCustomerPoints(args, userId),
        'adjust_customer_credit' =>
          _adjustCustomerCredit(args, userId),
        _ => AiCommandError('Unknown customer tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Customer tool handler error', tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  Future<AiCommandResult> _listCustomers(String companyId) async {
    final customers = await _customerRepo.watchAll(companyId).first;
    final json = customers
        .take(1000)
        .map((c) => {
              'id': c.id,
              'first_name': c.firstName,
              'last_name': c.lastName,
              'email': c.email,
              'phone': c.phone,
              'points': c.points,
              'credit': c.credit,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _searchCustomers(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final query = args['query'] as String;
    final customers = await _customerRepo.search(companyId, query).first;
    final json = customers
        .take(1000)
        .map((c) => {
              'id': c.id,
              'first_name': c.firstName,
              'last_name': c.lastName,
              'email': c.email,
              'phone': c.phone,
              'points': c.points,
              'credit': c.credit,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _getCustomer(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final customer = await _customerRepo.getById(id);
    if (customer == null) return const AiCommandError('Customer not found');
    return AiCommandSuccess(jsonEncode({
      'id': customer.id,
      'first_name': customer.firstName,
      'last_name': customer.lastName,
      'email': customer.email,
      'phone': customer.phone,
      'address': customer.address,
      'points': customer.points,
      'credit': customer.credit,
      'total_spent': customer.totalSpent,
      'last_visit_date': customer.lastVisitDate?.toIso8601String(),
      'birthdate': customer.birthdate?.toIso8601String(),
    }));
  }

  Future<AiCommandResult> _createCustomer(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final now = DateTime.now();
    final model = CustomerModel(
      id: _uuid.v7(),
      companyId: companyId,
      firstName: args['first_name'] as String,
      lastName: args['last_name'] as String,
      email: args['email'] as String?,
      phone: args['phone'] as String?,
      address: args['address'] as String?,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _customerRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Customer "${value.firstName} ${value.lastName}" created',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateCustomer(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final existing = await _customerRepo.getById(id);
    if (existing == null) return const AiCommandError('Customer not found');

    final updated = existing.copyWith(
      firstName: args['first_name'] as String? ?? existing.firstName,
      lastName: args['last_name'] as String? ?? existing.lastName,
      email: args.containsKey('email')
          ? args['email'] as String?
          : existing.email,
      phone: args.containsKey('phone')
          ? args['phone'] as String?
          : existing.phone,
      address: args.containsKey('address')
          ? args['address'] as String?
          : existing.address,
      updatedAt: DateTime.now(),
    );
    final result = await _customerRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Customer "${value.firstName} ${value.lastName}" updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteCustomer(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final result = await _customerRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess('Customer deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _adjustCustomerPoints(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final customerId = args['customer_id'] as String;
    final delta = (args['delta'] as num).toInt();
    final note = args['note'] as String?;

    final result = await _customerRepo.adjustPoints(
      customerId: customerId,
      delta: delta,
      processedByUserId: userId,
      reference: 'ai_adjustment',
      note: note,
    );
    return switch (result) {
      Success() => AiCommandSuccess(
          'Customer points adjusted by $delta',
          entityId: customerId,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _adjustCustomerCredit(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final customerId = args['customer_id'] as String;
    final delta = (args['delta'] as num).toInt();
    final note = args['note'] as String?;

    final result = await _customerRepo.adjustCredit(
      customerId: customerId,
      delta: delta,
      processedByUserId: userId,
      reference: 'ai_adjustment',
      note: note,
    );
    return switch (result) {
      Success() => AiCommandSuccess(
          'Customer credit adjusted by $delta',
          entityId: customerId,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }
}
