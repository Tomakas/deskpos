import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import 'screen_cloud_auth.dart';

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
              Tab(text: l.settingsTabSecurity),
              Tab(text: l.settingsTabSales),
              Tab(text: l.settingsTabCloud),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text(l.settingsTabSecurity)),
            Center(child: Text(l.settingsTabSales)),
            const ScreenCloudAuth(),
          ],
        ),
      ),
    );
  }
}
