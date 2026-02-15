import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/section_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import 'dialog_customer_search.dart';

class DialogNewBill extends ConsumerStatefulWidget {
  const DialogNewBill({
    super.key,
    this.title,
    this.initialTableId,
    this.initialNumberOfGuests = 1,
  });

  final String? title;
  final String? initialTableId;
  final int initialNumberOfGuests;

  @override
  ConsumerState<DialogNewBill> createState() => _DialogNewBillState();
}

class _DialogNewBillState extends ConsumerState<DialogNewBill> {
  String? _selectedSectionId;
  String? _selectedTableId;
  int _guestCount = 0;
  CustomerModel? _selectedCustomer;
  String? _customerName;

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

    return PosDialogShell(
      title: '${widget.title ?? l.newBillTitle}:',
      titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      maxWidth: 420,
      children: [
        StreamBuilder<List<SectionModel>>(
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
                      // Customer
                      _FormRow(
                        label: '${l.newBillCustomer}:',
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                enabled: false,
                                controller: TextEditingController(
                                  text: _selectedCustomer != null
                                      ? '${_selectedCustomer!.firstName} ${_selectedCustomer!.lastName}'
                                      : _customerName ?? '',
                                ),
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
                                onPressed: () async {
                                  final result = await showCustomerSearchDialogRaw(
                                    context,
                                    ref,
                                    showRemoveButton: _selectedCustomer != null || _customerName != null,
                                  );
                                  if (result is CustomerModel) {
                                    setState(() {
                                      _selectedCustomer = result;
                                      _customerName = null;
                                    });
                                  } else if (result is String) {
                                    setState(() {
                                      _customerName = result;
                                      _selectedCustomer = null;
                                    });
                                  } else if (result != null && result is! CustomerModel) {
                                    // _RemoveCustomer sentinel
                                    setState(() {
                                      _selectedCustomer = null;
                                      _customerName = null;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.search, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Bottom buttons
                      PosDialogActions(
                        actions: [
                          OutlinedButton(
                            style: PosButtonStyles.destructiveOutlined(context),
                            onPressed: () => Navigator.pop(context),
                            child: Text(l.actionCancel.toUpperCase()),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context, NewBillResult(
                                sectionId: _selectedSectionId,
                                tableId: _selectedTableId,
                                numberOfGuests: _guestCount,
                                customerId: _selectedCustomer?.id,
                                customerName: _selectedCustomer != null ? null : _customerName,
                                navigateToSell: false,
                              ));
                            },
                            child: Text(l.newBillSave.toUpperCase()),
                          ),
                          if (widget.title == null)
                            FilledButton(
                              style: PosButtonStyles.confirm(context),
                              onPressed: () {
                                Navigator.pop(context, NewBillResult(
                                  sectionId: _selectedSectionId,
                                  tableId: _selectedTableId,
                                  numberOfGuests: _guestCount,
                                  customerId: _selectedCustomer?.id,
                                  customerName: _selectedCustomer != null ? null : _customerName,
                                  navigateToSell: true,
                                ));
                              },
                              child: Text(l.newBillOrder.toUpperCase()),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
      ],
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
    this.sectionId,
    this.tableId,
    this.customerId,
    this.customerName,
    this.numberOfGuests = 1,
    this.navigateToSell = false,
  });

  final String? sectionId;
  final String? tableId;
  final String? customerId;
  final String? customerName;
  final int numberOfGuests;
  final bool navigateToSell;
}
