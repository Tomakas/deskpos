import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  PaymentRepository(this._db);
  final AppDatabase _db;

  Stream<List<PaymentModel>> watchByBill(String billId) {
    return (_db.select(_db.payments)
          ..where((t) => t.billId.equals(billId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.paidAt)]))
        .watch()
        .map((rows) => rows.map(paymentFromEntity).toList());
  }

  Future<List<PaymentModel>> getByBill(String billId) async {
    final entities = await (_db.select(_db.payments)
          ..where((t) => t.billId.equals(billId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.paidAt)]))
        .get();
    return entities.map(paymentFromEntity).toList();
  }
}
