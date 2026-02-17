import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/reservation_model.dart';
import 'base_company_scoped_repository.dart';

class ReservationRepository
    extends BaseCompanyScopedRepository<$ReservationsTable, Reservation, ReservationModel> {
  ReservationRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$ReservationsTable, Reservation> get table => db.reservations;

  @override
  String get entityName => 'reservation';

  @override
  String get supabaseTableName => 'reservations';

  @override
  ReservationModel fromEntity(Reservation e) => reservationFromEntity(e);

  @override
  Insertable<Reservation> toCompanion(ReservationModel m) => reservationToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(ReservationModel m) => reservationToSupabaseJson(m);

  @override
  Expression<bool> whereId($ReservationsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($ReservationsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($ReservationsTable t) => t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($ReservationsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.desc(t.reservationDate)];

  @override
  Insertable<Reservation> toUpdateCompanion(ReservationModel m) => ReservationsCompanion(
        customerId: Value(m.customerId),
        customerName: Value(m.customerName),
        customerPhone: Value(m.customerPhone),
        reservationDate: Value(m.reservationDate),
        partySize: Value(m.partySize),
        tableId: Value(m.tableId),
        notes: Value(m.notes),
        status: Value(m.status),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<Reservation> toDeleteCompanion(DateTime now) => ReservationsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Stream<List<ReservationModel>> watchByDateRange(
    String companyId,
    DateTime from,
    DateTime to,
  ) {
    return (db.select(db.reservations)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.deletedAt.isNull() &
              t.reservationDate.isBiggerOrEqualValue(from) &
              t.reservationDate.isSmallerOrEqualValue(to))
          ..orderBy([(t) => OrderingTerm.asc(t.reservationDate)]))
        .watch()
        .map((rows) => rows.map(reservationFromEntity).toList());
  }
}
