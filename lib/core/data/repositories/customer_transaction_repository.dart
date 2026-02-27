import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/customer_transaction_model.dart';
import 'base_company_scoped_repository.dart';

class CustomerTransactionRepository extends BaseCompanyScopedRepository<
    $CustomerTransactionsTable, CustomerTransaction, CustomerTransactionModel> {
  CustomerTransactionRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$CustomerTransactionsTable, CustomerTransaction> get table =>
      db.customerTransactions;

  @override
  String get entityName => 'customer_transaction';

  @override
  String get supabaseTableName => 'customer_transactions';

  @override
  CustomerTransactionModel fromEntity(CustomerTransaction e) =>
      customerTransactionFromEntity(e);

  @override
  Insertable<CustomerTransaction> toCompanion(CustomerTransactionModel m) =>
      customerTransactionToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(CustomerTransactionModel m) =>
      customerTransactionToSupabaseJson(m);

  @override
  Expression<bool> whereId($CustomerTransactionsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($CustomerTransactionsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($CustomerTransactionsTable t) =>
      t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($CustomerTransactionsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.desc(t.createdAt)];

  @override
  Insertable<CustomerTransaction> toUpdateCompanion(CustomerTransactionModel m) =>
      CustomerTransactionsCompanion(
        pointsChange: Value(m.pointsChange),
        creditChange: Value(m.creditChange),
        orderId: Value(m.orderId),
        reference: Value(m.reference),
        note: Value(m.note),
        processedByUserId: Value(m.processedByUserId),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<CustomerTransaction> toDeleteCompanion(DateTime now) =>
      CustomerTransactionsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Stream<List<CustomerTransactionModel>> watchByCustomer(String customerId) {
    return (db.select(db.customerTransactions)
          ..where((t) => t.customerId.equals(customerId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(customerTransactionFromEntity).toList());
  }
}
