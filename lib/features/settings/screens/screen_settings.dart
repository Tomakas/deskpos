import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/cloud_tab.dart';
import '../widgets/company_info_tab.dart';
import '../widgets/log_tab.dart';
import '../widgets/payment_methods_tab.dart';
import '../widgets/security_tab.dart';
import '../widgets/tax_rates_tab.dart';
import '../widgets/users_tab.dart';

class ScreenCompanySettings extends ConsumerWidget {
  const ScreenCompanySettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.settingsCompanyTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.settingsTabCompany),
              Tab(text: l.settingsTabUsers),
              Tab(text: l.settingsSectionSecurity),
              Tab(text: l.settingsSectionCloud),
              Tab(text: l.settingsTaxRates),
              Tab(text: l.settingsPaymentMethods),
              Tab(text: l.settingsTabLog),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CompanyInfoTab(),
            UsersTab(),
            SecurityTab(),
            CloudTab(),
            TaxRatesTab(),
            PaymentMethodsTab(),
            LogTab(),
          ],
        ),
      ),
    );
  }
}
