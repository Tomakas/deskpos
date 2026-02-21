import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/order_item_modifier_model.dart';
import 'base_company_scoped_repository.dart';

class OrderItemModifierRepository
    extends BaseCompanyScopedRepository<$OrderItemModifiersTable, OrderItemModifier, OrderItemModifierModel> {
  OrderItemModifierRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$OrderItemModifiersTable, OrderItemModifier> get table => db.orderItemModifiers;

  @override
  String get entityName => 'order_item_modifier';

  @override
  String get supabaseTableName => 'order_item_modifiers';

  @override
  OrderItemModifierModel fromEntity(OrderItemModifier e) => orderItemModifierFromEntity(e);

  @override
  Insertable<OrderItemModifier> toCompanion(OrderItemModifierModel m) => orderItemModifierToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(OrderItemModifierModel m) => orderItemModifierToSupabaseJson(m);

  @override
  Expression<bool> whereId($OrderItemModifiersTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($OrderItemModifiersTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($OrderItemModifiersTable t) => t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($OrderItemModifiersTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.createdAt)];

  @override
  Insertable<OrderItemModifier> toUpdateCompanion(OrderItemModifierModel m) =>
      OrderItemModifiersCompanion(
        quantity: Value(m.quantity),
        unitPrice: Value(m.unitPrice),
        taxRate: Value(m.taxRate),
        taxAmount: Value(m.taxAmount),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<OrderItemModifier> toDeleteCompanion(DateTime now) => OrderItemModifiersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Future<List<OrderItemModifierModel>> getByOrderItem(String orderItemId) async {
    final rows = await (db.select(db.orderItemModifiers)
          ..where((t) => t.orderItemId.equals(orderItemId) & t.deletedAt.isNull()))
        .get();
    return rows.map(fromEntity).toList();
  }

  Stream<List<OrderItemModifierModel>> watchByOrderItem(String orderItemId) {
    return (db.select(db.orderItemModifiers)
          ..where((t) => t.orderItemId.equals(orderItemId) & t.deletedAt.isNull()))
        .watch()
        .map((rows) => rows.map(fromEntity).toList());
  }

  Future<void> createBatch(List<OrderItemModifierModel> modifiers) async {
    await db.transaction(() async {
      for (final m in modifiers) {
        await db.into(db.orderItemModifiers).insert(toCompanion(m));
        await _enqueueSync(m);
      }
    });
  }

  Future<void> _enqueueSync(OrderItemModifierModel m) async {
    if (syncQueueRepo == null) return;
    await syncQueueRepo!.enqueue(
      companyId: m.companyId,
      entityType: supabaseTableName,
      entityId: m.id,
      operation: 'insert',
      payload: jsonEncode(toSupabaseJson(m)),
    );
  }
}
