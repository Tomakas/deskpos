import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

enum _BillType { takeaway, table, noTable }

class DialogNewBill extends ConsumerStatefulWidget {
  const DialogNewBill({super.key});

  @override
  ConsumerState<DialogNewBill> createState() => _DialogNewBillState();
}

class _DialogNewBillState extends ConsumerState<DialogNewBill> {
  _BillType? _billType;
  String? _selectedTableId;
  final _guestsCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    _guestsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (_billType == null) {
      return _buildTypeSelection(l);
    }

    if (_billType == _BillType.table && _selectedTableId == null) {
      return _buildTableSelection(l);
    }

    return _buildGuestsAndConfirm(l);
  }

  Widget _buildTypeSelection(dynamic l) {
    return AlertDialog(
      title: Text(l.newBillTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 52,
              child: FilledButton.tonal(
                onPressed: () {
                  // Takeaway: create immediately, no guests needed
                  Navigator.pop(context, _NewBillResult(
                    isTakeaway: true,
                    tableId: null,
                    numberOfGuests: 0,
                  ));
                },
                child: Text(l.newBillTakeaway),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () => setState(() => _billType = _BillType.table),
                child: Text(l.newBillTable),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => setState(() => _billType = _BillType.noTable),
                child: Text(l.newBillNoTable),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
      ],
    );
  }

  Widget _buildTableSelection(dynamic l) {
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return AlertDialog(
      title: Text(l.newBillSelectTable),
      content: SizedBox(
        width: 400,
        height: 400,
        child: StreamBuilder<List<SectionModel>>(
          stream: ref.watch(sectionRepositoryProvider).watchAll(company.id),
          builder: (context, sectionSnap) {
            final sections = sectionSnap.data ?? [];
            return StreamBuilder<List<TableModel>>(
              stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
              builder: (context, tableSnap) {
                final tables = tableSnap.data ?? [];
                return ListView(
                  children: [
                    for (final section in sections) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          section.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tables
                            .where((t) => t.sectionId == section.id && t.isActive)
                            .map((table) => SizedBox(
                                  width: 110,
                                  height: 44,
                                  child: OutlinedButton(
                                    onPressed: () => setState(() {
                                      _selectedTableId = table.id;
                                    }),
                                    child: Text(table.name),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _billType = null),
          child: Text(l.wizardBack),
        ),
      ],
    );
  }

  Widget _buildGuestsAndConfirm(dynamic l) {
    return AlertDialog(
      title: Text(l.newBillTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_billType != _BillType.takeaway)
              TextField(
                controller: _guestsCtrl,
                decoration: InputDecoration(labelText: l.newBillGuests),
                keyboardType: TextInputType.number,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() {
            if (_billType == _BillType.table) {
              _selectedTableId = null;
            } else {
              _billType = null;
            }
          }),
          child: Text(l.wizardBack),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, _NewBillResult(
              isTakeaway: _billType == _BillType.takeaway,
              tableId: _selectedTableId,
              numberOfGuests: int.tryParse(_guestsCtrl.text) ?? 0,
            ));
          },
          child: Text(l.newBillCreate),
        ),
      ],
    );
  }
}

class NewBillResult {
  const NewBillResult({
    required this.isTakeaway,
    this.tableId,
    this.numberOfGuests = 0,
  });

  final bool isTakeaway;
  final String? tableId;
  final int numberOfGuests;
}

typedef _NewBillResult = NewBillResult;
