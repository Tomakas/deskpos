import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class DialogNewBill extends ConsumerStatefulWidget {
  const DialogNewBill({
    super.key,
    this.initialTableId,
    this.initialNumberOfGuests = 0,
  });

  final String? initialTableId;
  final int initialNumberOfGuests;

  @override
  ConsumerState<DialogNewBill> createState() => _DialogNewBillState();
}

class _DialogNewBillState extends ConsumerState<DialogNewBill> {
  String? _selectedSectionId;
  String? _selectedTableId;
  int _guestCount = 0;

  @override
  void initState() {
    super.initState();
    _guestCount = widget.initialNumberOfGuests;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StreamBuilder<List<SectionModel>>(
            stream: ref.watch(sectionRepositoryProvider).watchAll(company.id),
            builder: (context, sectionSnap) {
              final sections = sectionSnap.data ?? [];
              if (_selectedSectionId == null && sections.isNotEmpty) {
                if (widget.initialTableId != null) {
                  // Will resolve once tables load below
                } else {
                  final defaultSection = sections.where((s) => s.isDefault).firstOrNull;
                  if (defaultSection != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _selectedSectionId == null) {
                        setState(() => _selectedSectionId = defaultSection.id);
                      }
                    });
                  }
                }
              }
              return StreamBuilder<List<TableModel>>(
                stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
                builder: (context, tableSnap) {
                  final allTables = tableSnap.data ?? [];
                  if (_selectedSectionId == null && widget.initialTableId != null && allTables.isNotEmpty) {
                    final initTable = allTables.where((t) => t.id == widget.initialTableId).firstOrNull;
                    if (initTable != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _selectedSectionId == null) {
                          setState(() {
                            _selectedSectionId = initTable.sectionId;
                            _selectedTableId = initTable.id;
                          });
                        }
                      });
                    }
                  }
                  final filteredTables = _selectedSectionId != null
                      ? allTables.where((t) => t.sectionId == _selectedSectionId && t.isActive).toList()
                      : <TableModel>[];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        '${l.newBillTitle}:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Section dropdown
                      _FormRow(
                        label: '${l.newBillSelectSection}:',
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSectionId,
                              isExpanded: true,
                              isDense: true,
                              items: sections.map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSectionId = value;
                                  _selectedTableId = null;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Table dropdown
                      _FormRow(
                        label: '${l.newBillSelectTable}:',
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedTableId,
                              isExpanded: true,
                              isDense: true,
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(l.newBillNoTable),
                                ),
                                ...filteredTables.map((t) => DropdownMenuItem<String?>(
                                  value: t.id,
                                  child: Text(t.name),
                                )),
                              ],
                              onChanged: _selectedSectionId == null
                                  ? null
                                  : (value) {
                                      setState(() => _selectedTableId = value);
                                    },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Guest count stepper
                      _FormRow(
                        label: '${l.newBillGuests}:',
                        child: Row(
                          children: [
                            Expanded(
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: Text(
                                  '$_guestCount',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: IconButton.filled(
                                onPressed: () => setState(() => _guestCount++),
                                icon: const Icon(Icons.add, size: 20),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: IconButton.filled(
                                onPressed: _guestCount > 0
                                    ? () => setState(() => _guestCount--)
                                    : null,
                                icon: const Icon(Icons.remove, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Customer (disabled)
                      _FormRow(
                        label: '${l.newBillCustomer}:',
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: IconButton(
                                onPressed: null,
                                icon: const Icon(Icons.search, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Bottom buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(l.actionCancel.toUpperCase()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.pop(context, NewBillResult(
                                    tableId: _selectedTableId,
                                    numberOfGuests: _guestCount,
                                    navigateToSell: false,
                                  ));
                                },
                                child: Text(l.newBillSave.toUpperCase()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                ),
                                onPressed: () {
                                  Navigator.pop(context, NewBillResult(
                                    tableId: _selectedTableId,
                                    numberOfGuests: _guestCount,
                                    navigateToSell: true,
                                  ));
                                },
                                child: Text(l.newBillOrder.toUpperCase()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class NewBillResult {
  const NewBillResult({
    this.tableId,
    this.numberOfGuests = 0,
    this.navigateToSell = false,
  });

  final String? tableId;
  final int numberOfGuests;
  final bool navigateToSell;
}
