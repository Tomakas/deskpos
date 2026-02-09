import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class DialogNewBill extends ConsumerStatefulWidget {
  const DialogNewBill({super.key});

  @override
  ConsumerState<DialogNewBill> createState() => _DialogNewBillState();
}

class _DialogNewBillState extends ConsumerState<DialogNewBill> {
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
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return AlertDialog(
      title: Text(l.newBillTitle),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _guestsCtrl,
              decoration: InputDecoration(labelText: l.newBillGuests),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              l.newBillSelectTable,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: _buildTableList(company.id),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, NewBillResult(
              tableId: _selectedTableId,
              numberOfGuests: int.tryParse(_guestsCtrl.text) ?? 0,
            ));
          },
          child: Text(l.newBillCreate),
        ),
      ],
    );
  }

  Widget _buildTableList(String companyId) {
    return StreamBuilder<List<SectionModel>>(
      stream: ref.watch(sectionRepositoryProvider).watchAll(companyId),
      builder: (context, sectionSnap) {
        final sections = sectionSnap.data ?? [];
        return StreamBuilder<List<TableModel>>(
          stream: ref.watch(tableRepositoryProvider).watchAll(companyId),
          builder: (context, tableSnap) {
            final tables = tableSnap.data ?? [];
            return ListView(
              children: [
                for (final section in sections) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      section.name,
                      style: Theme.of(context).textTheme.labelMedium,
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
                              child: _selectedTableId == table.id
                                  ? FilledButton(
                                      onPressed: () => setState(() {
                                        _selectedTableId = null;
                                      }),
                                      child: Text(table.name),
                                    )
                                  : OutlinedButton(
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
    );
  }
}

class NewBillResult {
  const NewBillResult({
    this.tableId,
    this.numberOfGuests = 0,
  });

  final String? tableId;
  final int numberOfGuests;
}
