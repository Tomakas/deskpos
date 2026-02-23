import 'package:drift/drift.dart';

import '../../data/enums/discount_type.dart';
import '../../data/enums/voucher_discount_scope.dart';
import '../../data/enums/voucher_status.dart';
import '../../data/enums/voucher_type.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_vouchers_company_updated', columns: {#companyId, #updatedAt})
@TableIndex(name: 'idx_vouchers_code', columns: {#code})
class Vouchers extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get code => text()();
  TextColumn get type => textEnum<VoucherType>()();
  TextColumn get status => textEnum<VoucherStatus>()();
  IntColumn get value => integer()();
  TextColumn get discountType => textEnum<DiscountType>().nullable()();
  TextColumn get discountScope => textEnum<VoucherDiscountScope>().nullable()();
  TextColumn get itemId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get minOrderValue => integer().nullable()();
  IntColumn get maxUses => integer().withDefault(const Constant(1))();
  IntColumn get usedCount => integer().withDefault(const Constant(0))();
  TextColumn get customerId => text().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get redeemedAt => dateTime().nullable()();
  TextColumn get redeemedOnBillId => text().nullable()();
  TextColumn get sourceBillId => text().nullable()();
  TextColumn get createdByUserId => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
