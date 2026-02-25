import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/mode_tab.dart';
import '../widgets/register_tab.dart';

class ScreenRegisterSettings extends ConsumerWidget {
  const ScreenRegisterSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.settingsRegisterTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.modeTitle),
              Tab(text: l.sellTitle),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ModeTab(),
            RegisterTab(),
          ],
        ),
      ),
    );
  }
}
