import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/data/enums/cash_movement_type.dart';
import '../../../core/data/models/cash_movement_model.dart';
import '../../../core/l10n/app_localizations_ext.dart';
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

class DialogCashJournal extends StatefulWidget {
  const DialogCashJournal({
    super.key,
    required this.movements,
    required this.sales,
    required this.currentBalance,
  });

  final List<CashMovementModel> movements;
  final List<CashJournalSale> sales;

  /// Current cash balance in haléře.
  final int currentBalance;

  @override
  State<DialogCashJournal> createState() => _DialogCashJournalState();
}

class _DialogCashJournalState extends State<DialogCashJournal> {
  bool _showDeposits = true;
  bool _showWithdrawals = true;
  bool _showSales = false;

  List<_JournalEntry> get _filtered {
    final entries = <_JournalEntry>[];

    if (_showDeposits) {
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
        if (m.type == CashMovementType.withdrawal || m.type == CashMovementType.expense) {
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
    final timeFormat = DateFormat('HH:mm', 'cs');
    final filtered = _filtered;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: balance
              Row(
                children: [
                  Text(l.cashJournalBalance, style: theme.textTheme.titleMedium),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.currentBalance ~/ 100} Kč',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filters + add button
              Row(
                children: [
                  FilterChip(
                    showCheckmark: true,
                    label: Text(l.cashJournalFilterDeposits, style: const TextStyle(fontSize: 12)),
                    selected: _showDeposits,
                    onSelected: (v) => setState(() => _showDeposits = v),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    showCheckmark: true,
                    label: Text(l.cashJournalFilterWithdrawals, style: const TextStyle(fontSize: 12)),
                    selected: _showWithdrawals,
                    onSelected: (v) => setState(() => _showWithdrawals = v),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    showCheckmark: true,
                    label: Text(l.cashJournalFilterSales, style: const TextStyle(fontSize: 12)),
                    selected: _showSales,
                    onSelected: (v) => setState(() => _showSales = v),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => _addMovement(context),
                      child: Text(l.cashJournalAddMovement, style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Table header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 50, child: Text(l.cashJournalColumnTime, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 60, child: Text(l.cashJournalColumnType, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 80, child: Text(l.cashJournalColumnAmount, textAlign: TextAlign.right, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.cashJournalColumnNote, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),

              // Table body — fixed height
              SizedBox(
                height: 240,
                child: filtered.isEmpty
                    ? Center(
                        child: Text(l.cashJournalEmpty, style: theme.textTheme.bodySmall),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final e = filtered[index];
                          final String sign;
                          final Color color;
                          final String typeName;

                          switch (e.kind) {
                            case _EntryKind.deposit:
                              sign = '+';
                              color = Colors.green;
                              typeName = l.cashMovementDeposit;
                            case _EntryKind.withdrawal:
                              sign = '-';
                              color = theme.colorScheme.error;
                              typeName = l.cashMovementWithdrawal;
                            case _EntryKind.sale:
                              sign = '+';
                              color = theme.colorScheme.primary;
                              typeName = l.cashMovementSale;
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3))),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 50, child: Text(timeFormat.format(e.createdAt), style: theme.textTheme.bodySmall)),
                                SizedBox(width: 60, child: Text(typeName, style: theme.textTheme.bodySmall)),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    '$sign ${e.amount ~/ 100} Kč',
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    e.note ?? '',
                                    style: theme.textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),

              // Close button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.actionClose),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addMovement(BuildContext context) async {
    final result = await showDialog<CashMovementResult>(
      context: context,
      builder: (_) => const DialogCashMovement(),
    );
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }
}
