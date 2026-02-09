import 'package:drift/drift.dart';

import '../../data/enums/tax_calc_type.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_tax_rates_company_updated', columns: {#companyId, #updatedAt})
class TaxRates extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get label => text()();
  TextColumn get type => textEnum<TaxCalcType>()();
  IntColumn get rate => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
