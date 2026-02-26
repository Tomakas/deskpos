import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/reservation_status.dart';
import '../../../core/data/models/reservation_model.dart';
import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_date_range_selector.dart';
import '../../../core/widgets/pos_table.dart';
import '../widgets/dialog_reservation_edit.dart';
import '../widgets/reservation_bar_chart.dart';
import '../widgets/reservation_gantt_chart.dart';

class ScreenReservations extends ConsumerStatefulWidget {
  const ScreenReservations({super.key});

  @override
  ConsumerState<ScreenReservations> createState() => _ScreenReservationsState();
}

class _ScreenReservationsState extends ConsumerState<ScreenReservations> {
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _showChart = false;
  DatePeriod _currentPeriod = DatePeriod.week;
  String? _selectedSectionId; // null = "All"

  void _onDateRangeChanged(DateTime from, DateTime to, DatePeriod period) {
    setState(() {
      _dateFrom = from;
      _dateTo = to;
      _currentPeriod = period;
    });
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const DialogReservationEdit(),
    );
    if (result == true && mounted) {
      setState(() {}); // triggers stream rebuild
    }
  }

  Future<void> _openEditDialog(ReservationModel reservation) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DialogReservationEdit(reservation: reservation),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Color _statusColor(ReservationStatus s, ThemeData theme, AppColorsExtension appColors) {
    switch (s) {
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

  String _statusLabel(BuildContext context, ReservationStatus s) {
    final l = context.l10n;
    switch (s) {
      case ReservationStatus.created:
        return l.reservationStatusCreated;
      case ReservationStatus.confirmed:
        return l.reservationStatusConfirmed;
      case ReservationStatus.seated:
        return l.reservationStatusSeated;
      case ReservationStatus.cancelled:
        return l.reservationStatusCancelled;
    }
  }

  bool get _useGantt {
    if (_currentPeriod == DatePeriod.day) return true;
    if (_currentPeriod == DatePeriod.week) return true;
    if (_currentPeriod == DatePeriod.month) return true;
    if (_currentPeriod == DatePeriod.year) return false;
    // custom
    if (_dateFrom != null && _dateTo != null) {
      return _dateTo!.difference(_dateFrom!).inDays <= 31;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final company = ref.watch(currentCompanyProvider);
    final locale = ref.watch(appLocaleProvider).value ?? 'cs';

    if (company == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.reservationsTitle),
      ),
      body: StreamBuilder<List<SectionModel>>(
        stream: ref.watch(sectionRepositoryProvider).watchAll(company.id),
        builder: (context, sectionSnap) {
          final sections = (sectionSnap.data ?? [])
              .where((s) => s.isActive)
              .toList();

          // Auto-select first section
          if (sections.isNotEmpty &&
              (_selectedSectionId == null ||
                  !sections.any((s) => s.id == _selectedSectionId))) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _selectedSectionId = sections.first.id);
            });
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: PosDateRangeSelector(
                  onChanged: _onDateRangeChanged,
                  locale: locale,
                  l10n: l,
                  initialPeriod: DatePeriod.week,
                  allowFuture: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(
                      height: 40,
                      child: _showChart
                          ? OutlinedButton(
                              onPressed: () => setState(() => _showChart = false),
                              child: const Icon(Icons.table_rows_outlined, size: 20),
                            )
                          : FilledButton.tonal(
                              onPressed: null,
                              child: const Icon(Icons.table_rows_outlined, size: 20),
                            ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      child: _showChart
                          ? FilledButton.tonal(
                              onPressed: null,
                              child: const Icon(Icons.bar_chart, size: 20),
                            )
                          : OutlinedButton(
                              onPressed: () => setState(() => _showChart = true),
                              child: const Icon(Icons.bar_chart, size: 20),
                            ),
                    ),
                    const SizedBox(width: 16),
                    for (final section in sections) ...[
                      if (section != sections.first) const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: FilterChip(
                            label: SizedBox(
                              width: double.infinity,
                              child: Text(section.name, textAlign: TextAlign.center),
                            ),
                            selected: _selectedSectionId == section.id,
                            onSelected: (_) => setState(() => _selectedSectionId = section.id),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilledButton.icon(
                          onPressed: _openCreateDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(
                            l.reservationNew,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _dateFrom == null || _dateTo == null
                    ? const SizedBox.shrink()
                    : StreamBuilder<List<ReservationModel>>(
                        stream: ref.watch(reservationRepositoryProvider).watchByDateRange(
                              company.id,
                              _dateFrom!,
                              _dateTo!,
                            ),
                        builder: (context, snap) {
                          final reservations = snap.data ?? [];

                          return StreamBuilder<List<TableModel>>(
                            stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
                            builder: (context, tablesnap) {
                              final tables = tablesnap.data ?? [];

                              // Filter tables by selected section
                              final sectionTables = _selectedSectionId != null
                                  ? tables.where((t) => t.sectionId == _selectedSectionId && t.isActive).toList()
                                  : tables.where((t) => t.isActive).toList();
                              final sectionTableIds = sectionTables.map((t) => t.id).toSet();
                              final sectionReservations = reservations.where((r) =>
                                  r.tableId == null || sectionTableIds.contains(r.tableId)).toList();

                              if (!_showChart) {
                                final tableMap = {for (final t in sectionTables) t.id: t.name};
                                return PosTable<ReservationModel>(
                                  columns: [
                                    PosColumn(label: l.reservationColumnDate, flex: 2, cellBuilder: (r) => Text(ref.fmtDate(r.reservationDate))),
                                    PosColumn(label: l.reservationColumnTime, flex: 1, cellBuilder: (r) => Text(ref.fmtTime(r.reservationDate))),
                                    PosColumn(label: l.reservationColumnName, flex: 3, cellBuilder: (r) => Text(r.customerName)),
                                    PosColumn(label: l.reservationColumnPhone, flex: 2, cellBuilder: (r) => Text(r.customerPhone ?? '')),
                                    PosColumn(label: l.reservationColumnPartySize, flex: 1, cellBuilder: (r) => Text('${r.partySize}', textAlign: TextAlign.center)),
                                    PosColumn(label: l.reservationColumnTable, flex: 2, cellBuilder: (r) => Text(r.tableId != null ? (tableMap[r.tableId] ?? '-') : '-')),
                                    PosColumn(
                                      label: l.reservationColumnStatus,
                                      flex: 2,
                                      numeric: true,
                                      cellBuilder: (r) => Text(
                                        _statusLabel(context, r.status),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: _statusColor(r.status, theme, context.appColors),
                                        ),
                                      ),
                                    ),
                                  ],
                                  items: sectionReservations,
                                  onRowTap: (r) => _openEditDialog(r),
                                  emptyMessage: l.reservationsEmpty,
                                );
                              }

                              // Chart mode
                              return Expanded(
                                child: _useGantt
                                    ? ReservationGanttChart(
                                        reservations: sectionReservations,
                                        tables: sectionTables,
                                        dateFrom: _dateFrom!,
                                        dateTo: _dateTo!,
                                        onReservationTap: _openEditDialog,
                                      )
                                    : ReservationBarChart(
                                        reservations: sectionReservations,
                                        period: _currentPeriod,
                                        dateFrom: _dateFrom!,
                                        dateTo: _dateTo!,
                                      ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
