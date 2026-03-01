import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/enums/discount_type.dart';
import '../../../core/data/enums/payment_type.dart';
import '../../../core/data/enums/display_device_type.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/enums/unit_type.dart';
import '../../../core/data/enums/voucher_discount_scope.dart';
import '../../../core/data/enums/voucher_type.dart';
import '../../../core/data/utils/voucher_discount_calculator.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/customer_display_content.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/order_item_model.dart';
import '../../../core/data/models/order_item_modifier_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/unit_type_l10n.dart';
import '../../shared/session_helpers.dart' as helpers;
import 'dialog_customer_search.dart';
import 'dialog_discount.dart';
import 'dialog_merge_bill.dart';
import 'dialog_new_bill.dart';
import 'dialog_payment.dart';
import 'dialog_receipt_preview.dart' show showReceiptPrintDialog;
import 'dialog_split_bill.dart';
import 'dialog_voucher_redeem.dart';
import '../../../core/widgets/void_quantity_dialog.dart';

class DialogBillDetail extends ConsumerStatefulWidget {
  const DialogBillDetail({super.key, required this.billId});
  final String billId;

  @override
  ConsumerState<DialogBillDetail> createState() => _DialogBillDetailState();
}

class _DialogBillDetailState extends ConsumerState<DialogBillDetail> {
  bool _showSummary = false;
  bool _isProcessing = false;
  bool _didShowOnDisplay = false;
  bool _didSendThankYou = false;
  bool _hasCustomerDisplay = false;
  String? _displayCode;
  String? _cachedCustomerId;
  Future<CustomerModel?>? _customerFuture;
  String? _cachedOrderKey;
  Future<List<OrderItemModel>>? _orderItemsFuture;

  // Cached reference for use in dispose() where ref is no longer available.
  late final _displayChannel = ref.read(customerDisplayChannelProvider);

  @override
  void initState() {
    super.initState();
    _checkCustomerDisplay();
  }

  Future<void> _checkCustomerDisplay() async {
    final register = await ref.read(activeRegisterProvider.future);
    if (!mounted || register == null) return;
    final devices = await ref.read(displayDeviceRepositoryProvider)
        .getByParentRegister(register.id);
    if (!mounted) return;
    final customerDisplay = devices
        .where((d) => d.type == DisplayDeviceType.customerDisplay)
        .firstOrNull;
    if (customerDisplay != null) {
      _displayCode = customerDisplay.code;
      await _displayChannel.join('display:${_displayCode!}');
      if (!mounted) return;
      setState(() => _hasCustomerDisplay = true);
    }
  }

  Future<CustomerModel?> _getCustomerFuture(String customerId) {
    if (_cachedCustomerId != customerId || _customerFuture == null) {
      _cachedCustomerId = customerId;
      _customerFuture = ref.read(customerRepositoryProvider)
          .getById(customerId, includeDeleted: true);
    }
    return _customerFuture!;
  }

  Future<List<OrderItemModel>> _getOrderItemsFuture(List<OrderModel> activeOrders) {
    final key = activeOrders.map((o) => o.id).join(',');
    if (_cachedOrderKey != key || _orderItemsFuture == null) {
      _cachedOrderKey = key;
      final orderRepo = ref.read(orderRepositoryProvider);
      _orderItemsFuture = Future.wait(activeOrders.map((o) => orderRepo.getOrderItems(o.id)))
          .then((lists) => lists.expand((l) => l).toList());
    }
    return _orderItemsFuture!;
  }

  @override
  void dispose() {
    if (!_didSendThankYou && _didShowOnDisplay && _displayCode != null) {
      _displayChannel.send(const DisplayIdle().toJson());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return StreamBuilder<BillModel?>(
      stream: ref.watch(billRepositoryProvider).watchById(widget.billId),
      builder: (context, billSnap) {
        final bill = billSnap.data;
        if (bill == null) {
          return const Dialog(
            insetPadding: EdgeInsets.all(12),
            child: SizedBox(
              width: 700,
              height: 500,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          child: SizedBox(
            width: 750,
            height: 520,
            child: Column(
              children: [
                _buildHeader(context, ref, bill, l),
                const Divider(height: 1),
                Expanded(
                  child: Row(
                    children: [
                      // Center: order history
                      Expanded(child: _buildOrderList(context, ref, bill, l)),
                      const VerticalDivider(width: 1),
                      // Right action buttons
                      _buildRightButtons(context, ref, bill, l),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildFooter(context, ref, bill, l),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, BillModel bill, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bill title (table name or takeaway)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: _buildBillTitle(context, ref, bill, l)),
                    if (_hasCustomerDisplay) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _didShowOnDisplay ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () {
                          if (_didShowOnDisplay) {
                            _hideFromDisplay();
                          } else {
                            _showOnDisplay(bill);
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                        tooltip: l.billDetailShowOnDisplay,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                _buildTotalSpentLine(context, ref, bill, l),
              ],
            ),
          ),
          // Dates & customer
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l.billDetailCreatedAt(ref.fmtDateTime(bill.openedAt)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                StreamBuilder<List<OrderModel>>(
                  stream: ref.watch(orderRepositoryProvider).watchByBill(bill.id),
                  builder: (context, snap) {
                    final orders = snap.data ?? [];
                    if (orders.isEmpty) {
                      return Text(
                        l.billDetailNoOrderYet,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    final lastOrder = orders.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
                    return Text(
                      l.billDetailLastOrderAt(ref.fmtDateTime(lastOrder.createdAt)),
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
                const SizedBox(height: 2),
                if (bill.customerId != null) ...[
                  FutureBuilder<CustomerModel?>(
                    future: _getCustomerFuture(bill.customerId!),
                    builder: (context, snap) {
                      final customer = snap.data;
                      if (customer == null) return const SizedBox.shrink();
                      return Text(
                        l.billDetailCustomerName('${customer.firstName} ${customer.lastName}'),
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                  _buildCustomerLoyaltyInfo(context, ref, bill),
                ] else if (bill.customerName != null)
                  Text(
                    l.billDetailCustomerName(bill.customerName!),
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  Text(
                    l.billDetailNoCustomer,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillTitle(BuildContext context, WidgetRef ref, BillModel bill, AppLocalizations l) {
    final billNum = l.billDetailBillNumber(bill.billNumber);

    if (bill.isTakeaway) {
      return Text(
        '$billNum — ${l.billsQuickBill}',
        style: Theme.of(context).textTheme.titleLarge,
      );
    }
    if (bill.tableId == null) {
      return Text(
        '$billNum — ${l.billDetailNoTable}',
        style: Theme.of(context).textTheme.titleLarge,
      );
    }
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<TableModel>>(
      stream: ref.watch(tableRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final tables = snap.data ?? [];
        final table = tables.where((t) => t.id == bill.tableId).firstOrNull;
        final tableName = table?.name ?? '-';
        return Text(
          '$billNum — $tableName',
          style: Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }

  Widget _buildTotalSpentLine(BuildContext context, WidgetRef ref, BillModel bill, AppLocalizations l) {
    return StreamBuilder<int>(
      stream: ref.watch(orderRepositoryProvider).watchByBill(bill.id).asyncMap((orders) async {
        final activeOrders = orders.where((o) =>
            o.status != PrepStatus.voided && !o.isStorno);
        final modRepo = ref.read(orderItemModifierRepositoryProvider);
        int total = 0;
        for (final order in activeOrders) {
          final items = await ref.read(orderRepositoryProvider).getOrderItems(order.id);
          for (final item in items) {
            if (item.status != PrepStatus.voided) {
              total += (item.salePriceAtt * item.quantity).round();
              // Include modifier costs
              final mods = await modRepo.getByOrderItem(item.id);
              for (final mod in mods) {
                total += (mod.unitPrice * mod.quantity * item.quantity).round();
              }
            }
          }
        }
        return total;
      }),
      builder: (context, snap) {
        final undiscountedSubtotal = snap.data ?? 0;
        final hasAnyDiscount = undiscountedSubtotal > 0 && undiscountedSubtotal != bill.totalGross;

        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: l.billDetailTotalSpent(''),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (hasAnyDiscount) ...[
                TextSpan(
                  text: '${ref.moneyValue(undiscountedSubtotal)} ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              TextSpan(
                text: ref.money(bill.totalGross),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerLoyaltyInfo(BuildContext context, WidgetRef ref, BillModel bill) {
    return FutureBuilder<CustomerModel?>(
      future: _getCustomerFuture(bill.customerId!),
      builder: (context, snap) {
        final customer = snap.data;
        if (customer == null) return const SizedBox.shrink();
        final l = context.l10n;
        return Text(
          l.loyaltyCustomerInfo(
            customer.points,
            ref.money(customer.credit),
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  Widget _buildOrderList(BuildContext context, WidgetRef ref, BillModel bill, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header — tap to toggle summary/order history
        InkWell(
          onTap: () => setState(() => _showSummary = !_showSummary),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _showSummary ? l.billDetailSummary : l.billDetailOrderHistory,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Icon(
                  _showSummary ? Icons.list : Icons.functions,
                  size: 22,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        // Order items
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: ref.watch(orderRepositoryProvider).watchByBill(bill.id),
            builder: (context, snap) {
              final orders = snap.data ?? [];
              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    l.billDetailNoOrders,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                );
              }

              if (_showSummary) {
                return _buildSummaryList(context, ref, orders, bill);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: orders.length,
                itemBuilder: (context, index) => _OrderSection(
                  order: orders[index],
                  isEditable: bill.status == BillStatus.opened,
                  isPaid: bill.status == BillStatus.paid,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryList(BuildContext context, WidgetRef ref, List<OrderModel> orders, BillModel bill) {
    if (orders.isEmpty) {
      return const SizedBox.shrink();
    }

    final isCancelled = bill.status == BillStatus.cancelled;
    final activeOrders = isCancelled
        ? orders
        : orders.where((o) =>
            o.status != PrepStatus.voided).toList();

    if (activeOrders.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<OrderItemModel>>(
      future: _getOrderItemsFuture(activeOrders),
      builder: (context, snap) {
        final allItems = isCancelled
            ? (snap.data ?? [])
            : (snap.data ?? []).where((item) =>
                item.status != PrepStatus.voided).toList();

        if (allItems.isEmpty) return const SizedBox.shrink();

        // Group by itemName + salePriceAtt + hasVoucherDiscount
        // When voucher covers only part of an item's qty, split into two entries.
        final grouped = <String, _SummaryItem>{};

        void addToGroup(String key, String name, int unitPrice, double qty, int total, int totalBeforeVoucher, UnitType unit) {
          final existing = grouped[key];
          if (existing != null) {
            grouped[key] = _SummaryItem(
              name: name,
              unitPrice: unitPrice,
              quantity: existing.quantity + qty,
              totalGross: existing.totalGross + total,
              totalBeforeVoucher: existing.totalBeforeVoucher + totalBeforeVoucher,
              unit: unit,
            );
          } else {
            grouped[key] = _SummaryItem(
              name: name,
              unitPrice: unitPrice,
              quantity: qty,
              totalGross: total,
              totalBeforeVoucher: totalBeforeVoucher,
              unit: unit,
            );
          }
        }

        for (final item in allItems) {
          final fullSubtotal = (item.salePriceAtt * item.quantity).round();
          int fullDiscount = 0;
          if (item.discount > 0) {
            if (item.discountType == DiscountType.percent) {
              fullDiscount = (fullSubtotal * item.discount / 10000).round();
            } else {
              fullDiscount = item.discount;
            }
          }
          final itemTotal = fullSubtotal - fullDiscount - item.voucherDiscount;
          final totalBeforeVoucher = fullSubtotal - fullDiscount;
          final hasVoucher = item.voucherDiscount > 0;
          final key = '${item.itemName}|${item.salePriceAtt}|$hasVoucher';
          addToGroup(key, item.itemName, item.salePriceAtt, item.quantity,
              itemTotal, totalBeforeVoucher, item.unit);
        }

        final summaryItems = grouped.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: summaryItems.length,
          itemBuilder: (context, index) {
            final item = summaryItems[index];
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${ref.fmtQty(item.quantity, maxDecimals: 1)} ${localizedUnitType(context.l10n, item.unit)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(flex: 5, child: Text(item.name, style: Theme.of(context).textTheme.bodyMedium)),
                  Expanded(
                    flex: 3,
                    child: item.totalGross != item.totalBeforeVoucher
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                ref.moneyValue(item.totalBeforeVoucher),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ref.money(item.totalGross),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          )
                        : Text(
                            ref.money(item.totalGross),
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRightButtons(BuildContext context, WidgetRef ref, BillModel bill, AppLocalizations l) {
    final isOpened = bill.status == BillStatus.opened;
    final canAssignCustomer = ref.watch(hasPermissionProvider('orders.assign_customer'));
    final canTransfer = ref.watch(hasPermissionProvider('orders.transfer'));
    final canMerge = ref.watch(hasPermissionProvider('orders.merge'));
    final canSplit = ref.watch(hasPermissionProvider('orders.split'));
    final canDiscount = ref.watch(hasPermissionProvider('discounts.apply_bill')) ||
        ref.watch(hasPermissionProvider('discounts.apply_bill_limited'));

    final buttons = <Widget>[
      if (canAssignCustomer)
        Expanded(
          child: _SideButton(
            label: l.billDetailCustomer,
            onPressed: isOpened && !_isProcessing ? () => _selectCustomer(context, ref, bill) : null,
          ),
        ),
      if (canTransfer)
        Expanded(
          child: _SideButton(
            label: l.billDetailMove,
            onPressed: isOpened && !_isProcessing ? () => _moveBill(context, ref, bill) : null,
          ),
        ),
      if (canMerge)
        Expanded(
          child: _SideButton(
            label: l.billDetailMerge,
            onPressed: isOpened && !_isProcessing ? () => _mergeBill(context, ref, bill) : null,
          ),
        ),
      if (canSplit)
        Expanded(
          child: _SideButton(
            label: l.billDetailSplit,
            onPressed: isOpened && !_isProcessing ? () => _splitBill(context, ref, bill) : null,
          ),
        ),
      if (canDiscount)
        Expanded(
          child: _SideButton(
            label: bill.discountAmount > 0 ? l.billDetailRemoveDiscount : l.billDetailDiscount,
            onPressed: isOpened && !_isProcessing
                ? () => bill.discountAmount > 0
                    ? _removeBillDiscount(context, ref, bill)
                    : _applyBillDiscount(context, ref, bill)
                : null,
          ),
        ),
      Expanded(
        child: _SideButton(
          label: bill.voucherId != null ? l.billDetailRemoveVoucher : l.billDetailVoucher,
          onPressed: isOpened && !_isProcessing
              ? () => bill.voucherId != null
                  ? _removeVoucher(context, ref, bill)
                  : _applyVoucher(context, ref, bill)
              : null,
        ),
      ),
    ];

    return SizedBox(
      width: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              if (i > 0) const SizedBox(height: 4),
              buttons[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, BillModel bill, AppLocalizations l) {
    final isClosed = bill.status != BillStatus.opened;
    final isPaid = bill.status == BillStatus.paid;
    final canPrint = isClosed
        ? ref.watch(hasPermissionProvider('printing.reprint'))
        : ref.watch(hasPermissionProvider('printing.receipt'));
    final canRefund = ref.watch(hasPermissionProvider('payments.refund'));
    final canReopen = ref.watch(hasPermissionProvider('orders.reopen'));
    final canVoidBill = ref.watch(hasPermissionProvider('orders.void_bill'));
    final canPay = ref.watch(hasPermissionProvider('payments.accept'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Close
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.actionClose),
              ),
            ),
          ),
          if (canPrint) ...[
            const SizedBox(width: 12),
            // Print receipt
            Expanded(
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: () => showReceiptPrintDialog(context, ref, bill.id),
                  child: Text(l.billDetailPrint),
                ),
              ),
            ),
          ],
          if (canRefund &&
              isPaid &&
              (ref.watch(activeRegisterProvider).value?.allowRefunds ?? true)) ...[
            const SizedBox(width: 12),
            // Refund
            Expanded(
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  style: PosButtonStyles.warningFilled(context),
                  onPressed: !_isProcessing ? () => _refundBill(context, ref, bill, l) : null,
                  child: Text(l.refundButton),
                ),
              ),
            ),
          ],
          if (canReopen && isClosed) ...[
            const SizedBox(width: 12),
            // Reopen bill
            Expanded(
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  style: PosButtonStyles.warningFilled(context),
                  onPressed: !_isProcessing ? () => _reopenBill(context, ref, bill, l) : null,
                  child: Text(l.billDetailReopen),
                ),
              ),
            ),
          ],
          if (canVoidBill && !isClosed) ...[
            const SizedBox(width: 12),
            // Cancel bill
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  style: PosButtonStyles.destructiveOutlined(context),
                  onPressed: !_isProcessing ? () => _cancelBill(context, ref, bill, l) : null,
                  child: Text(l.billDetailCancel),
                ),
              ),
            ),
          ],
          if (canPay && !isClosed) ...[
            const SizedBox(width: 12),
            // Pay
            Expanded(
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  style: PosButtonStyles.confirm(context),
                  onPressed: !_isProcessing ? () => _payBill(context, ref, bill) : null,
                  child: Text(l.billDetailPay),
                ),
              ),
            ),
          ],
          if (!isClosed) ...[
            const SizedBox(width: 12),
            // Order
            Expanded(
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/sell/${bill.id}');
                  },
                  child: Text(l.billDetailOrder),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showOnDisplay(BillModel bill) async {
    // Resolve display code if not cached
    if (_displayCode == null) {
      final register = await ref.read(activeRegisterProvider.future);
      if (!mounted) return;
      if (register == null) return;
      final displayDeviceRepo = ref.read(displayDeviceRepositoryProvider);
      final devices = await displayDeviceRepo.getByParentRegister(register.id);
      if (!mounted) return;
      final customerDisplay = devices
          .where((d) => d.type == DisplayDeviceType.customerDisplay)
          .firstOrNull;
      if (customerDisplay == null) return;
      _displayCode = customerDisplay.code;
      await _displayChannel.join('display:${_displayCode!}');
      if (!mounted) return;
    }

    // Build display items from bill orders
    final orderRepo = ref.read(orderRepositoryProvider);
    final modRepo = ref.read(orderItemModifierRepositoryProvider);
    final items = await orderRepo.getOrderItemsByBill(bill.id);
    if (!mounted) return;
    final activeItems = items.where((i) =>
        i.status != PrepStatus.voided).toList();

    final displayItems = <DisplayItem>[];
    int subtotal = 0;
    for (final item in activeItems) {
      final mods = await modRepo.getByOrderItem(item.id);
      final modTotal = mods.fold<int>(0, (sum, m) => sum + (m.unitPrice * m.quantity).round());
      final effectiveUnitPrice = item.salePriceAtt + modTotal;
      final totalPrice = (effectiveUnitPrice * item.quantity).round();
      subtotal += totalPrice;
      displayItems.add(DisplayItem(
        name: item.itemName,
        quantity: item.quantity,
        unitPrice: effectiveUnitPrice,
        totalPrice: totalPrice,
        notes: item.notes,
        modifiers: mods.map((m) => DisplayModifier(
          name: m.modifierItemName,
          unitPrice: m.unitPrice,
        )).toList(),
      ));
    }

    final content = DisplayItems(
      items: displayItems,
      subtotal: subtotal,
      total: bill.totalGross,
      discountAmount: bill.discountAmount,
    );

    _displayChannel.send(content.toJson());
    setState(() => _didShowOnDisplay = true);
  }

  void _hideFromDisplay() {
    if (_displayCode != null) {
      _displayChannel.send(const DisplayIdle().toJson());
    }
    setState(() => _didShowOnDisplay = false);
  }

  void _sendThankYou(BuildContext context) {
    if (_displayCode == null) return;
    _didSendThankYou = true;
    final l = context.l10n;
    _displayChannel.send(
      DisplayMessage(
        text: l.customerDisplayThankYou,
        messageType: 'success',
        autoClearAfterMs: 10000,
      ).toJson(),
    );
  }

  Future<void> _cancelBill(BuildContext context, WidgetRef ref, BillModel bill, AppLocalizations l) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      // Skip confirmation for empty bills (no orders at all)
      final orders = await ref.read(orderRepositoryProvider).getOrdersByBillIds([bill.id]);
      if (!context.mounted) return;
      if (orders.isNotEmpty) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => PosDialogShell(
            title: '',
            maxWidth: 400,
            scrollable: true,
            bottomActions: PosDialogActions(
              actions: [
                OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
              ],
            ),
            children: [
              Text(l.billDetailConfirmCancel),
              const SizedBox(height: 16),
            ],
          ),
        );
        if (confirmed != true) return;
        if (!mounted) return;
      }

      // Reverse voucher redemption before cancelling (items still active)
      if (bill.voucherId != null) {
        final voucherRepo = ref.read(voucherRepositoryProvider);
        final voucher = await voucherRepo.getById(bill.voucherId!, includeDeleted: true);
        if (voucher != null) {
          int usesToReturn = 1;
          if (voucher.type == VoucherType.discount) {
            // Count uses from items that have voucherDiscount > 0
            final orderRepo = ref.read(orderRepositoryProvider);
            final activeItems = await orderRepo.getOrderItemsByBill(bill.id);
            usesToReturn = activeItems
                .where((i) => i.voucherDiscount > 0 &&
                    i.status != PrepStatus.voided)
                .fold<double>(0, (s, i) => s + i.quantity)
                .ceil();
          }
          if (usesToReturn > 0) {
            await voucherRepo.unredeem(voucher.id, usesToReturn: usesToReturn);
          }
        }
      }

      final repo = ref.read(billRepositoryProvider);
      final result = await repo.cancelBill(bill.id, userId: ref.read(activeUserProvider)?.id);
      if (result is Success) {
        if (context.mounted) Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _reopenBill(BuildContext context, WidgetRef ref, BillModel bill, AppLocalizations l) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => PosDialogShell(
          title: '',
          maxWidth: 400,
          scrollable: true,
          bottomActions: PosDialogActions(
            actions: [
              OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
            ],
          ),
          children: [
            Text(l.billDetailConfirmReopen),
            const SizedBox(height: 16),
          ],
        ),
      );
      if (confirmed != true) return;
      if (!context.mounted) return;

      final repo = ref.read(billRepositoryProvider);
      final result = await repo.reopenBill(bill.id);
      if (result is Success) {
        if (context.mounted) Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _applyBillDiscount(BuildContext context, WidgetRef ref, BillModel bill) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final l = context.l10n;
      final hasUnlimited = ref.read(hasPermissionProvider('discounts.apply_bill'));
      int? maxPercent;
      if (!hasUnlimited) {
        final company = ref.read(currentCompanyProvider);
        if (company != null) {
          final settings = await ref.read(companySettingsRepositoryProvider).getOrCreate(company.id);
          maxPercent = settings.maxBillDiscountPercent;
        }
      }
      if (!context.mounted) return;
      final result = await showDialog<(DiscountType, int)?>(
        context: context,
        builder: (_) => DialogDiscount(
          title: l.discountTitleBill,
          currentDiscount: bill.discountAmount,
          currentDiscountType: bill.discountType ?? DiscountType.absolute,
          referenceAmount: bill.subtotalGross,
          maxPercent: maxPercent,
        ),
      );
      if (result == null) return;
      if (!mounted) return;
      await ref.read(billRepositoryProvider).updateDiscount(
        bill.id,
        result.$1,
        result.$2,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _removeBillDiscount(BuildContext context, WidgetRef ref, BillModel bill) async {
    if (_isProcessing) return;
    final l = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => PosDialogShell(
        title: l.billDetailRemoveDiscount,
        maxWidth: 400,
        scrollable: true,
        bottomActions: PosDialogActions(
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.no)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.yes)),
          ],
        ),
        children: [
          Text(l.billDetailRemoveDiscountConfirm),
          const SizedBox(height: 16),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await ref.read(billRepositoryProvider).updateDiscount(
        bill.id,
        DiscountType.absolute,
        0,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _applyVoucher(BuildContext context, WidgetRef ref, BillModel bill) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final code = await showDialog<String>(
        context: context,
        builder: (_) => const DialogVoucherRedeem(),
      );
      if (code == null || !mounted) return;

      final company = ref.read(currentCompanyProvider);
      if (company == null) return;

      final voucherRepo = ref.read(voucherRepositoryProvider);
      final result = await voucherRepo.validateForBill(code, company.id, bill);
      if (!context.mounted) return;
      if (result is Failure) {
        // Validation failed — show error text in a simple dialog
        final l = context.l10n;
        final errorKey = (result as Failure).message;
        final errorMsg = switch (errorKey) {
          'voucherInvalid' => l.voucherInvalid,
          'voucherExpiredError' => l.voucherExpiredError,
          'voucherAlreadyUsed' => l.voucherAlreadyUsed,
          'voucherMinOrderNotMet' => l.voucherMinOrderNotMet,
          'voucherCustomerMismatch' => l.voucherCustomerMismatch,
          _ => errorKey,
        };
        showDialog(
          context: context,
          builder: (_) => PosDialogShell(
            title: '',
            maxWidth: 400,
            scrollable: true,
            bottomActions: PosDialogActions(
              actions: [
                OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.actionOk)),
              ],
            ),
            children: [
              Text(errorMsg),
              const SizedBox(height: 16),
            ],
          ),
        );
        return;
      }

      final voucher = (result as Success).value;
      // Calculate discount amount based on voucher type
      int discountAmount;
      int usesConsumed = 1;
      if (voucher.type == VoucherType.gift || voucher.type == VoucherType.deposit) {
        // Cap at bill total
        discountAmount = voucher.value.clamp(0, bill.totalGross);
      } else {
        // Discount voucher — scope-aware computation + physical item splitting
        final orderRepo = ref.read(orderRepositoryProvider);
        final modifierRepo = ref.read(orderItemModifierRepositoryProvider);
        final activeItems = await orderRepo.getOrderItemsByBill(bill.id);
        final filtered = activeItems
            .where((i) => i.status != PrepStatus.voided)
            .toList();
        final itemIds = filtered.map((i) => i.id).toList();
        final allMods = await modifierRepo.getByOrderItemIds(itemIds);
        final modsByItem = <String, List<OrderItemModifierModel>>{};
        for (final mod in allMods) {
          modsByItem.putIfAbsent(mod.orderItemId, () => []).add(mod);
        }
        // Build itemId→categoryId map for category scope
        Map<String, String>? itemCategoryMap;
        if (voucher.discountScope == VoucherDiscountScope.category && voucher.categoryId != null) {
          final itemRepo = ref.read(itemRepositoryProvider);
          itemCategoryMap = {};
          final catalogIds = filtered.map((i) => i.itemId).toSet();
          for (final catId in catalogIds) {
            final catalogItem = await itemRepo.getById(catId, includeDeleted: true);
            if (catalogItem?.categoryId != null) {
              itemCategoryMap[catId] = catalogItem!.categoryId!;
            }
          }
        }
        final vResult = VoucherDiscountCalculator.compute(
          voucher: voucher,
          activeItems: filtered,
          modsByItem: modsByItem,
          subtotalGross: bill.subtotalGross,
          itemCategoryMap: itemCategoryMap,
        );
        // Physically split items and apply per-item voucher discounts
        for (final attr in vResult.attributions) {
          await orderRepo.applyVoucherToOrderItem(
            orderItemId: attr.orderItemId,
            coveredQty: attr.coveredQty,
            voucherDiscountAmount: attr.discountAmount,
          );
        }
        // Discount is embedded in items; bill-level voucherDiscountAmount = 0
        discountAmount = 0;
        usesConsumed = vResult.attributions.fold<double>(0, (s, a) => s + a.coveredQty).ceil();
      }

      final billRepo = ref.read(billRepositoryProvider);
      await billRepo.applyVoucher(
        billId: bill.id,
        voucherId: voucher.id,
        voucherDiscountAmount: discountAmount,
      );
      await voucherRepo.redeem(voucher.id, bill.id, usesConsumed: usesConsumed);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _removeVoucher(BuildContext context, WidgetRef ref, BillModel bill) async {
    if (_isProcessing || bill.voucherId == null) return;
    final l = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => PosDialogShell(
        title: l.billDetailRemoveVoucher,
        maxWidth: 400,
        scrollable: true,
        bottomActions: PosDialogActions(
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.no)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.yes)),
          ],
        ),
        children: [
          Text(l.billDetailRemoveVoucherConfirm),
          const SizedBox(height: 16),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final voucherRepo = ref.read(voucherRepositoryProvider);
      final voucher = await voucherRepo.getById(bill.voucherId!, includeDeleted: true);

      if (voucher != null) {
        // Count uses to return
        int usesToReturn = 1;
        if (voucher.type == VoucherType.discount) {
          final orderRepo = ref.read(orderRepositoryProvider);
          final activeItems = await orderRepo.getOrderItemsByBill(bill.id);
          usesToReturn = activeItems
              .where((i) => i.voucherDiscount > 0 &&
                  i.status != PrepStatus.voided)
              .fold<double>(0, (s, i) => s + i.quantity)
              .ceil();
        }

        // Unredeem voucher
        if (usesToReturn > 0) {
          await voucherRepo.unredeem(voucher.id, usesToReturn: usesToReturn);
        }
      }

      // Clear per-item voucher discounts
      final orderRepo = ref.read(orderRepositoryProvider);
      await orderRepo.clearVoucherDiscounts(bill.id);

      // Clear bill-level voucher fields + recalculate totals
      final billRepo = ref.read(billRepositoryProvider);
      await billRepo.removeVoucher(bill.id);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _selectCustomer(BuildContext context, WidgetRef ref, BillModel bill) async {
    final billRepo = ref.read(billRepositoryProvider);
    final result = await showCustomerSearchDialogRaw(
      context,
      ref,
      showRemoveButton: bill.customerId != null || bill.customerName != null,
      currentCustomerName: bill.customerName,
      currentCustomerId: bill.customerId,
    );
    if (result == null) return;
    if (!mounted) return;
    if (result is CustomerModel) {
      await billRepo.updateCustomer(bill.id, result.id, customerName: '${result.firstName} ${result.lastName}');
    } else if (result is String) {
      // Free-text customer name
      await billRepo.updateCustomerName(bill.id, result);
    } else {
      // _RemoveCustomer sentinel
      await billRepo.updateCustomer(bill.id, null);
    }
  }

  Future<void> _moveBill(BuildContext context, WidgetRef ref, BillModel bill) async {
    final l = context.l10n;
    final billRepo = ref.read(billRepositoryProvider);
    final result = await showDialog<NewBillResult>(
      context: context,
      builder: (_) => DialogNewBill(
        title: l.billDetailMoveTitle,
        initialTableId: bill.tableId,
        initialNumberOfGuests: bill.numberOfGuests,
      ),
    );
    if (result == null) return;
    if (!mounted) return;
    await billRepo.moveBill(
      bill.id,
      tableId: result.tableId,
      numberOfGuests: result.numberOfGuests,
    );
  }

  Future<void> _mergeBill(BuildContext context, WidgetRef ref, BillModel bill) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final billRepo = ref.read(billRepositoryProvider);
      final targetBillId = await showDialog<String>(
        context: context,
        builder: (_) => DialogMergeBill(excludeBillId: bill.id),
      );
      if (targetBillId == null || !context.mounted) return;

      final result = await billRepo.mergeBill(bill.id, targetBillId);
      if (result is Success && context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => DialogBillDetail(billId: targetBillId),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _splitBill(BuildContext context, WidgetRef ref, BillModel bill) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final billRepo = ref.read(billRepositoryProvider);
      final tableRepo = ref.read(tableRepositoryProvider);
      final splitResult = await showDialog<SplitBillResult>(
        context: context,
        builder: (_) => DialogSplitBill(billId: bill.id, billNumber: bill.billNumber),
      );
      if (splitResult == null || !context.mounted) return;

      final splitItems = splitResult.items
          .map((e) => (orderItemId: e.orderItemId, moveQuantity: e.moveQuantity))
          .toList();

      final company = ref.read(currentCompanyProvider);
      final user = ref.read(activeUserProvider);
      if (company == null || user == null) return;

      if (splitResult.payImmediately) {
        // Create new bill (same table, 0 guests)
        final register = ref.read(activeRegisterProvider).value;
        final activeSession = ref.read(activeRegisterSessionProvider).value;
        final newBillResult = await billRepo.createBill(
          companyId: company.id,
          userId: user.id,
          currencyId: bill.currencyId,
          tableId: bill.tableId,
          registerId: register?.id,
          registerSessionId: activeSession?.id,
        );
        if (newBillResult is! Success<BillModel> || !mounted) return;
        final newBill = newBillResult.value;

        // Split items to new bill
        await billRepo.splitBill(
          sourceBillId: bill.id,
          targetBillId: newBill.id,
          splitItems: splitItems,
          userId: user.id,
          registerId: register?.id,
        );
        if (!mounted) return;

        // Get updated new bill for payment
        final updatedResult = await billRepo.getById(newBill.id);
        if (updatedResult is! Success<BillModel> || !context.mounted) return;

        // Resolve table name for payment dialog
        String? tableName;
        if (bill.tableId != null) {
          final table = await tableRepo.getById(bill.tableId!);
          tableName = table?.name;
        }
        if (!context.mounted) return;

        // Open payment dialog for new bill
        final splitPaid = await showDialog<bool>(
          context: context,
          builder: (_) => DialogPayment(bill: updatedResult.value, tableName: tableName),
        );
        if (splitPaid == true && context.mounted) {
          _sendThankYou(context);
        }
        // Stay on original bill detail (auto-refreshed via stream)
      } else {
        // Show DialogNewBill for target configuration
        final l = context.l10n;
        final newBillConfig = await showDialog<NewBillResult>(
          context: context,
          builder: (_) => DialogNewBill(
            title: l.splitBillTitle,
            initialTableId: bill.tableId,
            initialNumberOfGuests: 0,
          ),
        );
        if (newBillConfig == null || !context.mounted) return;

        // Create new bill
        final register2 = ref.read(activeRegisterProvider).value;
        final activeSession2 = ref.read(activeRegisterSessionProvider).value;
        final newBillResult = await billRepo.createBill(
          companyId: company.id,
          userId: user.id,
          currencyId: bill.currencyId,
          tableId: newBillConfig.tableId,
          numberOfGuests: newBillConfig.numberOfGuests,
          registerId: register2?.id,
          registerSessionId: activeSession2?.id,
        );
        if (newBillResult is! Success<BillModel> || !mounted) return;

        // Split items to new bill
        await billRepo.splitBill(
          sourceBillId: bill.id,
          targetBillId: newBillResult.value.id,
          splitItems: splitItems,
          userId: user.id,
          registerId: register2?.id,
        );
        // Stay on original bill detail (auto-refreshed via stream)
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _refundBill(BuildContext context, WidgetRef ref, BillModel bill, AppLocalizations l) async {
    if (_isProcessing) return;
    if (helpers.requireActiveSession(context, ref) == null) return;
    setState(() => _isProcessing = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => PosDialogShell(
          title: l.refundTitle,
          maxWidth: 400,
          scrollable: true,
          bottomActions: PosDialogActions(
            actions: [
              OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
            ],
          ),
          children: [
            Text(l.refundConfirmFull),
            const SizedBox(height: 16),
          ],
        ),
      );
      if (confirmed != true) return;
      if (!mounted) return;

      final session = ref.read(activeRegisterSessionProvider).valueOrNull;
      final user = ref.read(activeUserProvider);
      if (session == null || user == null) return;

      final register = ref.read(activeRegisterProvider).value;
      final repo = ref.read(billRepositoryProvider);
      await repo.refundBill(
        billId: bill.id,
        registerSessionId: session.id,
        userId: user.id,
        registerId: register?.id,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _payBill(BuildContext context, WidgetRef ref, BillModel bill) async {
    if (_isProcessing) return;
    if (helpers.requireActiveSession(context, ref) == null) return;
    setState(() => _isProcessing = true);
    try {
      // If remaining is zero (e.g. fully covered by loyalty), record zero cash payment directly
      if (bill.totalGross - bill.paidAmount <= 0) {
        final methods = await ref.read(paymentMethodRepositoryProvider).getAll(bill.companyId);
        final cashMethod = methods.where((m) => m.type == PaymentType.cash).firstOrNull;
        if (cashMethod != null) {
          final register = ref.read(activeRegisterProvider).value;
          final session = ref.read(activeRegisterSessionProvider).valueOrNull;
          await ref.read(billRepositoryProvider).recordPayment(
            companyId: bill.companyId,
            billId: bill.id,
            paymentMethodId: cashMethod.id,
            currencyId: bill.currencyId,
            amount: 0,
            userId: ref.read(activeUserProvider)?.id,
            registerId: register?.id,
            registerSessionId: session?.id,
          );
        }
        if (context.mounted) {
          _sendThankYou(context);
          Navigator.pop(context);
        }
        return;
      }

      String? tableName;
      if (bill.tableId != null) {
        final tableRepo = ref.read(tableRepositoryProvider);
        final table = await tableRepo.getById(bill.tableId!);
        tableName = table?.name;
      }

      if (!context.mounted) return;

      final paid = await showDialog<bool>(
        context: context,
        builder: (_) => DialogPayment(bill: bill, tableName: tableName),
      );
      if (paid == true && context.mounted) {
        _sendThankYou(context);
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Side button for right panel
// ---------------------------------------------------------------------------
class _SideButton extends StatelessWidget {
  const _SideButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: null,
        child: Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order section (shows items inline, with status)
// ---------------------------------------------------------------------------
class _OrderSection extends ConsumerWidget {
  const _OrderSection({required this.order, this.isEditable = false, this.isPaid = false});
  final OrderModel order;
  final bool isEditable;
  final bool isPaid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return StreamBuilder<List<OrderItemModel>>(
      stream: ref.watch(orderRepositoryProvider).watchOrderItems(order.id),
      builder: (context, snap) {
        final items = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Storno order header
            if (order.isStorno)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  children: [
                    Text(
                      l.ordersStornoPrefix,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.stornoSourceOrderId != null) ...[
                      const SizedBox(width: 4),
                      StreamBuilder<List<OrderModel>>(
                        stream: ref.watch(orderRepositoryProvider).watchByBill(order.billId),
                        builder: (context, snap) {
                          final orders = snap.data ?? [];
                          final source = orders.where((o) => o.id == order.stornoSourceOrderId).firstOrNull;
                          if (source == null) return const SizedBox.shrink();
                          return Text(
                            l.ordersStornoRef(source.orderNumber),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.appColors.danger,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            // Order notes (if any)
            if (!order.isStorno && order.notes != null && order.notes!.isNotEmpty)
              InkWell(
                onTap: isEditable ? () => _editOrderNotes(context, ref) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(Icons.notes, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.notes!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            for (final item in items)
              InkWell(
                onTap: isEditable && ref.watch(hasPermissionProvider('orders.edit'))
                    ? () => _editItemNotes(context, ref, item)
                    : (isPaid &&
                            item.status != PrepStatus.voided &&
                            ref.watch(hasPermissionProvider('payments.refund_item')) &&
                            (ref.watch(activeRegisterProvider).value?.allowRefunds ?? true))
                        ? () => _refundItem(context, ref, item)
                        : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: StreamBuilder(
                    stream: ref.watch(orderItemModifierRepositoryProvider).watchByOrderItem(item.id),
                    builder: (context, modSnap) {
                      final mods = modSnap.data ?? [];
                      final modTotal = mods.fold<int>(0, (sum, m) => sum + (m.unitPrice * m.quantity * item.quantity).round());
                      final isVoided = item.status == PrepStatus.voided;
                      final voidedDecoration = isVoided ? TextDecoration.lineThrough : null;
                      final voidedColor = isVoided ? Theme.of(context).colorScheme.onSurfaceVariant : null;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  ref.fmtTime(order.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    decoration: voidedDecoration,
                                    color: voidedColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${ref.fmtQty(item.quantity, maxDecimals: 1)} ${localizedUnitType(context.l10n, item.unit)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    decoration: voidedDecoration,
                                    color: voidedColor,
                                  ),
                                ),
                              ),
                              Expanded(flex: 5, child: Text(item.itemName, overflow: TextOverflow.ellipsis, maxLines: 1, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                decoration: voidedDecoration,
                                color: voidedColor,
                              ))),
                              Expanded(
                                flex: 3,
                                child: () {
                                  final itemSubtotal = (item.salePriceAtt * item.quantity).round() + modTotal;
                                  int itemDiscount = 0;
                                  if (item.discount > 0) {
                                    itemDiscount = item.discountType == DiscountType.percent
                                        ? (itemSubtotal * item.discount / 10000).round()
                                        : item.discount;
                                  }
                                  final totalDiscount = itemDiscount + item.voucherDiscount;
                                  if (totalDiscount > 0 && !isVoided) {
                                    final discountedPrice = itemSubtotal - totalDiscount;
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          ref.moneyValue(itemSubtotal),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            decoration: TextDecoration.lineThrough,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          ref.money(discountedPrice),
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    );
                                  }
                                  return Text(
                                    ref.money(itemSubtotal),
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      decoration: voidedDecoration,
                                      color: voidedColor,
                                    ),
                                  );
                                }(),
                              ),
                              SizedBox(
                                width: 40,
                                child: (item.status == PrepStatus.created ||
                                        item.status == PrepStatus.ready)
                                    ? PopupMenuButton<PrepStatus>(
                                        icon: Icon(Icons.more_vert,
                                            color: item.status.color(context)),
                                        iconSize: 16,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                            minWidth: 40, minHeight: 40),
                                        onSelected: (status) =>
                                            _changeItemStatus(context, ref, item, status),
                                        itemBuilder: (_) =>
                                            _availableTransitions(
                                                item.status, l, context, ref),
                                      )
                                    : Center(
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: item.status.color(context),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          // Item notes
                          if (item.notes != null && item.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 80, bottom: 2),
                              child: Text(
                                item.notes!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          // Order item modifiers
                          if (mods.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 80, bottom: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final mod in mods)
                                    Text(
                                      '+ ${mod.modifierItemName}${mod.unitPrice > 0 ? '  ${ref.money(mod.unitPrice)}' : ''}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _editOrderNotes(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: order.notes);
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => PosDialogShell(
        title: context.l10n.sellNote,
        maxWidth: 380,
        scrollable: true,
        bottomActions: PosDialogActions(
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(context.l10n.actionSave),
            ),
          ],
        ),
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.l10n.sellNote,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
    if (result != null && context.mounted) {
      await ref.read(orderRepositoryProvider).updateOrderNotes(
        order.id,
        result.isEmpty ? null : result,
      );
    }
  }

  Future<void> _editItemNotes(BuildContext context, WidgetRef ref, OrderItemModel item) async {
    final controller = TextEditingController(text: item.notes);
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => PosDialogShell(
        title: item.itemName,
        maxWidth: 380,
        scrollable: true,
        bottomActions: PosDialogActions(
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(context.l10n.actionSave),
            ),
          ],
        ),
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.l10n.sellNote,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (ref.read(hasPermissionProvider('discounts.apply_item')) ||
              ref.read(hasPermissionProvider('discounts.apply_item_limited')))
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _editItemDiscount(context, ref, item);
                },
                child: Text(context.l10n.billDetailDiscount),
              ),
            ),
          if (ref.read(hasPermissionProvider('orders.void_item'))) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                style: PosButtonStyles.destructiveOutlined(context),
                onPressed: () {
                  Navigator.pop(context);
                  _voidSingleItem(context, ref, item);
                },
                child: Text(context.l10n.orderItemStorno),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
    if (result != null && context.mounted) {
      await ref.read(orderRepositoryProvider).updateItemNotes(
        item.id,
        result.isEmpty ? null : result,
      );
    }
  }

  Future<void> _voidSingleItem(BuildContext context, WidgetRef ref, OrderItemModel item) async {
    final l = context.l10n;
    double? voidQty;

    if (item.quantity > 1) {
      // Show quantity selection dialog (also serves as confirmation)
      final result = await showDialog<double>(
        context: context,
        builder: (_) => VoidQuantityDialog(
          itemName: item.itemName,
          maxQuantity: item.quantity,
          unit: item.unit,
        ),
      );
      if (result == null || !context.mounted) return;
      voidQty = result;
    } else {
      // Simple confirmation for qty <= 1
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => PosDialogShell(
          title: '',
          maxWidth: 400,
          scrollable: true,
          bottomActions: PosDialogActions(
            actions: [
              OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
              FilledButton(style: PosButtonStyles.destructiveFilled(context), onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
            ],
          ),
          children: [
            Text(l.orderItemStornoConfirm),
            const SizedBox(height: 16),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }

    final user = ref.read(activeUserProvider);
    if (user == null) return;

    // Generate storno order number
    final session = ref.read(activeRegisterSessionProvider).valueOrNull;
    final registerModel = ref.read(activeRegisterProvider).value;
    final regNum = registerModel?.registerNumber ?? 0;
    final orderRepo = ref.read(orderRepositoryProvider);
    final billRepo = ref.read(billRepositoryProvider);
    String stornoNumber = 'X$regNum-0000';
    if (session != null) {
      final sessionRepo = ref.read(registerSessionRepositoryProvider);
      final counter = await sessionRepo.incrementOrderCounter(session.id);
      if (!context.mounted) return;
      if (counter is Success<int>) {
        stornoNumber = 'X$regNum-${counter.value.toString().padLeft(4, '0')}';
      }
    }

    // Full void when voidQty equals maxQty, partial otherwise
    final isFullVoid = voidQty == null || voidQty >= item.quantity;
    await orderRepo.voidItem(
      orderId: order.id,
      orderItemId: item.id,
      companyId: order.companyId,
      userId: user.id,
      stornoOrderNumber: stornoNumber,
      registerId: registerModel?.id,
      voidQuantity: isFullVoid ? null : voidQty,
    );
    await billRepo.updateTotals(order.billId);
  }

  Future<void> _editItemDiscount(BuildContext context, WidgetRef ref, OrderItemModel item) async {
    final hasUnlimited = ref.read(hasPermissionProvider('discounts.apply_item'));
    int? maxPercent;
    if (!hasUnlimited) {
      final company = ref.read(currentCompanyProvider);
      if (company != null) {
        final settings = await ref.read(companySettingsRepositoryProvider).getOrCreate(company.id);
        maxPercent = settings.maxItemDiscountPercent;
      }
    }
    if (!context.mounted) return;
    final referenceAmount = (item.salePriceAtt * item.quantity).round();
    final result = await showDialog<(DiscountType, int)?>(
      context: context,
      builder: (_) => DialogDiscount(
        title: context.l10n.discountTitleItem,
        currentDiscount: item.discount,
        currentDiscountType: item.discountType ?? DiscountType.absolute,
        referenceAmount: referenceAmount,
        maxPercent: maxPercent,
      ),
    );
    if (result == null) return;
    if (!context.mounted) return;
    final orderRepo = ref.read(orderRepositoryProvider);
    await orderRepo.updateItemDiscount(item.id, result.$1, result.$2);
    // Recalc bill totals
    final billId = order.billId;
    await ref.read(billRepositoryProvider).updateTotals(billId);
  }

  Future<void> _refundItem(BuildContext context, WidgetRef ref, OrderItemModel item) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => PosDialogShell(
        title: l.refundTitle,
        maxWidth: 400,
        scrollable: true,
        bottomActions: PosDialogActions(
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
          ],
        ),
        children: [
          Text(l.refundConfirmItem),
          const SizedBox(height: 16),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final session = ref.read(activeRegisterSessionProvider).valueOrNull;
    final user = ref.read(activeUserProvider);
    if (session == null || user == null) return;

    await ref.read(billRepositoryProvider).refundItem(
      billId: order.billId,
      orderItemId: item.id,
      registerSessionId: session.id,
      userId: user.id,
    );
  }

  void _changeItemStatus(
      BuildContext context, WidgetRef ref, OrderItemModel item, PrepStatus status) {
    if (status == PrepStatus.voided) {
      _voidSingleItem(context, ref, item);
      return;
    }
    final repo = ref.read(orderRepositoryProvider);
    repo.updateItemStatus(item.id, order.id, status);
  }

  List<PopupMenuEntry<PrepStatus>> _availableTransitions(
      PrepStatus current, AppLocalizations l, BuildContext context, WidgetRef ref) {
    PopupMenuItem<PrepStatus> transition(PrepStatus status, String label) =>
        PopupMenuItem(
          value: status,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_right, size: 18, color: status.color(context)),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: status.color(context))),
            ],
          ),
        );
    PopupMenuItem<PrepStatus> voidItem() => PopupMenuItem(
          value: PrepStatus.voided,
          child: Text(l.orderItemStorno,
              style: TextStyle(color: context.appColors.danger)),
        );
    final canVoidItem = ref.read(hasPermissionProvider('orders.void_item'));
    switch (current) {
      case PrepStatus.created:
        return [
          transition(PrepStatus.ready, l.prepStatusReady),
          if (canVoidItem) voidItem(),
        ];
      case PrepStatus.ready:
        return [
          transition(PrepStatus.delivered, l.prepStatusDelivered),
          if (canVoidItem) voidItem(),
        ];
      default:
        return [];
    }
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.totalGross,
    int? totalBeforeVoucher,
    required this.unit,
  }) : totalBeforeVoucher = totalBeforeVoucher ?? totalGross;
  final String name;
  final int unitPrice;
  final double quantity;
  final int totalGross;
  final int totalBeforeVoucher;
  final UnitType unit;
}
