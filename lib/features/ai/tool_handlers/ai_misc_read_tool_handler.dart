import 'dart:convert';

import '../../../core/data/repositories/company_currency_repository.dart';
import '../../../core/data/repositories/customer_transaction_repository.dart';
import '../../../core/data/repositories/register_repository.dart';
import '../../../core/data/repositories/role_repository.dart';
import '../../../core/data/repositories/stock_document_repository.dart';
import '../../../core/data/repositories/stock_movement_repository.dart';
import '../../../core/data/repositories/warehouse_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

/// Handles miscellaneous read-only AI tool calls across several domains.
class AiMiscReadToolHandler {
  AiMiscReadToolHandler({
    required CustomerTransactionRepository customerTransactionRepo,
    required StockDocumentRepository stockDocumentRepo,
    required StockMovementRepository stockMovementRepo,
    required RoleRepository roleRepo,
    required RegisterRepository registerRepo,
    required CompanyCurrencyRepository companyCurrencyRepo,
    required WarehouseRepository warehouseRepo,
  })  : _customerTransactionRepo = customerTransactionRepo,
        _stockDocumentRepo = stockDocumentRepo,
        _stockMovementRepo = stockMovementRepo,
        _roleRepo = roleRepo,
        _registerRepo = registerRepo,
        _companyCurrencyRepo = companyCurrencyRepo,
        _warehouseRepo = warehouseRepo;

  final CustomerTransactionRepository _customerTransactionRepo;
  final StockDocumentRepository _stockDocumentRepo;
  final StockMovementRepository _stockMovementRepo;
  final RoleRepository _roleRepo;
  final RegisterRepository _registerRepo;
  final CompanyCurrencyRepository _companyCurrencyRepo;
  final WarehouseRepository _warehouseRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        'list_customer_transactions' =>
          _listCustomerTransactions(args, companyId),
        'list_stock_documents' =>
          _listStockDocuments(args, companyId),
        'get_stock_document' => _getStockDocument(args, companyId),
        'list_stock_movements' =>
          _listStockMovements(args, companyId),
        'list_roles' => _listRoles(),
        'list_registers' => _listRegisters(companyId),
        'list_currencies' => _listCurrencies(companyId),
        'list_warehouses' => _listWarehouses(companyId),
        _ => AiCommandError('Unknown misc read tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Misc read tool handler error',
          tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  Future<AiCommandResult> _listCustomerTransactions(
      Map<String, dynamic> args, String companyId) async {
    final customerId = args['customer_id'] as String;
    final allTransactions =
        await _customerTransactionRepo.watchByCustomer(customerId).first;
    final transactions =
        allTransactions.where((t) => t.companyId == companyId).toList();
    final json = transactions
        .take(1000)
        .map((t) => {
              'id': t.id,
              'customer_id': t.customerId,
              'points_change': t.pointsChange,
              'credit_change': t.creditChange,
              'order_id': t.orderId,
              'reference': t.reference,
              'note': t.note,
              'processed_by_user_id': t.processedByUserId,
              'created_at': t.createdAt.toIso8601String(),
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _listStockDocuments(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    // Get default warehouse for document listing
    final warehouse = await _warehouseRepo.getDefault(companyId);
    final documents =
        await _stockDocumentRepo.watchByWarehouse(companyId, warehouse.id).first;

    final days = (args['days'] as num?)?.toInt();
    var filtered = documents;
    if (days != null) {
      final since = DateTime.now().subtract(Duration(days: days));
      filtered = filtered
          .where((d) => d.documentDate.isAfter(since))
          .toList();
    }

    final json = filtered
        .take(1000)
        .map((d) => {
              'id': d.id,
              'document_number': d.documentNumber,
              'type': d.type.name,
              'warehouse_id': d.warehouseId,
              'supplier_id': d.supplierId,
              'user_id': d.userId,
              'note': d.note,
              'total_amount': d.totalAmount,
              'document_date': d.documentDate.toIso8601String(),
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _getStockDocument(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final document = await _stockDocumentRepo.watchById(id).first;
    if (document == null || document.companyId != companyId) {
      return const AiCommandError('Stock document not found');
    }

    final movements =
        await _stockMovementRepo.watchByDocumentWithItems(id).first;

    return AiCommandSuccess(jsonEncode({
      'id': document.id,
      'document_number': document.documentNumber,
      'type': document.type.name,
      'warehouse_id': document.warehouseId,
      'supplier_id': document.supplierId,
      'user_id': document.userId,
      'note': document.note,
      'total_amount': document.totalAmount,
      'document_date': document.documentDate.toIso8601String(),
      'movements': movements
          .map((m) => {
                'id': m.movement.id,
                'item_id': m.movement.itemId,
                'item_name': m.itemName,
                'quantity': m.movement.quantity,
                'direction': m.movement.direction.name,
                'purchase_price': m.movement.purchasePrice,
                'unit': m.unit.name,
              })
          .toList(),
    }));
  }

  Future<AiCommandResult> _listStockMovements(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final itemId = args['item_id'] as String?;
    final movements =
        await _stockMovementRepo.watchByCompany(companyId, itemId: itemId).first;

    final days = (args['days'] as num?)?.toInt();
    var filtered = movements;
    if (days != null) {
      final since = DateTime.now().subtract(Duration(days: days));
      filtered = filtered
          .where((m) => m.movement.createdAt.isAfter(since))
          .toList();
    }

    final json = filtered
        .take(1000)
        .map((m) => {
              'id': m.movement.id,
              'item_id': m.movement.itemId,
              'item_name': m.itemName,
              'quantity': m.movement.quantity,
              'direction': m.movement.direction.name,
              'purchase_price': m.movement.purchasePrice,
              'document_type': m.documentType?.name,
              'document_number': m.documentNumber,
              'bill_number': m.billNumber,
              'created_at': m.movement.createdAt.toIso8601String(),
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _listRoles() async {
    final result = await _roleRepo.getAll();
    return switch (result) {
      Success(:final value) => AiCommandSuccess(jsonEncode(
          value
              .take(1000)
              .map((r) => {
                    'id': r.id,
                    'name': r.name.name,
                  })
              .toList(),
        )),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _listRegisters(String companyId) async {
    final registers = await _registerRepo.getAll(companyId);
    final json = registers
        .take(1000)
        .map((r) => {
              'id': r.id,
              'name': r.name,
              'code': r.code,
              'register_number': r.registerNumber,
              'type': r.type.name,
              'is_main': r.isMain,
              'is_active': r.isActive,
              'sell_mode': r.sellMode.name,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _listCurrencies(String companyId) async {
    final currencies = await _companyCurrencyRepo.getActive(companyId);
    final json = currencies
        .take(1000)
        .map((c) => {
              'id': c.id,
              'currency_id': c.currencyId,
              'exchange_rate': c.exchangeRate,
              'is_active': c.isActive,
              'sort_order': c.sortOrder,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _listWarehouses(String companyId) async {
    final warehouses = await _warehouseRepo.watchAll(companyId).first;
    final json = warehouses
        .take(1000)
        .map((w) => {
              'id': w.id,
              'name': w.name,
              'is_default': w.isDefault,
              'is_active': w.isActive,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }
}
