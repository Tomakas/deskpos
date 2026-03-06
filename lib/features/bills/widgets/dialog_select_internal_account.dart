import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/internal_account_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

enum _AccountFilter { general, employee }

class DialogSelectInternalAccount extends ConsumerStatefulWidget {
  const DialogSelectInternalAccount({super.key});

  @override
  ConsumerState<DialogSelectInternalAccount> createState() => _DialogSelectInternalAccountState();
}

class _DialogSelectInternalAccountState extends ConsumerState<DialogSelectInternalAccount> {
  _AccountFilter _filter = _AccountFilter.general;
  List<InternalAccountModel>? _allAccounts;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return PosDialogShell(
      title: l.internalAccountSelectTitle,
      showCloseButton: true,
      maxWidth: 400,
      scrollable: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: SegmentedButton<_AccountFilter>(
              segments: [
                ButtonSegment(
                  value: _AccountFilter.general,
                  label: Text(l.internalAccountAddGeneral),
                ),
                ButtonSegment(
                  value: _AccountFilter.employee,
                  label: Text(l.internalAccountAddEmployee),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (val) {
                setState(() => _filter = val.first);
              },
              showSelectedIcon: false,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<InternalAccountModel>>(
          future: _allAccounts == null
              ? ref.read(internalAccountRepositoryProvider).getActive(company.id)
              : Future.value(_allAccounts),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ));
            }
            _allAccounts = snap.data!;
            final filtered = _allAccounts!.where((a) {
              if (_filter == _AccountFilter.general) return a.userId == null;
              if (_filter == _AccountFilter.employee) return a.userId != null;
              return true;
            }).toList();

            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text(l.internalAccountEmpty)),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final account in filtered)
                  ListTile(
                    leading: Icon(
                      account.userId != null ? Icons.person : Icons.account_balance_wallet,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
