import 'package:drift/drift.dart';

import '../../data/enums/table_shape.dart';
import 'sync_columns_mixin.dart';

@DataClassName('MapElementEntity')
@TableIndex(name: 'idx_map_elements_company_updated', columns: {#companyId, #updatedAt})
class MapElements extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get sectionId => text().nullable()();
  IntColumn get gridRow => integer().withDefault(const Constant(0))();
  IntColumn get gridCol => integer().withDefault(const Constant(0))();
  IntColumn get gridWidth => integer().withDefault(const Constant(2))();
  IntColumn get gridHeight => integer().withDefault(const Constant(2))();
  TextColumn get label => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get fontSize => integer().nullable()();
  IntColumn get fillStyle => integer().withDefault(const Constant(1))();
  IntColumn get borderStyle => integer().withDefault(const Constant(1))();
  TextColumn get shape => textEnum<TableShape>().withDefault(Constant(TableShape.rectangle.name))();

  @override
  Set<Column> get primaryKey => {id};
}
