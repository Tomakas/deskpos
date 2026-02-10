import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/catalog_categories_tab.dart';
import '../widgets/catalog_products_tab.dart';
import '../widgets/customers_tab.dart';
import '../widgets/manufacturers_tab.dart';
import '../widgets/recipes_tab.dart';
import '../widgets/suppliers_tab.dart';

class ScreenCatalog extends ConsumerWidget {
  const ScreenCatalog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.catalogTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.catalogTabProducts),
              Tab(text: l.catalogTabCategories),
              Tab(text: l.catalogTabSuppliers),
              Tab(text: l.catalogTabManufacturers),
              Tab(text: l.catalogTabRecipes),
              Tab(text: l.catalogTabCustomers),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CatalogProductsTab(),
            CatalogCategoriesTab(),
            SuppliersTab(),
            ManufacturersTab(),
            RecipesTab(),
            CustomersTab(),
          ],
        ),
      ),
    );
  }
}
