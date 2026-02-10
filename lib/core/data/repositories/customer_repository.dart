import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/customer_model.dart';
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
}
