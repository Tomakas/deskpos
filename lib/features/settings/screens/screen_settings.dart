import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/company_tab.dart';
import '../widgets/users_tab.dart';

class ScreenCompanySettings extends ConsumerWidget {
  const ScreenCompanySettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.settingsCompanyTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.settingsTabCompany),
              Tab(text: l.settingsTabUsers),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CompanyTab(),
            UsersTab(),
          ],
        ),
      ),
    );
  }
}
