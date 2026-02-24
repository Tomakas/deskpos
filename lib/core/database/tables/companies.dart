import 'package:drift/drift.dart';

import '../../data/enums/company_status.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_companies_updated_at', columns: {#updatedAt})
class Companies extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get status => textEnum<CompanyStatus>()();
  TextColumn get businessId => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get vatNumber => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get postalCode => text().nullable()();
  TextColumn get timezone => text().nullable()();
  TextColumn get businessType => text().nullable()();
  TextColumn get defaultCurrencyId => text()();
  TextColumn get authUserId => text()();
  BoolColumn get isDemo => boolean().withDefault(const Constant(false))();
  DateTimeColumn get demoExpiresAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
