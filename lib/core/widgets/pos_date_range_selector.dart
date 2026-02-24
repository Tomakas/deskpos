import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

enum DatePeriod { day, week, month, year, custom }

class PosDateRangeSelector extends StatefulWidget {
  const PosDateRangeSelector({
    super.key,
    required this.onChanged,
    required this.locale,
    required this.l10n,
    this.initialPeriod = DatePeriod.day,
    this.allowFuture = false,
  });

  final void Function(DateTime from, DateTime to) onChanged;
  final String locale;
  final AppLocalizations l10n;
  final DatePeriod initialPeriod;
  final bool allowFuture;

  @override
  State<PosDateRangeSelector> createState() => _PosDateRangeSelectorState();
}

class _PosDateRangeSelectorState extends State<PosDateRangeSelector> {
  late DatePeriod _period = widget.initialPeriod;
  int _offset = 0;
  DateTime? _customFrom;
  DateTime? _customTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _emitRange());
  }

  void _emitRange() {
    final (from, to) = _computeRange();
    widget.onChanged(from, to);
  }

  (DateTime, DateTime) _computeRange() {
    if (_period == DatePeriod.custom && _customFrom != null && _customTo != null) {
      return (
        DateTime(_customFrom!.year, _customFrom!.month, _customFrom!.day),
        DateTime(_customTo!.year, _customTo!.month, _customTo!.day, 23, 59, 59, 999),
      );
    }

    final now = DateTime.now();
    switch (_period) {
      case DatePeriod.day:
        final day = DateTime(now.year, now.month, now.day + _offset);
        return (day, DateTime(day.year, day.month, day.day, 23, 59, 59, 999));
      case DatePeriod.week:
        // Week starts Monday
        final todayMonday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        final monday = todayMonday.add(Duration(days: 7 * _offset));
        final sunday = monday.add(const Duration(days: 6));
        return (monday, DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999));
      case DatePeriod.month:
        final m = DateTime(now.year, now.month + _offset);
        final lastDay = DateTime(m.year, m.month + 1, 0);
        return (DateTime(m.year, m.month, 1), DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59, 999));
      case DatePeriod.year:
        final y = now.year + _offset;
        return (DateTime(y, 1, 1), DateTime(y, 12, 31, 23, 59, 59, 999));
      case DatePeriod.custom:
        // Fallback if custom dates not set yet — use today
        final today = DateTime(now.year, now.month, now.day);
        return (today, DateTime(today.year, today.month, today.day, 23, 59, 59, 999));
    }
  }

  (String? primary, String? secondary) _buildLabels() {
    final l = widget.l10n;
    final locale = widget.locale;
    final (from, to) = _computeRange();

    switch (_period) {
      case DatePeriod.day:
        final dateStr = DateFormat.yMd(locale).format(from);
        if (_offset == 0) return (l.periodToday, dateStr);
        if (_offset == -1) return (l.periodYesterday, dateStr);
        final dayName = DateFormat.EEEE(locale).format(from);
        return ('${dayName[0].toUpperCase()}${dayName.substring(1)} $dateStr', null);
      case DatePeriod.week:
        final rangeStr = '${DateFormat.Md(locale).format(from)} — ${DateFormat.yMd(locale).format(to)}';
        if (_offset == 0) return (l.periodThisWeek, rangeStr);
        if (_offset == -1) return (l.periodLastWeek, rangeStr);
        return (rangeStr, null);
      case DatePeriod.month:
        final monthStr = DateFormat.yMMMM(locale).format(from);
        final capitalized = '${monthStr[0].toUpperCase()}${monthStr.substring(1)}';
        if (_offset == 0) return (l.periodThisMonth, capitalized);
        if (_offset == -1) return (l.periodLastMonth, capitalized);
        return (capitalized, null);
      case DatePeriod.year:
        final yearStr = '${from.year}';
        if (_offset == 0) return (l.periodThisYear, yearStr);
        if (_offset == -1) return (l.periodLastYear, yearStr);
        return (yearStr, null);
      case DatePeriod.custom:
        if (_customFrom != null && _customTo != null) {
          final rangeStr = '${DateFormat.yMd(locale).format(_customFrom!)} — ${DateFormat.yMd(locale).format(_customTo!)}';
          return (rangeStr, null);
        }
        return (l.periodCustom, null);
    }
  }

  void _onPeriodSelected(DatePeriod period) {
    if (period == DatePeriod.custom) {
      _pickCustomRange();
      return;
    }
    setState(() {
      _period = period;
      _offset = 0;
    });
    _emitRange();
  }

  void _navigate(int delta) {
    setState(() => _offset += delta);
    _emitRange();
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5);
    final lastDate = DateTime(now.year + 1, 12, 31);

    final from = await showDatePicker(
      context: context,
      initialDate: _customFrom ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (from == null || !mounted) return;

    final to = await showDatePicker(
      context: context,
      initialDate: from,
      firstDate: from,
      lastDate: lastDate,
    );
    if (to == null || !mounted) return;

    setState(() {
      _period = DatePeriod.custom;
      _customFrom = from;
      _customTo = to;
    });
    _emitRange();
  }

  Widget _buildNavigation(ThemeData theme, bool isCustom, String? primary, String? secondary) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          icon: const Icon(Icons.chevron_left),
          onPressed: isCustom ? null : () => _navigate(-1),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (primary != null)
                Text(
                  primary,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              if (secondary != null)
                Text(
                  secondary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        IconButton.filledTonal(
          icon: const Icon(Icons.chevron_right),
          onPressed: isCustom || (!widget.allowFuture && _offset >= 0) ? null : () => _navigate(1),
        ),
      ],
    );
  }

  List<Widget> _buildChips(List<(DatePeriod, String)> chips, {bool expanded = false}) {
    return [
      for (var i = 0; i < chips.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        if (expanded)
          Expanded(
            child: SizedBox(
              height: 40,
              child: FilterChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(chips[i].$2, textAlign: TextAlign.center),
                ),
                selected: _period == chips[i].$1,
                onSelected: (_) => _onPeriodSelected(chips[i].$1),
              ),
            ),
          )
        else
          SizedBox(
            height: 40,
            child: FilterChip(
              label: Text(chips[i].$2),
              selected: _period == chips[i].$1,
              onSelected: (_) => _onPeriodSelected(chips[i].$1),
            ),
          ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l10n;
    final theme = Theme.of(context);
    final isCustom = _period == DatePeriod.custom;
    final (primary, secondary) = _buildLabels();

    final chips = <(DatePeriod, String)>[
      (DatePeriod.day, l.periodDay),
      (DatePeriod.week, l.periodWeek),
      (DatePeriod.month, l.periodMonth),
      (DatePeriod.year, l.periodYear),
      (DatePeriod.custom, l.periodCustom),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Single row when wide enough; two rows otherwise
        if (constraints.maxWidth >= 600) {
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildNavigation(theme, isCustom, primary, secondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Row(children: _buildChips(chips, expanded: true)),
              ),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: _buildChips(chips, expanded: true)),
            const SizedBox(height: 12),
            _buildNavigation(theme, isCustom, primary, secondary),
          ],
        );
      },
    );
  }
}
