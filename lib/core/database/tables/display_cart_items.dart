import 'package:drift/drift.dart';

/// Local-only table — NOT synced to Supabase.
/// Mirrors cart state for the customer display screen.
class DisplayCartItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get registerId => text()();
  TextColumn get itemName => text()();
  RealColumn get quantity => real()();
  IntColumn get unitPrice => integer()();
  TextColumn get notes => text().nullable()();
  IntColumn get sortOrder => integer()();
}
