import 'package:drift/drift.dart';

/// Local-only table — NOT synced to Supabase.
/// Stores the one-time binding between this physical device and a register.
class DeviceRegistrations extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get registerId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
