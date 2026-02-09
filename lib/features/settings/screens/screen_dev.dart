import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/categories_tab.dart';
import '../widgets/payment_methods_tab.dart';
import '../widgets/products_tab.dart';
import '../widgets/sections_tab.dart';
import '../widgets/tables_tab.dart';
import '../widgets/tax_rates_tab.dart';
import '../widgets/users_tab.dart';

class ScreenDev extends ConsumerWidget {
  const ScreenDev({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.settingsTitle),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l.settingsUsers),
              Tab(text: l.settingsSections),
              Tab(text: l.settingsTables),
              Tab(text: l.settingsCategories),
              Tab(text: l.settingsProducts),
              Tab(text: l.settingsTaxRates),
              Tab(text: l.settingsPaymentMethods),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UsersTab(),
            SectionsTab(),
            TablesTab(),
            CategoriesTab(),
            ProductsTab(),
            TaxRatesTab(),
            PaymentMethodsTab(),
          ],
        ),
      ),
    );
  }
}
