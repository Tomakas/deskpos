import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/product_recipe_model.dart';
import 'base_company_scoped_repository.dart';

class ProductRecipeRepository
    extends BaseCompanyScopedRepository<$ProductRecipesTable, ProductRecipe, ProductRecipeModel> {
  ProductRecipeRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$ProductRecipesTable, ProductRecipe> get table => db.productRecipes;

  @override
  String get entityName => 'product_recipe';

  @override
  String get supabaseTableName => 'product_recipes';

  @override
  ProductRecipeModel fromEntity(ProductRecipe e) => productRecipeFromEntity(e);

  @override
  Insertable<ProductRecipe> toCompanion(ProductRecipeModel m) => productRecipeToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(ProductRecipeModel m) => productRecipeToSupabaseJson(m);

  @override
  Expression<bool> whereId($ProductRecipesTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($ProductRecipesTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($ProductRecipesTable t) => t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($ProductRecipesTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.parentProductId)];

  @override
  Insertable<ProductRecipe> toUpdateCompanion(ProductRecipeModel m) => ProductRecipesCompanion(
        parentProductId: Value(m.parentProductId),
        componentProductId: Value(m.componentProductId),
        quantityRequired: Value(m.quantityRequired),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<ProductRecipe> toDeleteCompanion(DateTime now) => ProductRecipesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );
}
