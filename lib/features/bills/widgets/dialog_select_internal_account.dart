import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/internal_account_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

class DialogSelectInternalAccount extends ConsumerWidget {
  const DialogSelectInternalAccount({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return PosDialogShell(
      title: l.internalAccountSelectTitle,
      maxWidth: 400,
      scrollable: true,
      bottomActions: PosDialogActions(
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
        ],
      ),
      children: [
        FutureBuilder<List<InternalAccountModel>>(
          future: ref.read(internalAccountRepositoryProvider).getActive(company.id),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ));
            }
            final accounts = snap.data!;
            if (accounts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l.internalAccountEmpty),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final account in accounts)
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: Text(account.name),
                    onTap: () => Navigator.pop(context, account),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
