import 'package:drift/drift.dart';

import '../../data/enums/reservation_status.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_reservations_company_updated', columns: {#companyId, #updatedAt})
class Reservations extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get customerName => text()();
  TextColumn get customerPhone => text().nullable()();
  DateTimeColumn get reservationDate => dateTime()();
  IntColumn get partySize => integer().withDefault(const Constant(2))();
  IntColumn get durationMinutes => integer().withDefault(const Constant(90))();
  TextColumn get tableId => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => textEnum<ReservationStatus>()();

  @override
  Set<Column> get primaryKey => {id};
}
