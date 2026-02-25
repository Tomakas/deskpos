import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/reservation_status.dart';
import '../../../core/data/models/reservation_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_date_range_selector.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';
import 'dialog_reservation_edit.dart';

class DialogReservationsList extends ConsumerStatefulWidget {
  const DialogReservationsList({super.key});

  @override
  ConsumerState<DialogReservationsList> createState() => _DialogReservationsListState();
}

class _DialogReservationsListState extends ConsumerState<DialogReservationsList> {
  DateTime? _dateFrom;
  DateTime? _dateTo;

  void _onDateRangeChanged(DateTime from, DateTime to, DatePeriod _) {
    setState(() {
      _dateFrom = from;
      _dateTo = to;
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

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final company = ref.watch(currentCompanyProvider);
    final locale = ref.watch(appLocaleProvider).value ?? 'cs';

    if (company == null) return const SizedBox.shrink();

    return PosDialogShell(
      title: l.reservationsTitle,
      titleStyle: theme.textTheme.headlineSmall,
      maxWidth: 800,
      children: [
        PosDateRangeSelector(
          onChanged: _onDateRangeChanged,
          locale: locale,
          l10n: l,
          initialPeriod: DatePeriod.week,
          allowFuture: true,
        ),
        const SizedBox(height: 8),

        // Table
        SizedBox(
          height: 400,
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

                    // Load tables for name lookup
                    return StreamBuilder<List<TableModel>>(
                      stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
                      builder: (context, tablesnap) {
                        final tables = tablesnap.data ?? [];
                        final tableMap = {for (final t in tables) t.id: t.name};

                        return PosTable<ReservationModel>(
                          columns: [
                            PosColumn(label: l.reservationColumnDate, width: 80, cellBuilder: (r) => Text(ref.fmtDate(r.reservationDate))),
                            PosColumn(label: l.reservationColumnTime, width: 50, cellBuilder: (r) => Text(ref.fmtTime(r.reservationDate))),
                            PosColumn(label: l.reservationColumnName, cellBuilder: (r) => Text(r.customerName)),
                            PosColumn(label: l.reservationColumnPhone, width: 100, cellBuilder: (r) => Text(r.customerPhone ?? '')),
                            PosColumn(label: l.reservationColumnPartySize, width: 50, cellBuilder: (r) => Text('${r.partySize}', textAlign: TextAlign.center)),
                            PosColumn(label: l.reservationColumnTable, width: 80, cellBuilder: (r) => Text(r.tableId != null ? (tableMap[r.tableId] ?? '-') : '-')),
                            PosColumn(
                              label: l.reservationColumnStatus,
                              width: 90,
                              numeric: true,
                              cellBuilder: (r) => Text(
                                _statusLabel(context, r.status),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: r.status == ReservationStatus.cancelled
                                      ? theme.colorScheme.error
                                      : r.status == ReservationStatus.confirmed
                                          ? theme.colorScheme.primary
                                          : null,
                                ),
                              ),
                            ),
                          ],
                          items: reservations,
                          onRowTap: (r) => _openEditDialog(r),
                          emptyMessage: l.reservationsEmpty,
                        );
                      },
                    );
                  },
                ),
        ),

        const SizedBox(height: 16),
        PosDialogActions(
          leading: FilledButton.tonalIcon(
            onPressed: _openCreateDialog,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l.reservationNew),
          ),
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
