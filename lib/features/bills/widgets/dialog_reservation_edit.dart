import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/reservation_status.dart';
import '../../../core/data/models/reservation_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import 'dialog_customer_search.dart';

class DialogReservationEdit extends ConsumerStatefulWidget {
  const DialogReservationEdit({super.key, this.reservation});
  final ReservationModel? reservation;

  @override
  ConsumerState<DialogReservationEdit> createState() => _DialogReservationEditState();
}

class _DialogReservationEditState extends ConsumerState<DialogReservationEdit> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _partySizeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String? _customerId;
  String? _tableId;
  late ReservationStatus _status;

  bool get _isEdit => widget.reservation != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reservation;
    if (r != null) {
      _nameCtrl.text = r.customerName;
      _phoneCtrl.text = r.customerPhone ?? '';
      _partySizeCtrl.text = r.partySize.toString();
      _notesCtrl.text = r.notes ?? '';
      _selectedDate = r.reservationDate;
      _selectedTime = TimeOfDay.fromDateTime(r.reservationDate);
      _customerId = r.customerId;
      _tableId = r.tableId;
      _status = r.status;
    } else {
      final now = DateTime.now();
      _selectedDate = DateTime(now.year, now.month, now.day, 18, 0);
      _selectedTime = const TimeOfDay(hour: 18, minute: 0);
      _partySizeCtrl.text = '2';
      _status = ReservationStatus.created;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _partySizeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  DateTime get _combinedDateTime => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null && mounted) {
      setState(() => _selectedDate = result);
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (result != null && mounted) {
      setState(() => _selectedTime = result);
    }
  }

  Future<void> _linkCustomer() async {
    final customer = await showCustomerSearchDialog(context, ref);
    if (customer != null && mounted) {
      setState(() {
        _customerId = customer.id;
        _nameCtrl.text = '${customer.firstName} ${customer.lastName}';
        if (customer.phone != null && customer.phone!.isNotEmpty) {
          _phoneCtrl.text = customer.phone!;
        }
      });
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final repo = ref.read(reservationRepositoryProvider);
    final partySize = int.tryParse(_partySizeCtrl.text.trim()) ?? 2;
    final phone = _phoneCtrl.text.trim();
    final notes = _notesCtrl.text.trim();

    if (_isEdit) {
      final updated = widget.reservation!.copyWith(
        customerId: _customerId,
        customerName: name,
        customerPhone: phone.isEmpty ? null : phone,
        reservationDate: _combinedDateTime,
        partySize: partySize,
        tableId: _tableId,
        notes: notes.isEmpty ? null : notes,
        status: _status,
      );
      await repo.update(updated);
    } else {
      final now = DateTime.now();
      final model = ReservationModel(
        id: const Uuid().v7(),
        companyId: company.id,
        customerId: _customerId,
        customerName: name,
        customerPhone: phone.isEmpty ? null : phone,
        reservationDate: _combinedDateTime,
        partySize: partySize,
        tableId: _tableId,
        notes: notes.isEmpty ? null : notes,
        status: _status,
        createdAt: now,
        updatedAt: now,
      );
      await repo.create(model);
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    if (!_isEdit) return;
    final repo = ref.read(reservationRepositoryProvider);
    await repo.delete(widget.reservation!.id);
    if (mounted) Navigator.pop(context, true);
  }

  String _statusLabel(ReservationStatus s) {
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
    final company = ref.watch(currentCompanyProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isEdit ? l.reservationEdit : l.reservationNew,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Customer name
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(labelText: l.reservationCustomerName),
                ),
                const SizedBox(height: 12),

                // Customer phone
                TextField(
                  controller: _phoneCtrl,
                  decoration: InputDecoration(labelText: l.reservationCustomerPhone),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),

                // Link customer button
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _linkCustomer,
                      icon: const Icon(Icons.person_search, size: 18),
                      label: Text(l.reservationLinkCustomer),
                    ),
                    if (_customerId != null) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(l.reservationLinkedCustomer),
                        onDeleted: () => setState(() => _customerId = null),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Date + Time
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(dateFormat.format(_selectedDate)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Party size
                TextField(
                  controller: _partySizeCtrl,
                  decoration: InputDecoration(labelText: l.reservationPartySize),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Table dropdown
                if (company != null)
                  StreamBuilder<List<TableModel>>(
                    stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
                    builder: (context, snap) {
                      final tables = snap.data ?? [];
                      return DropdownButtonFormField<String?>(
                        initialValue: _tableId,
                        decoration: InputDecoration(labelText: l.reservationTable),
                        items: [
                          DropdownMenuItem<String?>(value: null, child: Text('-')),
                          ...tables.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))),
                        ],
                        onChanged: (v) => setState(() => _tableId = v),
                      );
                    },
                  ),
                const SizedBox(height: 12),

                // Notes
                TextField(
                  controller: _notesCtrl,
                  decoration: InputDecoration(labelText: l.reservationNotes),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Status (edit mode only)
                if (_isEdit) ...[
                  Text(l.reservationStatus, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  SegmentedButton<ReservationStatus>(
                    segments: ReservationStatus.values
                        .map((s) => ButtonSegment(value: s, label: Text(_statusLabel(s))))
                        .toList(),
                    selected: {_status},
                    onSelectionChanged: (v) => setState(() => _status = v.first),
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      textStyle: WidgetStatePropertyAll(theme.textTheme.labelSmall),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isEdit)
                      TextButton(
                        onPressed: _delete,
                        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                        child: Text(l.reservationDelete),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.actionCancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _save,
                      child: Text(l.reservationSave),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
