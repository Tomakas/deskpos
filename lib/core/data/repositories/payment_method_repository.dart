import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/payment_method_model.dart';
import 'base_company_scoped_repository.dart';

class PaymentMethodRepository
    extends BaseCompanyScopedRepository<$PaymentMethodsTable, PaymentMethod, PaymentMethodModel> {
  PaymentMethodRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$PaymentMethodsTable, PaymentMethod> get table => db.paymentMethods;

  @override
  String get entityName => 'payment method';

  @override
  String get supabaseTableName => 'payment_methods';

  @override
  PaymentMethodModel fromEntity(PaymentMethod e) => paymentMethodFromEntity(e);

  @override
  Insertable<PaymentMethod> toCompanion(PaymentMethodModel m) =>
      paymentMethodToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(PaymentMethodModel m) =>
      paymentMethodToSupabaseJson(m);

  @override
  Expression<bool> whereId($PaymentMethodsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($PaymentMethodsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($PaymentMethodsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.name)];

  @override
  Insertable<PaymentMethod> toUpdateCompanion(PaymentMethodModel m) =>
      PaymentMethodsCompanion(
        name: Value(m.name),
        type: Value(m.type),
        isActive: Value(m.isActive),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<PaymentMethod> toDeleteCompanion(DateTime now) =>
      PaymentMethodsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );
}
