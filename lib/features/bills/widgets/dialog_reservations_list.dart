import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/data/enums/reservation_status.dart';
import '../../../core/data/models/reservation_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
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

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.reservationsTitle, style: theme.textTheme.headlineSmall),
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
                  const SizedBox(width: 16),
                  FilledButton.tonalIcon(
                    onPressed: _openCreateDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l.reservationNew),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Header row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Row(
                  children: [
                    SizedBox(width: 80, child: Text(l.reservationColumnDate, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 50, child: Text(l.reservationColumnTime, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                    Expanded(child: Text(l.reservationColumnName, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 100, child: Text(l.reservationColumnPhone, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 50, child: Text(l.reservationColumnPartySize, textAlign: TextAlign.center, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 80, child: Text(l.reservationColumnTable, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                    SizedBox(width: 90, child: Text(l.reservationColumnStatus, textAlign: TextAlign.right, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),

              // Body
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
                    if (reservations.isEmpty) {
                      return Center(child: Text(l.reservationsEmpty, style: theme.textTheme.bodyMedium));
                    }

                    // Load tables for name lookup
                    return StreamBuilder<List<TableModel>>(
                      stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
                      builder: (context, tablesnap) {
                        final tables = tablesnap.data ?? [];
                        final tableMap = {for (final t in tables) t.id: t.name};

                        return ListView.builder(
                          itemCount: reservations.length,
                          itemBuilder: (context, index) {
                            final r = reservations[index];
                            return InkWell(
                              onTap: () => _openEditDialog(r),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3))),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 80, child: Text(dateFormat.format(r.reservationDate))),
                                    SizedBox(width: 50, child: Text(timeFormat.format(r.reservationDate))),
                                    Expanded(child: Text(r.customerName)),
                                    SizedBox(width: 100, child: Text(r.customerPhone ?? '')),
                                    SizedBox(width: 50, child: Text('${r.partySize}', textAlign: TextAlign.center)),
                                    SizedBox(width: 80, child: Text(r.tableId != null ? (tableMap[r.tableId] ?? '-') : '-')),
                                    SizedBox(
                                      width: 90,
                                      child: Text(
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
                                ),
                              ),
                            );
                          },
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
          ),
        ),
      ),
    );
  }
}
