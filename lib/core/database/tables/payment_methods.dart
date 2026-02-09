import 'package:drift/drift.dart';

import '../../data/enums/payment_type.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_payment_methods_company_updated', columns: {#companyId, #updatedAt})
class PaymentMethods extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<PaymentType>()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
