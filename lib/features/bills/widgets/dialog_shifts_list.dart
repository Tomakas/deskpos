import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';

class ShiftDisplayRow {
  const ShiftDisplayRow({
    required this.username,
    required this.loginAt,
    this.logoutAt,
  });
  final String username;
  final DateTime loginAt;
  final DateTime? logoutAt;
}

class DialogShiftsList extends ConsumerStatefulWidget {
  const DialogShiftsList({super.key, required this.shifts});
  final List<ShiftDisplayRow> shifts;

  @override
  ConsumerState<DialogShiftsList> createState() => _DialogShiftsListState();
}

class _DialogShiftsListState extends ConsumerState<DialogShiftsList> {
  late DateTime _dateFrom;
  late DateTime _dateTo;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _dateFrom = _dateTo.subtract(const Duration(days: 7));
  }

  List<ShiftDisplayRow> get _filteredShifts {
    return widget.shifts.where((s) {
      return !s.loginAt.isBefore(_dateFrom) && !s.loginAt.isAfter(_dateTo);
    }).toList();
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final initial = isFrom ? _dateFrom : _dateTo;
    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (result != null && mounted) {
      setState(() {
        if (isFrom) {
          _dateFrom = result;
        } else {
          _dateTo = DateTime(result.year, result.month, result.day, 23, 59, 59);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final filtered = _filteredShifts;
    String fmtDur(Duration d) => formatDuration(d,
        hm: l.durationHoursMinutes, hOnly: l.durationHoursOnly, mOnly: l.durationMinutesOnly);

    return PosDialogShell(
      title: l.shiftsListTitle,
      titleStyle: theme.textTheme.headlineSmall,
      maxWidth: 640,
      children: [
        // Date filter row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => _pickDate(context, true),
              child: Text(ref.fmtDate(_dateFrom)),
            ),
            const Text(' — '),
            TextButton(
              onPressed: () => _pickDate(context, false),
              child: Text(ref.fmtDate(_dateTo)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Table
        SizedBox(
          height: 400,
          child: PosTable<ShiftDisplayRow>(
            columns: [
              PosColumn(label: l.shiftsColumnDate, width: 90, cellBuilder: (s) => Text(ref.fmtDate(s.loginAt))),
              PosColumn(label: l.shiftsColumnUser, cellBuilder: (s) => Text(s.username)),
              PosColumn(label: l.shiftsColumnLogin, width: 60, cellBuilder: (s) => Text(ref.fmtTime(s.loginAt))),
              PosColumn(
                label: l.shiftsColumnLogout,
                width: 80,
                numeric: true,
                cellBuilder: (s) {
                  final isOngoing = s.logoutAt == null;
                  return Text(
                    isOngoing ? l.shiftsOngoing : ref.fmtTime(s.logoutAt!),
                    textAlign: TextAlign.right,
                    style: isOngoing
                        ? TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)
                        : null,
                  );
                },
              ),
              PosColumn(
                label: l.shiftsColumnDuration,
                width: 80,
                numeric: true,
                cellBuilder: (s) {
                  final duration = (s.logoutAt ?? DateTime.now()).difference(s.loginAt);
                  return Text(fmtDur(duration), textAlign: TextAlign.right);
                },
              ),
            ],
            items: filtered,
            emptyMessage: l.shiftsListEmpty,
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
