import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';
import '../models/z_report_data.dart';

class DialogZReportList extends ConsumerStatefulWidget {
  const DialogZReportList({
    super.key,
    required this.sessions,
    required this.onSessionSelected,
    this.onVenueReport,
  });
  final List<ZReportSessionSummary> sessions;
  final ValueChanged<String> onSessionSelected;
  final void Function(DateTime dateFrom, DateTime dateTo)? onVenueReport;

  @override
  ConsumerState<DialogZReportList> createState() => _DialogZReportListState();
}

class _DialogZReportListState extends ConsumerState<DialogZReportList> {
  late DateTime _dateFrom;
  late DateTime _dateTo;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _dateFrom = _dateTo.subtract(const Duration(days: 7));
  }

  List<ZReportSessionSummary> get _filteredSessions {
    return widget.sessions.where((s) {
      final d = s.closedAt ?? s.openedAt;
      return !d.isBefore(_dateFrom) && !d.isAfter(_dateTo);
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
    final filtered = _filteredSessions;

    return PosDialogShell(
      title: l.zReportListTitle,
      titleStyle: theme.textTheme.headlineSmall,
      maxWidth: 720,
      scrollable: true,
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
          child: PosTable<ZReportSessionSummary>(
            columns: [
              PosColumn(
                label: l.zReportColumnDate,
                width: 100,
                cellBuilder: (s) => Text(ref.fmtDate(s.closedAt ?? s.openedAt)),
              ),
              PosColumn(
                label: l.zReportColumnTime,
                width: 60,
                cellBuilder: (s) => Text(ref.fmtTime(s.closedAt ?? s.openedAt)),
              ),
              PosColumn(
                label: l.zReportRegisterColumn,
                cellBuilder: (s) => Text(
                  s.registerName ?? '-',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PosColumn(label: l.zReportColumnUser, cellBuilder: (s) => Text(s.userName)),
              PosColumn(
                label: l.zReportColumnRevenue,
                width: 100,
                numeric: true,
                cellBuilder: (s) => Text(ref.money(s.totalRevenue), textAlign: TextAlign.right),
              ),
              PosColumn(
                label: l.zReportColumnDifference,
                width: 80,
                numeric: true,
                cellBuilder: (s) {
                  final diff = s.difference;
                  final diffColor = diff == null ? null : cashDifferenceColor(diff, context);
                  return Text(
                    diff != null ? ref.moneyWithSign(diff) : '-',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: diffColor),
                  );
                },
              ),
            ],
            items: filtered,
            onRowTap: (s) => widget.onSessionSelected(s.sessionId),
            emptyMessage: l.zReportListEmpty,
          ),
        ),
        const SizedBox(height: 16),
      ],
      bottomActions: PosDialogActions(
        actions: [
          if (widget.onVenueReport != null)
            OutlinedButton(
              onPressed: () => widget.onVenueReport!(_dateFrom, _dateTo),
              child: Text(l.zReportVenueReport),
            ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionClose),
          ),
        ],
      ),
    );
  }
}
