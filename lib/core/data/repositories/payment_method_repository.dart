import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/payment_method_model.dart';
import '../result.dart';

class PaymentMethodRepository {
  PaymentMethodRepository(this._db);
  final AppDatabase _db;

  Future<Result<PaymentMethodModel>> create(PaymentMethodModel model) async {
    try {
      await _db.into(_db.paymentMethods).insert(paymentMethodToCompanion(model));
      final entity = await (_db.select(_db.paymentMethods)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(paymentMethodFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to create payment method', error: e, stackTrace: s);
      return Failure('Failed to create payment method: $e');
    }
  }

  Future<Result<PaymentMethodModel>> update(PaymentMethodModel model) async {
    try {
      await (_db.update(_db.paymentMethods)..where((t) => t.id.equals(model.id))).write(
        PaymentMethodsCompanion(
          name: Value(model.name),
          type: Value(model.type),
          isActive: Value(model.isActive),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final entity = await (_db.select(_db.paymentMethods)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(paymentMethodFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to update payment method', error: e, stackTrace: s);
      return Failure('Failed to update payment method: $e');
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await (_db.update(_db.paymentMethods)..where((t) => t.id.equals(id))).write(
        PaymentMethodsCompanion(
            deletedAt: Value(DateTime.now()), updatedAt: Value(DateTime.now())),
      );
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to delete payment method', error: e, stackTrace: s);
      return Failure('Failed to delete payment method: $e');
    }
  }

  Stream<List<PaymentMethodModel>> watchAll(String companyId) {
    return (_db.select(_db.paymentMethods)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(paymentMethodFromEntity).toList());
  }
}
