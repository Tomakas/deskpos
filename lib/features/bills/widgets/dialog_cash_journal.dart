import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/cash_movement_type.dart';
import '../../../core/data/models/cash_movement_model.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';
import 'dialog_cash_movement.dart';

// ---------------------------------------------------------------------------
// Sale entry passed from outside (cash payments during this session)
// ---------------------------------------------------------------------------

class CashJournalSale {
  const CashJournalSale({
    required this.createdAt,
    required this.amount,
    this.billNumber,
  });

  final DateTime createdAt;

  /// In haléře.
  final int amount;

  /// Bill number for the note column.
  final String? billNumber;
}

// ---------------------------------------------------------------------------
// Unified row type for the table
// ---------------------------------------------------------------------------

enum _EntryKind { deposit, withdrawal, sale }

class _JournalEntry {
  const _JournalEntry({
    required this.createdAt,
    required this.kind,
    required this.amount,
    this.note,
  });

  final DateTime createdAt;
  final _EntryKind kind;

  /// In haléře, always positive.
  final int amount;
  final String? note;
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class DialogCashJournal extends ConsumerStatefulWidget {
  const DialogCashJournal({
    super.key,
    required this.movements,
    required this.sales,
    required this.currentBalance,
    this.openingCash = 0,
    this.openedAt,
  });

  final List<CashMovementModel> movements;
  final List<CashJournalSale> sales;

  /// Current cash balance in haléře.
  final int currentBalance;

  /// Opening cash amount in haléře (shown as synthetic entry).
  final int openingCash;

  /// Session opened at (timestamp for the opening cash entry).
  final DateTime? openedAt;

  @override
  ConsumerState<DialogCashJournal> createState() => _DialogCashJournalState();
}

class _DialogCashJournalState extends ConsumerState<DialogCashJournal> {
  bool _showDeposits = true;
  bool _showWithdrawals = true;
  bool _showSales = false;

  List<_JournalEntry> get _filtered {
    final entries = <_JournalEntry>[];

    if (_showDeposits) {
      // Synthetic opening cash entry
      if (widget.openingCash != 0 && widget.openedAt != null) {
        final l = context.l10n;
        entries.add(_JournalEntry(
          createdAt: widget.openedAt!,
          kind: _EntryKind.deposit,
          amount: widget.openingCash,
          note: l.openingCashNote,
        ));
      }

      for (final m in widget.movements) {
        if (m.type == CashMovementType.deposit) {
          entries.add(_JournalEntry(
            createdAt: m.createdAt,
            kind: _EntryKind.deposit,
            amount: m.amount,
            note: m.reason,
          ));
        }
      }
    }

    if (_showWithdrawals) {
      for (final m in widget.movements) {
        if (m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense || m.type == CashMovementType.handover) {
          entries.add(_JournalEntry(
            createdAt: m.createdAt,
            kind: _EntryKind.withdrawal,
            amount: m.amount,
            note: m.reason,
          ));
        }
      }
    }

    if (_showSales) {
      for (final s in widget.sales) {
        entries.add(_JournalEntry(
          createdAt: s.createdAt,
          kind: _EntryKind.sale,
          amount: s.amount,
          note: s.billNumber,
        ));
      }
    }

    entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final filtered = _filtered;

    return PosDialogShell(
      showCloseButton: true,
      title: l.cashJournalBalance,
      titleWidget: Text.rich(
        TextSpan(
          text: '${l.cashJournalBalance} ',
          style: theme.textTheme.titleLarge,
          children: [
            TextSpan(
              text: ref.money(widget.currentBalance),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      maxWidth: 800,
      expandHeight: true,
      padding: const EdgeInsets.all(20),
      children: [
        // Filters + add button
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilterChip(
                  showCheckmark: true,
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(l.cashJournalFilterDeposits, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ),
                  selected: _showDeposits,
                  onSelected: (v) => setState(() => _showDeposits = v),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilterChip(
                  showCheckmark: true,
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(l.cashJournalFilterWithdrawals, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ),
                  selected: _showWithdrawals,
                  onSelected: (v) => setState(() => _showWithdrawals = v),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilterChip(
                  showCheckmark: true,
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(l.cashJournalFilterSales, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ),
                  selected: _showSales,
                  onSelected: (v) => setState(() => _showSales = v),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilledButton(
                  style: PosButtonStyles.confirm(context),
                  onPressed: () => _addMovement(context),
                  child: Text(l.cashJournalAddMovement, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Table
        Flexible(
          child: PosTable<_JournalEntry>(
            columns: [
              PosColumn(
                label: l.cashJournalColumnTime,
                flex: 1,
                cellBuilder: (e) => Text(ref.fmtTime(e.createdAt), style: theme.textTheme.bodySmall),
              ),
              PosColumn(
                label: l.cashJournalColumnType,
                flex: 1,
                cellBuilder: (e) {
                  final typeName = switch (e.kind) {
                    _EntryKind.deposit => l.cashMovementDeposit,
                    _EntryKind.withdrawal => l.cashMovementWithdrawal,
                    _EntryKind.sale => l.cashMovementSale,
                  };
                  return Text(typeName, style: theme.textTheme.bodySmall);
                },
              ),
              PosColumn(
                label: l.cashJournalColumnAmount,
                flex: 1,
                numeric: true,
                cellBuilder: (e) {
                  final String sign;
                  final Color color;
                  switch (e.kind) {
                    case _EntryKind.deposit:
                      sign = '+';
                      color = context.appColors.positive;
                    case _EntryKind.withdrawal:
                      sign = '-';
                      color = theme.colorScheme.error;
                    case _EntryKind.sale:
                      sign = '+';
                      color = theme.colorScheme.primary;
                  }
                  return Text(
                    '$sign ${ref.money(e.amount)}',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
                  );
                },
              ),
              PosColumn(
                label: l.cashJournalColumnNote,
                flex: 4,
                headerAlign: TextAlign.center,
                cellBuilder: (e) => Text(
                  e.note ?? '',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            items: filtered,
            emptyMessage: l.cashJournalEmpty,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _addMovement(BuildContext context) async {
    final result = await showDialog<CashMovementResult>(
      context: context,
      builder: (_) => const DialogCashMovement(),
    );
    if (result != null && context.mounted) {
      Navigator.pop(context, result);
    }
  }
}
