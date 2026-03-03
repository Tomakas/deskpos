import 'dart:convert';

import '../../../core/data/enums/stock_document_type.dart';
import '../../../core/data/repositories/stock_document_repository.dart';
import '../../../core/data/repositories/stock_level_repository.dart';
import '../../../core/data/repositories/warehouse_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

/// Handles stock-domain AI tool calls.
class AiStockToolHandler {
  AiStockToolHandler({
    required StockLevelRepository stockLevelRepo,
    required StockDocumentRepository stockDocumentRepo,
    required WarehouseRepository warehouseRepo,
  })  : _stockLevelRepo = stockLevelRepo,
        _stockDocumentRepo = stockDocumentRepo,
        _warehouseRepo = warehouseRepo;

  final StockLevelRepository _stockLevelRepo;
  final StockDocumentRepository _stockDocumentRepo;
  final WarehouseRepository _warehouseRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId, {
    required String userId,
  }) async {
    try {
      return switch (toolName) {
        'list_stock_levels' => _listStockLevels(companyId),
        'create_stock_document' =>
          _createStockDocument(args, companyId, userId),
        _ => AiCommandError('Unknown stock tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Stock tool handler error',
          tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  Future<AiCommandResult> _listStockLevels(String companyId) async {
    final warehouse = await _warehouseRepo.getDefault(companyId);
    final items =
        await _stockLevelRepo.watchByWarehouse(companyId, warehouse.id).first;
    final json = items
        .take(1000)
        .map((i) => {
              'item_id': i.itemId,
              'name': i.itemName,
              'quantity': i.quantity,
              'min_quantity': i.minQuantity,
              'unit': i.unit.name,
              'purchase_price': i.purchasePrice,
              'category_id': i.categoryId,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _createStockDocument(
    Map<String, dynamic> args,
    String companyId,
    String userId,
  ) async {
    final typeStr = args['type'] as String;
    final type = StockDocumentType.values.byName(typeStr);
    final note = args['note'] as String?;
    final linesRaw = args['lines'] as List;

    final warehouse = await _warehouseRepo.getDefault(companyId);

    if (type == StockDocumentType.inventory) {
      // Inventory: needs current quantities to compute diff
      final stockMap =
          await _stockLevelRepo.watchStockMap(companyId, warehouse.id).first;

      final inventoryLines = linesRaw.map((l) {
        final line = l as Map<String, dynamic>;
        final itemId = line['item_id'] as String;
        final targetQty = (line['quantity'] as num).toDouble();
        final currentQty = stockMap[itemId] ?? 0.0;
        return InventoryLine(
          itemId: itemId,
          currentQuantity: currentQty,
          actualQuantity: targetQty,
          purchasePrice: (line['purchase_price'] as num?)?.toInt(),
        );
      }).toList();

      final result = await _stockDocumentRepo.createInventoryDocument(
        companyId: companyId,
        warehouseId: warehouse.id,
        userId: userId,
        inventoryLines: inventoryLines,
        note: note,
      );

      return switch (result) {
        Success(:final value) => AiCommandSuccess(jsonEncode({
            'document_id': value.id,
            'document_number': value.documentNumber,
            'type': value.type.name,
            'lines_count': inventoryLines.length,
          })),
        Failure(:final message) => AiCommandError(message),
      };
    }

    // receipt, waste, correction
    final lines = linesRaw.map((l) {
      final line = l as Map<String, dynamic>;
      return StockDocumentLine(
        itemId: line['item_id'] as String,
        quantity: (line['quantity'] as num).toDouble(),
        purchasePrice: (line['purchase_price'] as num?)?.toInt(),
      );
    }).toList();

    final result = await _stockDocumentRepo.createDocument(
      companyId: companyId,
      warehouseId: warehouse.id,
      userId: userId,
      type: type,
      note: note,
      lines: lines,
    );

    return switch (result) {
      Success(:final value) => AiCommandSuccess(jsonEncode({
          'document_id': value.id,
          'document_number': value.documentNumber,
          'type': value.type.name,
          'total_amount': value.totalAmount,
          'lines_count': lines.length,
        })),
      Failure(:final message) => AiCommandError(message),
    };
  }
}
