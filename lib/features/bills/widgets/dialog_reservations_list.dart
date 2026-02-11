import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/data/enums/reservation_status.dart';
import '../../../core/data/models/reservation_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';
import 'dialog_reservation_edit.dart';

class DialogReservationsList extends ConsumerStatefulWidget {
  const DialogReservationsList({super.key});

  @override
  ConsumerState<DialogReservationsList> createState() => _DialogReservationsListState();
}

class _DialogReservationsListState extends ConsumerState<DialogReservationsList> {
  late DateTime _dateFrom;
  late DateTime _dateTo;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateFrom = DateTime(now.year, now.month, now.day);
    _dateTo = _dateFrom.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final initial = isFrom ? _dateFrom : _dateTo;
    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  Future<void> _openCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const DialogReservationEdit(),
    );
    if (result == true) {
      setState(() {}); // triggers stream rebuild
    }
  }

  Future<void> _openEditDialog(ReservationModel reservation) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DialogReservationEdit(reservation: reservation),
    );
    if (result == true) {
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
    final dateFormat = DateFormat('d.M.yyyy', 'cs');
    final timeFormat = DateFormat('HH:mm', 'cs');
    final company = ref.watch(currentCompanyProvider);

    if (company == null) return const SizedBox.shrink();

    return PosDialogShell(
      title: l.reservationsTitle,
      titleStyle: theme.textTheme.headlineSmall,
      maxWidth: 800,
      children: [
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
            const SizedBox(width: 16),
            FilledButton.tonalIcon(
              onPressed: _openCreateDialog,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.reservationNew),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Table
        SizedBox(
          height: 400,
          child: StreamBuilder<List<ReservationModel>>(
            stream: ref.watch(reservationRepositoryProvider).watchByDateRange(
                  company.id,
                  _dateFrom,
                  _dateTo,
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
                      PosColumn(label: l.reservationColumnDate, width: 80, cellBuilder: (r) => Text(dateFormat.format(r.reservationDate))),
                      PosColumn(label: l.reservationColumnTime, width: 50, cellBuilder: (r) => Text(timeFormat.format(r.reservationDate))),
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
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionClose),
          ),
        ),
      ],
    );
  }
}
