import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/customer_model.dart';
import '../models/customer_transaction_model.dart';
import '../result.dart';
import 'base_company_scoped_repository.dart';

class CustomerRepository
    extends BaseCompanyScopedRepository<$CustomersTable, Customer, CustomerModel> {
  CustomerRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$CustomersTable, Customer> get table => db.customers;

  @override
  String get entityName => 'customer';

  @override
  String get supabaseTableName => 'customers';

  @override
  CustomerModel fromEntity(Customer e) => customerFromEntity(e);

  @override
  Insertable<Customer> toCompanion(CustomerModel m) => customerToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(CustomerModel m) => customerToSupabaseJson(m);

  @override
  Expression<bool> whereId($CustomersTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($CustomersTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($CustomersTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.lastName)];

  @override
  Insertable<Customer> toUpdateCompanion(CustomerModel m) => CustomersCompanion(
        firstName: Value(m.firstName),
        lastName: Value(m.lastName),
        email: Value(m.email),
        phone: Value(m.phone),
        address: Value(m.address),
        points: Value(m.points),
        credit: Value(m.credit),
        totalSpent: Value(m.totalSpent),
        lastVisitDate: Value(m.lastVisitDate),
        birthdate: Value(m.birthdate),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<Customer> toDeleteCompanion(DateTime now) => CustomersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Stream<List<CustomerModel>> search(String companyId, String query) {
    final pattern = '%$query%';
    return (db.select(db.customers)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.deletedAt.isNull() &
              (t.firstName.like(pattern) |
                  t.lastName.like(pattern) |
                  t.email.like(pattern) |
                  t.phone.like(pattern)))
          ..orderBy([(t) => OrderingTerm.asc(t.lastName)]))
        .watch()
        .map((rows) => rows.map(customerFromEntity).toList());
  }

  Future<Result<void>> adjustPoints({
    required String customerId,
    required int delta,
    required String processedByUserId,
    String? orderId,
  }) async {
    try {
      final entity = await (db.select(db.customers)
            ..where((t) => t.id.equals(customerId)))
          .getSingle();
      final customer = customerFromEntity(entity);
      final newPoints = customer.points + delta;

      final now = DateTime.now();
      final txId = const Uuid().v7();

      await db.transaction(() async {
        await (db.update(db.customers)..where((t) => t.id.equals(customerId))).write(
          CustomersCompanion(
            points: Value(newPoints),
            updatedAt: Value(now),
          ),
        );

        await db.into(db.customerTransactions).insert(
          customerTransactionToCompanion(CustomerTransactionModel(
            id: txId,
            companyId: customer.companyId,
            customerId: customerId,
            pointsChange: delta,
            creditChange: 0,
            orderId: orderId,
            processedByUserId: processedByUserId,
            createdAt: now,
            updatedAt: now,
          )),
        );
      });

      // Enqueue outside transaction
      final updatedEntity = await (db.select(db.customers)
            ..where((t) => t.id.equals(customerId)))
          .getSingle();
      final updatedCustomer = customerFromEntity(updatedEntity);
      if (syncQueueRepo != null) {
        await syncQueueRepo!.enqueue(
          companyId: updatedCustomer.companyId,
          entityType: 'customers',
          entityId: updatedCustomer.id,
          operation: 'update',
          payload: jsonEncode(customerToSupabaseJson(updatedCustomer)),
        );
      }

      final txEntity = await (db.select(db.customerTransactions)
            ..where((t) => t.id.equals(txId)))
          .getSingle();
      final tx = customerTransactionFromEntity(txEntity);
      if (syncQueueRepo != null) {
        await syncQueueRepo!.enqueue(
          companyId: tx.companyId,
          entityType: 'customer_transactions',
          entityId: tx.id,
          operation: 'insert',
          payload: jsonEncode(customerTransactionToSupabaseJson(tx)),
        );
      }

      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to adjust points', error: e, stackTrace: s);
      return Failure('Failed to adjust points: $e');
    }
  }

  Future<Result<void>> adjustCredit({
    required String customerId,
    required int delta,
    required String processedByUserId,
    String? orderId,
  }) async {
    try {
      final entity = await (db.select(db.customers)
            ..where((t) => t.id.equals(customerId)))
          .getSingle();
      final customer = customerFromEntity(entity);
      final newCredit = customer.credit + delta;
      if (newCredit < 0) {
        return const Failure('Credit cannot go below 0');
      }

      final now = DateTime.now();
      final txId = const Uuid().v7();

      await db.transaction(() async {
        await (db.update(db.customers)..where((t) => t.id.equals(customerId))).write(
          CustomersCompanion(
            credit: Value(newCredit),
            updatedAt: Value(now),
          ),
        );

        await db.into(db.customerTransactions).insert(
          customerTransactionToCompanion(CustomerTransactionModel(
            id: txId,
            companyId: customer.companyId,
            customerId: customerId,
            pointsChange: 0,
            creditChange: delta,
            orderId: orderId,
            processedByUserId: processedByUserId,
            createdAt: now,
            updatedAt: now,
          )),
        );
      });

      // Enqueue outside transaction
      final updatedEntity = await (db.select(db.customers)
            ..where((t) => t.id.equals(customerId)))
          .getSingle();
      final updatedCustomer = customerFromEntity(updatedEntity);
      if (syncQueueRepo != null) {
        await syncQueueRepo!.enqueue(
          companyId: updatedCustomer.companyId,
          entityType: 'customers',
          entityId: updatedCustomer.id,
          operation: 'update',
          payload: jsonEncode(customerToSupabaseJson(updatedCustomer)),
        );
      }

      final txEntity = await (db.select(db.customerTransactions)
            ..where((t) => t.id.equals(txId)))
          .getSingle();
      final tx = customerTransactionFromEntity(txEntity);
      if (syncQueueRepo != null) {
        await syncQueueRepo!.enqueue(
          companyId: tx.companyId,
          entityType: 'customer_transactions',
          entityId: tx.id,
          operation: 'insert',
          payload: jsonEncode(customerTransactionToSupabaseJson(tx)),
        );
      }

      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to adjust credit', error: e, stackTrace: s);
      return Failure('Failed to adjust credit: $e');
    }
  }

  Future<Result<void>> updateTrackingOnPayment({
    required String customerId,
    required int billTotal,
  }) async {
    try {
      final now = DateTime.now();
      final entity = await (db.select(db.customers)
            ..where((t) => t.id.equals(customerId)))
          .getSingle();
      final customer = customerFromEntity(entity);
      final newTotalSpent = customer.totalSpent + billTotal;

      await (db.update(db.customers)..where((t) => t.id.equals(customerId))).write(
        CustomersCompanion(
          totalSpent: Value(newTotalSpent),
          lastVisitDate: Value(now),
          updatedAt: Value(now),
        ),
      );

      // Enqueue
      final updatedEntity = await (db.select(db.customers)
            ..where((t) => t.id.equals(customerId)))
          .getSingle();
      final updatedCustomer = customerFromEntity(updatedEntity);
      if (syncQueueRepo != null) {
        await syncQueueRepo!.enqueue(
          companyId: updatedCustomer.companyId,
          entityType: 'customers',
          entityId: updatedCustomer.id,
          operation: 'update',
          payload: jsonEncode(customerToSupabaseJson(updatedCustomer)),
        );
      }

      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to update customer tracking', error: e, stackTrace: s);
      return Failure('Failed to update customer tracking: $e');
    }
  }
}
