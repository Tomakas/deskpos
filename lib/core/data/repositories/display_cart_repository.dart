import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../models/display_cart_item_model.dart';

class DisplayCartItemInput {
  const DisplayCartItemInput({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    this.notes,
    required this.sortOrder,
  });

  final String itemName;
  final double quantity;
  final int unitPrice;
  final String? notes;
  final int sortOrder;
}

/// Local-only repository — display_cart_items are NOT synced.
class DisplayCartRepository {
  DisplayCartRepository(this._db);
  final AppDatabase _db;

  Future<void> replaceAll(String registerId, List<DisplayCartItemInput> items) {
    return _db.transaction(() async {
      await (_db.delete(_db.displayCartItems)
            ..where((t) => t.registerId.equals(registerId)))
          .go();
      for (final item in items) {
        await _db.into(_db.displayCartItems).insert(
          DisplayCartItemsCompanion.insert(
            registerId: registerId,
            itemName: item.itemName,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            notes: Value(item.notes),
            sortOrder: item.sortOrder,
          ),
        );
      }
    });
  }

  Future<void> clear(String registerId) {
    return (_db.delete(_db.displayCartItems)
          ..where((t) => t.registerId.equals(registerId)))
        .go();
  }

  Stream<List<DisplayCartItemModel>> watchByRegister(String registerId) {
    final query = _db.select(_db.displayCartItems)
      ..where((t) => t.registerId.equals(registerId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch().map(
      (rows) => rows.map(displayCartItemFromEntity).toList(),
    );
  }
}
