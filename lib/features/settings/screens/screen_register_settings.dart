import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/register_tab.dart';

class ScreenRegisterSettings extends ConsumerWidget {
  const ScreenRegisterSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsRegisterTitle),
      ),
      body: const RegisterTab(),
    );
  }
}
