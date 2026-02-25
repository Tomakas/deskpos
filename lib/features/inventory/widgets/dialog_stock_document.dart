import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/purchase_price_strategy.dart';
import '../../../core/data/enums/stock_document_type.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/supplier_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/stock_document_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/unit_type_l10n.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

class DialogStockDocument extends ConsumerStatefulWidget {
  const DialogStockDocument({
    super.key,
    required this.companyId,
    required this.warehouseId,
    required this.type,
  });

  final String companyId;
  final String warehouseId;
  final StockDocumentType type;

  @override
  ConsumerState<DialogStockDocument> createState() =>
      _DialogStockDocumentState();
}

class _DialogStockDocumentState extends ConsumerState<DialogStockDocument> {
  String? _selectedSupplierId;
  PurchasePriceStrategy _documentStrategy = PurchasePriceStrategy.overwrite;
  final _noteController = TextEditingController();
  final _lines = <_LineItem>[];
  bool _saving = false;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay.fromDateTime(now);
  }

  @override
  void dispose() {
    _noteController.dispose();
    for (final line in _lines) {
      line.quantityController.dispose();
      line.priceController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isReceipt = widget.type == StockDocumentType.receipt;

    final title = switch (widget.type) {
      StockDocumentType.receipt => l.inventoryReceipt,
      StockDocumentType.waste => l.inventoryWaste,
      StockDocumentType.correction => l.inventoryCorrection,
      StockDocumentType.inventory => l.inventoryInventory,
    };

    return PosDialogShell(
      title: title,
      maxWidth: 700,
      maxHeight: 700,
      children: [
        // Document date + time
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(ref.fmtDate(_selectedDate)),
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

        // Supplier + price strategy (receipt only)
        if (isReceipt) ...[
          Row(
            children: [
              Expanded(
                child: StreamBuilder<List<SupplierModel>>(
                  stream: ref
                      .watch(supplierRepositoryProvider)
                      .watchAll(widget.companyId),
                  builder: (context, snap) {
                    final suppliers = snap.data ?? [];
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: l.stockDocumentSupplier),
                      initialValue: _selectedSupplierId,
                      items: [
                        DropdownMenuItem<String>(value: null, child: Text('-')),
                        ...suppliers.map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.supplierName),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedSupplierId = v),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<PurchasePriceStrategy>(
                  decoration: InputDecoration(
                    labelText: l.stockDocumentPriceStrategy,
                  ),
                  initialValue: _documentStrategy,
                  items: PurchasePriceStrategy.values.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(_strategyLabel(l, s)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _documentStrategy = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Note field
        TextField(
          controller: _noteController,
          decoration: InputDecoration(labelText: l.stockDocumentNote),
        ),
        const SizedBox(height: 16),

        // Items list
        Expanded(
          child: _lines.isEmpty
              ? Center(child: Text(l.stockDocumentNoItems))
              : ListView.builder(
                  itemCount: _lines.length,
                  itemBuilder: (context, i) {
                    final line = _lines[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                line.itemName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: line.quantityController,
                                decoration: InputDecoration(
                                  labelText: l.stockDocumentQuantity,
                                  isDense: true,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[\d.,]'),
                                  ),
                                ],
                              ),
                            ),
                            if (isReceipt) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: line.priceController,
                                  decoration: InputDecoration(
                                    labelText: l.stockDocumentPrice,
                                    isDense: true,
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[\d.,]'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Per-item strategy override
                              SizedBox(
                                width: 130,
                                child:
                                    DropdownButtonFormField<
                                      PurchasePriceStrategy?
                                    >(
                                      decoration: InputDecoration(
                                        labelText:
                                            l.stockDocumentItemOverrideStrategy,
                                        isDense: true,
                                      ),
                                      isExpanded: true,
                                      initialValue: line.strategyOverride,
                                      items: [
                                        DropdownMenuItem<
                                          PurchasePriceStrategy?
                                        >(value: null, child: Text('-')),
                                        ...PurchasePriceStrategy.values.map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(_strategyLabel(l, s)),
                                          ),
                                        ),
                                      ],
                                      onChanged: (v) => setState(
                                        () => line.strategyOverride = v,
                                      ),
                                    ),
                              ),
                            ],
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() {
                                _lines[i].quantityController.dispose();
                                _lines[i].priceController.dispose();
                                _lines.removeAt(i);
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),

        // Add item button + save
        PosDialogActions(
          leading: OutlinedButton.icon(
            onPressed: () => _addItem(context),
            icon: const Icon(Icons.add),
            label: Text(l.stockDocumentAddItem),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: _lines.isEmpty || _saving
                  ? null
                  : () => _save(context),
              child: Text(l.stockDocumentSave),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _addItem(BuildContext context) async {
    final l = context.l10n;
    final items = await _searchItemDialog(context, l);
    if (items == null) return;

    setState(() {
      for (final item in items) {
        // Avoid duplicates
        if (_lines.any((line) => line.itemId == item.id)) continue;
        _lines.add(
          _LineItem(
            itemId: item.id,
            itemName: item.name,
            quantityController: TextEditingController(text: '1'),
            priceController: TextEditingController(
              text: item.purchasePrice != null
                  ? minorUnitsToInputString(item.purchasePrice!, ref.read(currentCurrencyProvider).value)
                  : '',
            ),
          ),
        );
      }
    });
  }

  Future<List<ItemModel>?> _searchItemDialog(
    BuildContext context,
    AppLocalizations l,
  ) async {
    return showDialog<List<ItemModel>>(
      context: context,
      builder: (context) => _ItemSearchDialog(companyId: widget.companyId),
    );
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

  Future<void> _save(BuildContext context) async {
    setState(() => _saving = true);

    final user = ref.read(activeUserProvider);
    if (user == null) {
      setState(() => _saving = false);
      return;
    }

    final isReceipt = widget.type == StockDocumentType.receipt;

    final lines = _lines.map((line) {
      final qty =
          double.tryParse(line.quantityController.text.replaceAll(',', '.')) ??
          0;
      final priceText = line.priceController.text;
      final currency = ref.read(currentCurrencyProvider).value;
      final price = isReceipt && priceText.isNotEmpty
          ? parseMoney(priceText, currency)
          : null;

      return StockDocumentLine(
        itemId: line.itemId,
        quantity: qty,
        purchasePrice: price?.round(),
        purchasePriceStrategy: line.strategyOverride,
      );
    }).toList();

    final result = await ref
        .read(stockDocumentRepositoryProvider)
        .createDocument(
          companyId: widget.companyId,
          warehouseId: widget.warehouseId,
          userId: user.id,
          type: widget.type,
          documentStrategy: isReceipt ? _documentStrategy : null,
          supplierId: _selectedSupplierId,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          documentDate: _combinedDateTime,
          lines: lines,
        );

    if (!context.mounted) return;
    setState(() => _saving = false);

    if (result is Success) {
      Navigator.pop(context);
    }
  }

  String _strategyLabel(AppLocalizations l, PurchasePriceStrategy strategy) {
    return switch (strategy) {
      PurchasePriceStrategy.overwrite => context.l10n.stockStrategyOverwrite,
      PurchasePriceStrategy.keep => context.l10n.stockStrategyKeep,
      PurchasePriceStrategy.average => context.l10n.stockStrategyAverage,
      PurchasePriceStrategy.weightedAverage =>
        context.l10n.stockStrategyWeightedAverage,
    };
  }
}

class _LineItem {
  _LineItem({
    required this.itemId,
    required this.itemName,
    required this.quantityController,
    required this.priceController,
  });

  final String itemId;
  final String itemName;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  PurchasePriceStrategy? strategyOverride;
}

/// Simple search dialog for stock-tracked items.
class _ItemSearchDialog extends ConsumerStatefulWidget {
  const _ItemSearchDialog({required this.companyId});
  final String companyId;

  @override
  ConsumerState<_ItemSearchDialog> createState() => _ItemSearchDialogState();
}

class _ItemSearchDialogState extends ConsumerState<_ItemSearchDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return PosDialogShell(
      title: l.stockDocumentSearchItem,
      maxWidth: 500,
      maxHeight: 500,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: l.stockDocumentSearchItem,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => _query = v.toLowerCase()),
          autofocus: true,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<ItemModel>>(
            stream: ref
                .watch(itemRepositoryProvider)
                .watchAll(widget.companyId),
            builder: (context, snap) {
              final allItems = snap.data ?? [];
              final items = allItems.where((item) {
                if (!item.isStockTracked) return false;
                if (_query.isEmpty) return true;
                return item.name.toLowerCase().contains(_query) ||
                    (item.sku?.toLowerCase().contains(_query) ?? false);
              }).toList();

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: item.sku != null ? Text(item.sku!) : null,
                    trailing: Text(localizedUnitType(l, item.unit)),
                    onTap: () => Navigator.pop(context, [item]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
