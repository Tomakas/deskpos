import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/company_tab.dart';
import '../widgets/register_tab.dart';
import '../widgets/users_tab.dart';

class ScreenSettings extends ConsumerWidget {
  const ScreenSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.settingsTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.settingsTabCompany),
              Tab(text: l.settingsTabRegister),
              Tab(text: l.settingsTabUsers),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CompanyTab(),
            RegisterTab(),
            UsersTab(),
          ],
        ),
      ),
    );
  }
}
