import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/category_model.dart';
import 'base_company_scoped_repository.dart';

class CategoryRepository
    extends BaseCompanyScopedRepository<$CategoriesTable, Category, CategoryModel> {
  CategoryRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$CategoriesTable, Category> get table => db.categories;

  @override
  String get entityName => 'category';

  @override
  String get supabaseTableName => 'categories';

  @override
  CategoryModel fromEntity(Category e) => categoryFromEntity(e);

  @override
  Insertable<Category> toCompanion(CategoryModel m) => categoryToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(CategoryModel m) => categoryToSupabaseJson(m);

  @override
  Expression<bool> whereId($CategoriesTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($CategoriesTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($CategoriesTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.name)];

  @override
  Insertable<Category> toUpdateCompanion(CategoryModel m) => CategoriesCompanion(
        name: Value(m.name),
        isActive: Value(m.isActive),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<Category> toDeleteCompanion(DateTime now) => CategoriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );
}
