import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/permission_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/catalog_categories_tab.dart';
import '../widgets/catalog_modifiers_tab.dart';
import '../widgets/catalog_products_tab.dart';
import '../widgets/customers_tab.dart';
import '../widgets/manufacturers_tab.dart';
import '../widgets/recipes_tab.dart';
import '../widgets/suppliers_tab.dart';

class ScreenCatalog extends ConsumerStatefulWidget {
  const ScreenCatalog({super.key});

  @override
  ConsumerState<ScreenCatalog> createState() => _ScreenCatalogState();
}

class _ScreenCatalogState extends ConsumerState<ScreenCatalog>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<_CatalogTabDef> _tabs = [];

  @override
  void initState() {
    super.initState();
    ref.listenManual(hasAnyPermissionInGroupProvider('products'), (_, _) => _scheduleRebuild());
    ref.listenManual(hasAnyPermissionInGroupProvider('customers'), (_, _) => _scheduleRebuild());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildTabs();
  }

  void _scheduleRebuild() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _rebuildTabs());
    });
  }

  void _rebuildTabs() {
    final l = context.l10n;
    bool p(String code) => ref.read(hasPermissionProvider(code));

    final tabs = <_CatalogTabDef>[
      if (p('products.view'))
        _CatalogTabDef(l.catalogTabProducts, const CatalogProductsTab()),
      if (p('products.manage_categories'))
        _CatalogTabDef(l.catalogTabCategories, const CatalogCategoriesTab()),
      if (p('products.manage_modifiers'))
        _CatalogTabDef(l.modifierGroups, const CatalogModifiersTab()),
      if (p('products.manage_suppliers'))
        _CatalogTabDef(l.catalogTabSuppliers, const SuppliersTab()),
      if (p('products.manage_manufacturers'))
        _CatalogTabDef(l.catalogTabManufacturers, const ManufacturersTab()),
      if (p('products.manage_recipes'))
        _CatalogTabDef(l.catalogTabRecipes, const RecipesTab()),
      if (p('customers.view'))
        _CatalogTabDef(l.catalogTabCustomers, const CustomersTab()),
    ];

    if (_tabs.length == tabs.length &&
        List.generate(tabs.length, (i) => _tabs[i].label == tabs[i].label)
            .every((match) => match)) {
      return;
    }

    _tabs = tabs;
    _tabController?.dispose();
    _tabController = tabs.isNotEmpty
        ? TabController(length: tabs.length, vsync: this)
        : null;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (_tabs.isEmpty || _tabController == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.catalogTitle)),
        body: const SizedBox.shrink(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.catalogTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [for (final tab in _tabs) Tab(text: tab.label)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [for (final tab in _tabs) tab.view],
      ),
    );
  }
}

class _CatalogTabDef {
  const _CatalogTabDef(this.label, this.view);
  final String label;
  final Widget view;
}
