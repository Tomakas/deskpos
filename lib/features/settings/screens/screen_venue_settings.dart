import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/floor_map_editor_tab.dart';
import '../widgets/registers_tab.dart';
import '../widgets/sections_tab.dart';
import '../widgets/tables_tab.dart';

class ScreenVenueSettings extends ConsumerWidget {
  const ScreenVenueSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.settingsVenueTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.settingsSections),
              Tab(text: l.settingsTables),
              Tab(text: l.settingsFloorMap),
              Tab(text: l.settingsRegisters),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SectionsTab(),
            TablesTab(),
            FloorMapEditorTab(),
            RegistersTab(),
          ],
        ),
      ),
    );
  }
}
