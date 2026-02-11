import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations_ext.dart';
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

class DialogShiftsList extends StatefulWidget {
  const DialogShiftsList({super.key, required this.shifts});
  final List<ShiftDisplayRow> shifts;

  @override
  State<DialogShiftsList> createState() => _DialogShiftsListState();
}

class _DialogShiftsListState extends State<DialogShiftsList> {
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

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    return '${m}min';
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
    final dateFormat = DateFormat('d.M.yyyy', 'cs');
    final timeFormat = DateFormat('HH:mm', 'cs');
    final filtered = _filteredShifts;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.shiftsListTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              // Date filter row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => _pickDate(context, true),
                    child: Text(dateFormat.format(_dateFrom)),
                  ),
                  const Text(' — '),
                  TextButton(
                    onPressed: () => _pickDate(context, false),
                    child: Text(dateFormat.format(_dateTo)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Table
              SizedBox(
                height: 400,
                child: PosTable<ShiftDisplayRow>(
                  columns: [
                    PosColumn(label: l.shiftsColumnDate, width: 90, cellBuilder: (s) => Text(dateFormat.format(s.loginAt))),
                    PosColumn(label: l.shiftsColumnUser, cellBuilder: (s) => Text(s.username)),
                    PosColumn(label: l.shiftsColumnLogin, width: 60, cellBuilder: (s) => Text(timeFormat.format(s.loginAt))),
                    PosColumn(
                      label: l.shiftsColumnLogout,
                      width: 80,
                      numeric: true,
                      cellBuilder: (s) {
                        final isOngoing = s.logoutAt == null;
                        return Text(
                          isOngoing ? l.shiftsOngoing : timeFormat.format(s.logoutAt!),
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
                        return Text(_fmtDuration(duration), textAlign: TextAlign.right);
                      },
                    ),
                  ],
                  items: filtered,
                  emptyMessage: l.shiftsListEmpty,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.actionClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
