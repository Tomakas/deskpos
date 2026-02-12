import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_payments_company_updated', columns: {#companyId, #updatedAt})
class Payments extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get billId => text()();
  TextColumn get registerId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get paymentMethodId => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get paidAt => dateTime()();
  TextColumn get currencyId => text()();
  IntColumn get tipIncludedAmount => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get transactionId => text().nullable()();
  TextColumn get paymentProvider => text().nullable()();
  TextColumn get cardLast4 => text().nullable()();
  TextColumn get authorizationCode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
