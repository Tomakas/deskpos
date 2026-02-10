import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../models/z_report_data.dart';

class DialogZReportList extends StatefulWidget {
  const DialogZReportList({
    super.key,
    required this.sessions,
    required this.onSessionSelected,
  });
  final List<ZReportSessionSummary> sessions;
  final ValueChanged<String> onSessionSelected;

  @override
  State<DialogZReportList> createState() => _DialogZReportListState();
}

class _DialogZReportListState extends State<DialogZReportList> {
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

  String _fmtKc(int halere) => '${halere ~/ 100} Kč';

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
    final filtered = _filteredSessions;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.zReportListTitle, style: theme.textTheme.headlineSmall),
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
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Row(
                  children: [
                    SizedBox(width: 100, child: Text(l.zReportColumnDate, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 60, child: Text(l.zReportColumnTime, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                    Expanded(child: Text(l.zReportColumnUser, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 100, child: Text(l.zReportColumnRevenue, textAlign: TextAlign.right, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 80, child: Text(l.zReportColumnDifference, textAlign: TextAlign.right, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              // Body
              SizedBox(
                height: 400,
                child: filtered.isEmpty
                    ? Center(child: Text(l.zReportListEmpty, style: theme.textTheme.bodyMedium))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final s = filtered[index];
                          final displayDate = s.closedAt ?? s.openedAt;
                          final diff = s.difference;
                          final diffColor = diff == null
                              ? null
                              : diff == 0
                                  ? Colors.green
                                  : diff > 0
                                      ? Colors.blue
                                      : theme.colorScheme.error;

                          return InkWell(
                            onTap: () => widget.onSessionSelected(s.sessionId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3))),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 100, child: Text(dateFormat.format(displayDate))),
                                  SizedBox(width: 60, child: Text(timeFormat.format(displayDate))),
                                  Expanded(child: Text(s.userName)),
                                  SizedBox(width: 100, child: Text(_fmtKc(s.totalRevenue), textAlign: TextAlign.right)),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      diff != null ? '${diff >= 0 ? '+' : ''}${diff ~/ 100} Kč' : '-',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(color: diffColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
