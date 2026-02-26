import 'package:drift/drift.dart';

import '../../data/enums/negative_stock_policy.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_company_settings_company_updated', columns: {#companyId, #updatedAt})
class CompanySettings extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  BoolColumn get requirePinOnSwitch => boolean().withDefault(const Constant(true))();
  IntColumn get autoLockTimeoutMinutes => integer().nullable()();
  IntColumn get loyaltyEarnRate => integer().withDefault(const Constant(0))();
  IntColumn get loyaltyPointValue => integer().withDefault(const Constant(0))();
  TextColumn get locale => text().withDefault(const Constant('cs'))();
  TextColumn get negativeStockPolicy =>
      textEnum<NegativeStockPolicy>().withDefault(Constant(NegativeStockPolicy.allow.name))();

  // Discount limits (basis points: 2000 = 20.00%)
  IntColumn get maxItemDiscountPercent => integer().withDefault(const Constant(2000))();
  IntColumn get maxBillDiscountPercent => integer().withDefault(const Constant(2000))();

  // TODO: Add UI for editing these thresholds in company settings screen.
  IntColumn get billAgeWarningMinutes => integer().withDefault(const Constant(15))();
  IntColumn get billAgeDangerMinutes => integer().withDefault(const Constant(30))();
  IntColumn get billAgeCriticalMinutes => integer().withDefault(const Constant(45))();

  @override
  Set<Column> get primaryKey => {id};
}
