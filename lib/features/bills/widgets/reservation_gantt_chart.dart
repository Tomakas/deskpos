import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/data/enums/reservation_status.dart';
import '../../../core/data/models/reservation_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';

class ReservationGanttChart extends StatelessWidget {
  const ReservationGanttChart({
    super.key,
    required this.reservations,
    required this.tables,
    required this.dateFrom,
    required this.dateTo,
    required this.onReservationTap,
  });

  final List<ReservationModel> reservations;
  final List<TableModel> tables;
  final DateTime dateFrom;
  final DateTime dateTo;
  final void Function(ReservationModel) onReservationTap;

  static const double _minRowHeight = 32;
  static const double _labelWidth = 100;
  static const double _headerHeight = 28;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final locale = Localizations.localeOf(context).languageCode;

    if (tables.isEmpty && reservations.isEmpty) {
      return Center(child: Text(l.reservationChartNoData));
    }

    // Build row data from ALL passed tables
    final rowOrder = <String?>[];
    final rowLabels = <String?, String>{};
    for (final t in tables) {
      rowOrder.add(t.id);
      rowLabels[t.id] = t.name;
    }
    final hasUnassigned = reservations.any((r) => r.tableId == null);
    if (hasUnassigned) {
      rowOrder.add(null);
      rowLabels[null] = '–';
    }

    // Time span
    final dayStart = DateTime(dateFrom.year, dateFrom.month, dateFrom.day);
    final dayEnd = DateTime(dateTo.year, dateTo.month, dateTo.day);
    final numDays = dayEnd.difference(dayStart).inDays + 1;
    final totalMinutes = numDays * 24 * 60;
    final isSingleDay = numDays == 1;

    // Group reservations by table
    final rowReservations = <String?, List<ReservationModel>>{};
    for (final r in reservations) {
      (rowReservations[r.tableId] ??= []).add(r);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth - _labelWidth;
        if (chartWidth <= 0) return const SizedBox.shrink();
        final pxPerMinute = chartWidth / totalMinutes;

        // Dynamic row height: fill available vertical space
        final rowCount = rowOrder.length;
        final availableForRows = constraints.maxHeight - _headerHeight;
        final rowHeight = rowCount > 0
            ? (availableForRows / rowCount).clamp(_minRowHeight, double.infinity)
            : _minRowHeight;
        final needsScroll = rowCount * rowHeight > availableForRows;

        double reservationLeft(ReservationModel r) {
          final dayIndex = DateTime(
            r.reservationDate.year,
            r.reservationDate.month,
            r.reservationDate.day,
          ).difference(dayStart).inDays;
          final minuteInDay = r.reservationDate.hour * 60 + r.reservationDate.minute;
          return (dayIndex * 24 * 60 + minuteInDay) * pxPerMinute;
        }

        double durationWidth(int minutes) {
          return (minutes * pxPerMinute).clamp(2.0, double.infinity);
        }

        // Now indicator
        final now = DateTime.now();
        final nowDayIndex = DateTime(now.year, now.month, now.day).difference(dayStart).inDays;
        final nowAbsMinute = nowDayIndex * 24 * 60 + now.hour * 60 + now.minute;
        final showNow = nowDayIndex >= 0 && nowDayIndex < numDays;
        final nowX = showNow ? nowAbsMinute * pxPerMinute : 0.0;

        Widget buildRows() {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Labels column
              SizedBox(
                width: _labelWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final tableId in rowOrder)
                      Container(
                        height: rowHeight,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              rowLabels[tableId] ?? '–',
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Chart area
              SizedBox(
                width: chartWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final tableId in rowOrder)
                      Container(
                        height: rowHeight,
                        width: chartWidth,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            if (isSingleDay)
                              ..._buildHourGridLines(chartWidth, theme)
                            else
                              ..._buildDayGridLines(chartWidth, numDays, theme),
                            for (final r in rowReservations[tableId] ?? <ReservationModel>[])
                              _buildBlock(
                                context: context,
                                r: r,
                                left: reservationLeft(r),
                                width: durationWidth(r.durationMinutes),
                                theme: theme,
                                appColors: appColors,
                              ),
                            if (showNow)
                              Positioned(
                                left: nowX,
                                top: 0,
                                bottom: 0,
                                child: Container(width: 2, color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            // Header row (fixed)
            Row(
              children: [
                SizedBox(width: _labelWidth),
                SizedBox(
                  width: chartWidth,
                  child: isSingleDay
                      ? _buildHourHeader(chartWidth, theme)
                      : _buildDayHeader(chartWidth, numDays, dayStart, locale, theme),
                ),
              ],
            ),
            // Table rows (scrollable if needed)
            if (needsScroll)
              Expanded(child: SingleChildScrollView(child: buildRows()))
            else
              Expanded(child: buildRows()),
          ],
        );
      },
    );
  }

  // ── Day view header: hour labels ──────────────────────────────

  Widget _buildHourHeader(double chartWidth, ThemeData theme) {
    final hourWidth = chartWidth / 24;
    // Dynamic interval so labels don't overlap
    int interval = 1;
    if (hourWidth < 25) {
      interval = 4;
    } else if (hourWidth < 40) {
      interval = 3;
    } else if (hourWidth < 55) {
      interval = 2;
    }

    return SizedBox(
      height: _headerHeight,
      width: chartWidth,
      child: Stack(
        children: [
          for (int h = 0; h <= 24; h += interval)
            Positioned(
              left: h * hourWidth - 14,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: 28,
                child: Center(
                  child: Text(
                    h.toString().padLeft(2, '0'),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Week/multi-day header: day labels ─────────────────────────

  Widget _buildDayHeader(
    double chartWidth,
    int numDays,
    DateTime dayStart,
    String locale,
    ThemeData theme,
  ) {
    final dayWidth = chartWidth / numDays;
    // Short label for many days (month), full label for few days (week)
    final useShortLabel = dayWidth < 70;

    return SizedBox(
      height: _headerHeight,
      width: chartWidth,
      child: Row(
        children: [
          for (int i = 0; i < numDays; i++)
            SizedBox(
              width: dayWidth,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    left: i > 0
                        ? BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5)
                        : BorderSide.none,
                  ),
                ),
                child: Text(
                  useShortLabel
                      ? '${dayStart.add(Duration(days: i)).day}.'
                      : DateFormat('E d.M.', locale).format(dayStart.add(Duration(days: i))),
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Day view grid: vertical lines per hour ────────────────────

  List<Widget> _buildHourGridLines(double chartWidth, ThemeData theme) {
    final hourWidth = chartWidth / 24;
    return [
      for (int h = 0; h <= 24; h++)
        Positioned(
          left: h * hourWidth,
          top: 0,
          bottom: 0,
          child: Container(
            width: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
    ];
  }

  // ── Week view grid: vertical lines per day ────────────────────

  List<Widget> _buildDayGridLines(double chartWidth, int numDays, ThemeData theme) {
    final dayWidth = chartWidth / numDays;
    return [
      for (int d = 0; d <= numDays; d++)
        Positioned(
          left: d * dayWidth,
          top: 0,
          bottom: 0,
          child: Container(
            width: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
    ];
  }

  // ── Reservation block ─────────────────────────────────────────

  Widget _buildBlock({
    required BuildContext context,
    required ReservationModel r,
    required double left,
    required double width,
    required ThemeData theme,
    required AppColorsExtension appColors,
  }) {
    final color = _statusColor(r.status, theme, appColors);
    final isCancelled = r.status == ReservationStatus.cancelled;

    final tooltipText = '${r.customerName}\n'
        '${r.reservationDate.hour.toString().padLeft(2, '0')}:'
        '${r.reservationDate.minute.toString().padLeft(2, '0')}'
        ' – ${r.durationMinutes} min'
        '${r.partySize > 0 ? ' · ${r.partySize} guests' : ''}';

    final showName = width > 50;
    final showNumber = width > 14;

    return Positioned(
      left: left,
      width: width,
      top: 2,
      bottom: 2,
      child: Tooltip(
        message: tooltipText,
        child: Material(
          color: isCancelled ? color.withValues(alpha: 0.3) : color,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => onReservationTap(r),
            child: Container(
              decoration: isCancelled
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color, width: 1),
                    )
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              alignment: Alignment.centerLeft,
              child: showName || showNumber
                  ? Text(
                      showName ? r.customerName : '${r.partySize}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isCancelled
                            ? theme.colorScheme.onSurface
                            : _onStatusColor(r.status, theme),
                        decoration: isCancelled ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  // ── Now indicator ─────────────────────────────────────────────

  Color _statusColor(
    ReservationStatus status,
    ThemeData theme,
    AppColorsExtension appColors,
  ) {
    switch (status) {
      case ReservationStatus.created:
        return theme.colorScheme.outlineVariant;
      case ReservationStatus.confirmed:
        return theme.colorScheme.primary;
      case ReservationStatus.seated:
        return appColors.success;
      case ReservationStatus.cancelled:
        return appColors.danger;
    }
  }

  Color _onStatusColor(ReservationStatus status, ThemeData theme) {
    switch (status) {
      case ReservationStatus.created:
        return theme.colorScheme.onSurface;
      case ReservationStatus.confirmed:
        return theme.colorScheme.onPrimary;
      case ReservationStatus.seated:
        return Colors.white;
      case ReservationStatus.cancelled:
        return theme.colorScheme.onSurface;
    }
  }
}
