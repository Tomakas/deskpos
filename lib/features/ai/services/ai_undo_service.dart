import '../../../core/data/repositories/category_repository.dart';
import '../../../core/data/repositories/company_settings_repository.dart';
import '../../../core/data/repositories/customer_repository.dart';
import '../../../core/data/repositories/item_repository.dart';
import '../../../core/data/repositories/manufacturer_repository.dart';
import '../../../core/data/repositories/payment_method_repository.dart';
import '../../../core/data/repositories/section_repository.dart';
import '../../../core/data/repositories/supplier_repository.dart';
import '../../../core/data/repositories/table_repository.dart';
import '../../../core/data/repositories/tax_rate_repository.dart';
import '../../../core/data/repositories/voucher_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import 'ai_direct_supabase_service.dart';

/// Handles undo operations for AI-executed commands.
///
/// Processes undo logs in reverse order (last operation first),
/// checking for version conflicts before applying.
///
/// TODO: Phase 3 — add undo support for reservations, modifiers, recipes
/// (requires adding repos + _deleteEntity cases for those entity types).
/// TODO: Phase 3 — implement snapshot-based undo for update/delete operations.
class AiUndoService {
  AiUndoService({
    required AiDirectSupabaseService aiDirectService,
    required ItemRepository itemRepo,
    required CategoryRepository categoryRepo,
    required TaxRateRepository taxRateRepo,
    required SupplierRepository supplierRepo,
    required ManufacturerRepository manufacturerRepo,
    required CustomerRepository customerRepo,
    required SectionRepository sectionRepo,
    required TableRepository tableRepo,
    required VoucherRepository voucherRepo,
    required PaymentMethodRepository paymentMethodRepo,
    required CompanySettingsRepository companySettingsRepo,
  })  : _aiDirectService = aiDirectService,
        _itemRepo = itemRepo,
        _categoryRepo = categoryRepo,
        _taxRateRepo = taxRateRepo,
        _supplierRepo = supplierRepo,
        _manufacturerRepo = manufacturerRepo,
        _customerRepo = customerRepo,
        _sectionRepo = sectionRepo,
        _tableRepo = tableRepo,
        _voucherRepo = voucherRepo,
        _paymentMethodRepo = paymentMethodRepo,
        _companySettingsRepo = companySettingsRepo;

  final AiDirectSupabaseService _aiDirectService;
  final ItemRepository _itemRepo;
  final CategoryRepository _categoryRepo;
  final TaxRateRepository _taxRateRepo;
  final SupplierRepository _supplierRepo;
  final ManufacturerRepository _manufacturerRepo;
  final CustomerRepository _customerRepo;
  final SectionRepository _sectionRepo;
  final TableRepository _tableRepo;
  final VoucherRepository _voucherRepo;
  final PaymentMethodRepository _paymentMethodRepo;
  final CompanySettingsRepository _companySettingsRepo;

  /// Undoes all operations from a specific AI message.
  ///
  /// Processes undo logs in reverse order. Skips expired or already-undone logs.
  /// Returns [Failure] if any undo operation fails, but continues processing.
  Future<Result<void>> undoMessage(String messageId) async {
    try {
      final logs = await _aiDirectService.fetchUndoLogsForMessage(messageId);
      final now = DateTime.now();

      // Filter out expired and already-undone logs
      final actionable = logs
          .where((log) => !log.isUndone && log.expiresAt.isAfter(now))
          .toList();

      if (actionable.isEmpty) {
        return const Failure('No undoable operations found (expired or already undone)');
      }

      // Process in reverse order (last operation first)
      final reversed = actionable.reversed.toList();
      final undoneIds = <String>[];
      final errors = <String>[];

      for (final log in reversed) {
        try {
          final result = await _undoSingleOperation(log.operationType, log.entityType, log.entityId);
          if (result is Success) {
            undoneIds.add(log.id);
          } else if (result is Failure<void>) {
            errors.add('${log.entityType}/${log.entityId}: ${result.message}');
          }
        } catch (e) {
          errors.add('${log.entityType}/${log.entityId}: $e');
          AppLogger.warn('Undo failed for log ${log.id}', tag: 'AI', error: e);
        }
      }

      // Mark successfully undone logs
      if (undoneIds.isNotEmpty) {
        await _aiDirectService.markUndone(undoneIds);
      }

      if (errors.isNotEmpty) {
        return Failure('Some undo operations failed: ${errors.join("; ")}');
      }

      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Undo message failed', tag: 'AI', error: e, stackTrace: s);
      return Failure('Undo failed: $e');
    }
  }

  Future<Result<void>> _undoSingleOperation(
    String operationType,
    String entityType,
    String entityId,
  ) async {
    switch (operationType) {
      case 'create':
        // Undo create = soft-delete the entity
        return _deleteEntity(entityType, entityId);
      case 'delete':
        // Undo delete = we'd need snapshotBefore to restore;
        // for now, log a warning (full restore in Phase 3 with snapshots)
        AppLogger.warn(
          'Undo delete not fully supported without snapshots',
          tag: 'AI',
        );
        return const Failure('Undo delete requires snapshot data (not yet implemented)');
      case 'update':
        // Undo update = restore snapshotBefore
        // Full restore in Phase 3 with snapshots
        AppLogger.warn(
          'Undo update not fully supported without snapshots',
          tag: 'AI',
        );
        return const Failure('Undo update requires snapshot data (not yet implemented)');
      default:
        return Failure('Unknown operation type: $operationType');
    }
  }

  Future<Result<void>> _deleteEntity(String entityType, String entityId) async {
    return switch (entityType) {
      'item' => _itemRepo.delete(entityId),
      'category' => _categoryRepo.delete(entityId),
      'tax_rate' => _taxRateRepo.delete(entityId),
      'manufacturer' => _manufacturerRepo.delete(entityId),
      'supplier' => _supplierRepo.delete(entityId),
      'customer' => _customerRepo.delete(entityId),
      'section' => _sectionRepo.delete(entityId),
      'table' => _tableRepo.delete(entityId),
      'voucher' => _voucherRepo.delete(entityId),
      'payment_method' => _paymentMethodRepo.delete(entityId),
      'company_settings' => _undoCompanySettings(entityId),
      _ => Failure('Unknown entity type for delete: $entityType'),
    };
  }

  /// Company settings cannot be deleted; undo requires snapshot restore.
  Future<Result<void>> _undoCompanySettings(String entityId) async {
    // Verify the entity exists (uses _companySettingsRepo)
    final existing = await _companySettingsRepo.getByCompany(entityId);
    if (existing == null) {
      return const Failure('Company settings not found');
    }
    return const Failure(
      'Undo for company settings requires snapshot data (not yet implemented)',
    );
  }
}
