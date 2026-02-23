import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_date_range_selector.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';

class DialogTipStatistics extends ConsumerStatefulWidget {
  const DialogTipStatistics({super.key});

  @override
  ConsumerState<DialogTipStatistics> createState() =>
      _DialogTipStatisticsState();
}

class _TipStaffRow {
  const _TipStaffRow({
    required this.username,
    required this.count,
    required this.amount,
  });
  final String username;
  final int count;
  final int amount;
}

class _DialogTipStatisticsState extends ConsumerState<DialogTipStatistics> {
  bool _loading = false;
  int _totalTips = 0;
  List<_TipStaffRow> _rows = [];

  Future<void> _loadData(DateTime from, DateTime to) async {
    setState(() => _loading = true);

    final company = ref.read(currentCompanyProvider);
    if (company == null) {
      setState(() => _loading = false);
      return;
    }

    final paymentRepo = ref.read(paymentRepositoryProvider);
    final userRepo = ref.read(userRepositoryProvider);

    final payments = await paymentRepo.getTipsInRange(company.id, from, to);

    // Aggregate by userId
    final byUser = <String, (int count, int amount)>{};
    for (final p in payments) {
      final uid = p.userId ?? '';
      final existing = byUser[uid];
      byUser[uid] = (
        (existing?.$1 ?? 0) + 1,
        (existing?.$2 ?? 0) + p.tipIncludedAmount,
      );
    }

    // Resolve usernames
    final rows = <_TipStaffRow>[];
    for (final entry in byUser.entries) {
      String username = '-';
      if (entry.key.isNotEmpty) {
        final user = await userRepo.getById(entry.key, includeDeleted: true);
        username = user?.username ?? '-';
      }
      rows.add(_TipStaffRow(
        username: username,
        count: entry.value.$1,
        amount: entry.value.$2,
      ));
    }

    // Sort descending by amount
    rows.sort((a, b) => b.amount.compareTo(a.amount));

    final total = rows.fold(0, (sum, r) => sum + r.amount);

    if (!mounted) return;
    setState(() {
      _rows = rows;
      _totalTips = total;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final locale = ref.watch(appLocaleProvider).value ?? 'cs';

    return PosDialogShell(
      title: l.tipStatsTitle,
      titleStyle: theme.textTheme.headlineSmall,
      maxWidth: 640,
      children: [
        PosDateRangeSelector(
          onChanged: _loadData,
          locale: locale,
          l10n: l,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.tipStatsTotal,
              style: theme.textTheme.titleMedium,
            ),
            Text(
              ref.money(_totalTips),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : PosTable<_TipStaffRow>(
                  columns: [
                    PosColumn(
                      label: l.tipStatsColumnUser,
                      cellBuilder: (r) => Text(r.username),
                    ),
                    PosColumn(
                      label: l.tipStatsColumnCount,
                      width: 80,
                      numeric: true,
                      cellBuilder: (r) => Text(
                        '${r.count}',
                        textAlign: TextAlign.right,
                      ),
                    ),
                    PosColumn(
                      label: l.tipStatsColumnAmount,
                      width: 120,
                      numeric: true,
                      cellBuilder: (r) => Text(
                        ref.money(r.amount),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                  items: _rows,
                  emptyMessage: l.tipStatsEmpty,
                ),
        ),
        const SizedBox(height: 16),
        PosDialogActions(
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionClose),
            ),
          ],
        ),
      ],
    );
  }
}
