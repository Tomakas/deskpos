import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/data/enums/bill_status.dart';
import '../../../core/data/enums/discount_type.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/enums/voucher_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/order_item_model.dart';
import '../../../core/data/models/order_model.dart';
import '../../../core/data/models/table_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import 'dialog_customer_search.dart';
import 'dialog_discount.dart';
import 'dialog_loyalty_redeem.dart';
import 'dialog_merge_bill.dart';
import 'dialog_new_bill.dart';
import 'dialog_payment.dart';
import 'dialog_receipt_preview.dart' show showReceiptPrintDialog;
import 'dialog_split_bill.dart';
import 'dialog_voucher_redeem.dart';

class DialogBillDetail extends ConsumerStatefulWidget {
  const DialogBillDetail({super.key, required this.billId});
  final String billId;

  @override
  ConsumerState<DialogBillDetail> createState() => _DialogBillDetailState();
}

class _DialogBillDetailState extends ConsumerState<DialogBillDetail> {
  bool _showSummary = false;
  bool _didShowOnDisplay = false;

  @override
  void dispose() {
    if (_didShowOnDisplay) {
      final registerId = ref.read(activeRegisterProvider).value?.id;
      if (registerId != null) {
        ref.read(registerRepositoryProvider).setActiveBill(registerId, null);
      }
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
            child: SizedBox(
              width: 700,
              height: 500,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Dialog(
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

  Widget _buildHeader(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    final dateFormat = DateFormat('d.M.yyyy  HH:mm', 'cs');

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
                _buildBillTitle(context, ref, bill, l),
                const SizedBox(height: 2),
                _buildTotalSpentLine(context, ref, bill, l),
                if (bill.customerId != null)
                  _buildCustomerLoyaltyInfo(context, ref, bill),
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
                  l.billDetailCreatedAt(dateFormat.format(bill.openedAt)),
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
                      l.billDetailLastOrderAt(dateFormat.format(lastOrder.createdAt)),
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
                const SizedBox(height: 2),
                if (bill.customerId != null)
                  FutureBuilder<CustomerModel?>(
                    future: ref.watch(customerRepositoryProvider).getById(bill.customerId!),
                    builder: (context, snap) {
                      final customer = snap.data;
                      if (customer == null) return const SizedBox.shrink();
                      return Text(
                        l.billDetailCustomerName('${customer.firstName} ${customer.lastName}'),
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  )
                else if (bill.customerName != null)
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

  Widget _buildBillTitle(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
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

  Widget _buildTotalSpentLine(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    return StreamBuilder<int>(
      stream: ref.watch(orderRepositoryProvider).watchByBill(bill.id).asyncMap((orders) async {
        final activeOrders = orders.where((o) =>
            o.status != PrepStatus.cancelled && o.status != PrepStatus.voided && !o.isStorno);
        int total = 0;
        for (final order in activeOrders) {
          final items = await ref.read(orderRepositoryProvider).getOrderItems(order.id);
          for (final item in items) {
            if (item.status != PrepStatus.cancelled && item.status != PrepStatus.voided) {
              total += (item.salePriceAtt * item.quantity).round();
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
                  text: '${undiscountedSubtotal ~/ 100} ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              TextSpan(
                text: '${bill.totalGross ~/ 100},- Kč',
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
      future: ref.watch(customerRepositoryProvider).getById(bill.customerId!),
      builder: (context, snap) {
        final customer = snap.data;
        if (customer == null) return const SizedBox.shrink();
        final l = context.l10n;
        return Text(
          l.loyaltyCustomerInfo(
            customer.points,
            (customer.credit / 100).toStringAsFixed(2).replaceAll('.', ','),
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  Widget _buildOrderList(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
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
            o.status != PrepStatus.cancelled && o.status != PrepStatus.voided).toList();

    if (activeOrders.isEmpty) {
      return const SizedBox.shrink();
    }

    final orderRepo = ref.watch(orderRepositoryProvider);

    return FutureBuilder<List<OrderItemModel>>(
      future: Future.wait(activeOrders.map((o) => orderRepo.getOrderItems(o.id)))
          .then((lists) => lists.expand((l) => l).toList()),
      builder: (context, snap) {
        final allItems = isCancelled
            ? (snap.data ?? [])
            : (snap.data ?? []).where((item) =>
                item.status != PrepStatus.cancelled && item.status != PrepStatus.voided).toList();

        if (allItems.isEmpty) return const SizedBox.shrink();

        // Group by itemName + salePriceAtt
        final grouped = <String, _SummaryItem>{};
        for (final item in allItems) {
          final key = '${item.itemName}|${item.salePriceAtt}';
          final itemSubtotal = (item.salePriceAtt * item.quantity).round();
          int itemDiscount = 0;
          if (item.discount > 0) {
            if (item.discountType == DiscountType.percent) {
              itemDiscount = (itemSubtotal * item.discount / 10000).round();
            } else {
              itemDiscount = item.discount;
            }
          }
          final itemTotal = itemSubtotal - itemDiscount;
          final existing = grouped[key];
          if (existing != null) {
            grouped[key] = _SummaryItem(
              name: item.itemName,
              unitPrice: item.salePriceAtt,
              quantity: existing.quantity + item.quantity,
              totalGross: existing.totalGross + itemTotal,
            );
          } else {
            grouped[key] = _SummaryItem(
              name: item.itemName,
              unitPrice: item.salePriceAtt,
              quantity: item.quantity,
              totalGross: itemTotal,
            );
          }
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
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)} ks',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(child: Text(item.name, style: Theme.of(context).textTheme.bodyMedium)),
                  SizedBox(
                    width: 100,
                    child: Text(
                      '${item.totalGross ~/ 100} Kč',
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

  Widget _buildRightButtons(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    final isOpened = bill.status == BillStatus.opened;
    return SizedBox(
      width: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            _SideButton(
              label: l.billDetailCustomer,
              onPressed: isOpened ? () => _selectCustomer(context, ref, bill) : null,
            ),
            const SizedBox(height: 4),
            _SideButton(
              label: l.billDetailMove,
              onPressed: isOpened ? () => _moveBill(context, ref, bill) : null,
            ),
            const SizedBox(height: 4),
            _SideButton(
              label: l.billDetailMerge,
              onPressed: isOpened ? () => _mergeBill(context, ref, bill) : null,
            ),
            const SizedBox(height: 4),
            _SideButton(
              label: l.billDetailSplit,
              onPressed: isOpened ? () => _splitBill(context, ref, bill) : null,
            ),
            const SizedBox(height: 4),
            _SideButton(
              label: l.billDetailDiscount,
              onPressed: isOpened ? () => _applyBillDiscount(context, ref, bill) : null,
            ),
            const SizedBox(height: 4),
            _SideButton(
              label: l.loyaltyRedeem,
              onPressed: isOpened && bill.customerId != null
                  ? () => _redeemLoyalty(context, ref, bill)
                  : null,
            ),
            const SizedBox(height: 4),
            _SideButton(
              label: l.billDetailVoucher,
              onPressed: isOpened ? () => _applyVoucher(context, ref, bill) : null,
            ),
            const SizedBox(height: 4),
            Builder(
              builder: (context) {
                final register = ref.watch(activeRegisterProvider).value;
                final isOnDisplay = register?.activeBillId == bill.id;
                return _SideButton(
                  icon: isOnDisplay ? Icons.visibility_off : Icons.visibility,
                  label: l.billDetailShowOnDisplay,
                  onPressed: () {
                    final registerId = register?.id;
                    if (registerId != null) {
                      if (isOnDisplay) {
                        ref.read(registerRepositoryProvider).setActiveBill(registerId, null);
                        _didShowOnDisplay = false;
                      } else {
                        ref.read(registerRepositoryProvider).setActiveBill(registerId, bill.id);
                        _didShowOnDisplay = true;
                      }
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) {
    final isClosed = bill.status != BillStatus.opened;
    final isPaid = bill.status == BillStatus.paid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Close
          SizedBox(
            height: 44,
            width: 130,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionClose),
            ),
          ),
          const SizedBox(width: 12),
          // Print receipt
          SizedBox(
            height: 44,
            width: 130,
            child: FilledButton(
              onPressed: () => showReceiptPrintDialog(context, ref, bill.id),
              child: Text(l.billDetailPrint),
            ),
          ),
          if (isPaid &&
              (ref.read(activeRegisterProvider).value?.allowRefunds ?? true)) ...[
            const SizedBox(width: 12),
            // Refund
            SizedBox(
              height: 44,
              width: 130,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () => _refundBill(context, ref, bill, l),
                child: Text(l.refundButton),
              ),
            ),
          ],
          if (!isClosed) ...[
            const SizedBox(width: 12),
            // Cancel bill
            SizedBox(
              height: 44,
              width: 130,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () => _cancelBill(context, ref, bill, l),
                child: Text(l.billDetailCancel),
              ),
            ),
          ],
          if (!isClosed && bill.totalGross > 0) ...[
            const SizedBox(width: 12),
            // Pay
            SizedBox(
              height: 44,
              width: 130,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => _payBill(context, ref, bill),
                child: Text(l.billDetailPay),
              ),
            ),
          ],
          if (!isClosed) ...[
            const SizedBox(width: 12),
            // Order
            SizedBox(
              height: 44,
              width: 130,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/sell/${bill.id}');
                },
                child: Text(l.billDetailOrder),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _cancelBill(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.billDetailConfirmCancel),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
        ],
      ),
    );
    if (confirmed != true) return;

    final repo = ref.read(billRepositoryProvider);
    final result = await repo.cancelBill(bill.id);
    if (result is Success) {
      await repo.updateTotals(bill.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _applyBillDiscount(BuildContext context, WidgetRef ref, BillModel bill) async {
    final result = await showDialog<(DiscountType, int)?>(
      context: context,
      builder: (_) => DialogDiscount(
        currentDiscount: bill.discountAmount,
        currentDiscountType: bill.discountType ?? DiscountType.absolute,
        referenceAmount: bill.subtotalGross,
      ),
    );
    if (result == null) return;
    await ref.read(billRepositoryProvider).updateDiscount(
      bill.id,
      result.$1,
      result.$2,
    );
  }

  Future<void> _redeemLoyalty(BuildContext context, WidgetRef ref, BillModel bill) async {
    if (bill.customerId == null) return;
    final customer = await ref.read(customerRepositoryProvider).getById(bill.customerId!);
    if (customer == null || customer.points <= 0) return;

    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final settingsRepo = ref.read(companySettingsRepositoryProvider);
    final settings = await settingsRepo.getOrCreate(company.id);
    if (settings.loyaltyPointValueHalere <= 0) return;

    if (!context.mounted) return;
    await showDialog<bool>(
      context: context,
      builder: (_) => DialogLoyaltyRedeem(
        bill: bill,
        customer: customer,
        pointValueHalere: settings.loyaltyPointValueHalere,
      ),
    );
  }

  Future<void> _applyVoucher(BuildContext context, WidgetRef ref, BillModel bill) async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const DialogVoucherRedeem(),
    );
    if (code == null || !context.mounted) return;

    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final voucherRepo = ref.read(voucherRepositoryProvider);
    final result = await voucherRepo.validateForBill(code, company.id, bill);
    if (result is Failure) {
      // Validation failed — show error text in a simple dialog
      if (!context.mounted) return;
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
        builder: (_) => AlertDialog(
          content: Text(errorMsg),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final voucher = (result as Success).value;
    // Calculate discount amount based on voucher type
    int discountAmount;
    if (voucher.type == VoucherType.gift || voucher.type == VoucherType.deposit) {
      // Cap at bill total
      discountAmount = voucher.value.clamp(0, bill.totalGross);
    } else {
      // Discount voucher
      if (voucher.discountType == DiscountType.percent) {
        discountAmount = (bill.subtotalGross * voucher.value / 10000).round();
      } else {
        discountAmount = voucher.value.clamp(0, bill.subtotalGross);
      }
    }

    final billRepo = ref.read(billRepositoryProvider);
    await billRepo.applyVoucher(
      billId: bill.id,
      voucherId: voucher.id,
      voucherDiscountAmount: discountAmount,
    );
    await voucherRepo.redeem(voucher.id, bill.id);
  }

  Future<void> _selectCustomer(BuildContext context, WidgetRef ref, BillModel bill) async {
    final result = await showCustomerSearchDialogRaw(
      context,
      ref,
      showRemoveButton: bill.customerId != null || bill.customerName != null,
    );
    if (result == null) return;
    if (result is CustomerModel) {
      await ref.read(billRepositoryProvider).updateCustomer(bill.id, result.id);
    } else if (result is String) {
      // Free-text customer name
      await ref.read(billRepositoryProvider).updateCustomerName(bill.id, result);
    } else {
      // _RemoveCustomer sentinel
      await ref.read(billRepositoryProvider).updateCustomer(bill.id, null);
    }
  }

  Future<void> _moveBill(BuildContext context, WidgetRef ref, BillModel bill) async {
    final l = context.l10n;
    final result = await showDialog<NewBillResult>(
      context: context,
      builder: (_) => DialogNewBill(
        title: l.billDetailMoveTitle,
        initialTableId: bill.tableId,
        initialNumberOfGuests: bill.numberOfGuests,
      ),
    );
    if (result == null) return;
    await ref.read(billRepositoryProvider).moveBill(
      bill.id,
      tableId: result.tableId,
      numberOfGuests: result.numberOfGuests,
    );
  }

  Future<void> _mergeBill(BuildContext context, WidgetRef ref, BillModel bill) async {
    final targetBillId = await showDialog<String>(
      context: context,
      builder: (_) => DialogMergeBill(excludeBillId: bill.id),
    );
    if (targetBillId == null || !context.mounted) return;

    final result = await ref.read(billRepositoryProvider).mergeBill(bill.id, targetBillId);
    if (result is Success && context.mounted) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => DialogBillDetail(billId: targetBillId),
      );
    }
  }

  Future<void> _splitBill(BuildContext context, WidgetRef ref, BillModel bill) async {
    final splitResult = await showDialog<SplitBillResult>(
      context: context,
      builder: (_) => DialogSplitBill(billId: bill.id),
    );
    if (splitResult == null || !context.mounted) return;

    final company = ref.read(currentCompanyProvider);
    final user = ref.read(activeUserProvider);
    if (company == null || user == null) return;

    if (splitResult.payImmediately) {
      // Create new bill (same table, 0 guests)
      final register = ref.read(activeRegisterProvider).value;
      final activeSession = ref.read(activeRegisterSessionProvider).value;
      final newBillResult = await ref.read(billRepositoryProvider).createBill(
        companyId: company.id,
        userId: user.id,
        currencyId: bill.currencyId,
        tableId: bill.tableId,
        registerId: register?.id,
        registerSessionId: activeSession?.id,
      );
      if (newBillResult is! Success<BillModel> || !context.mounted) return;
      final newBill = newBillResult.value;

      // Split items to new bill
      await ref.read(billRepositoryProvider).splitBill(
        sourceBillId: bill.id,
        targetBillId: newBill.id,
        orderItemIds: splitResult.orderItemIds,
        userId: user.id,
        registerId: register?.id,
      );

      // Get updated new bill for payment
      final updatedResult = await ref.read(billRepositoryProvider).getById(newBill.id);
      if (updatedResult is! Success<BillModel> || !context.mounted) return;

      // Resolve table name for payment dialog
      String? tableName;
      if (bill.tableId != null) {
        final table = await ref.read(tableRepositoryProvider).getById(bill.tableId!);
        tableName = table?.name;
      }
      if (!context.mounted) return;

      // Open payment dialog for new bill
      await showDialog<bool>(
        context: context,
        builder: (_) => DialogPayment(bill: updatedResult.value, tableName: tableName),
      );
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
      final newBillResult = await ref.read(billRepositoryProvider).createBill(
        companyId: company.id,
        userId: user.id,
        currencyId: bill.currencyId,
        tableId: newBillConfig.tableId,
        numberOfGuests: newBillConfig.numberOfGuests,
        registerId: register2?.id,
        registerSessionId: activeSession2?.id,
      );
      if (newBillResult is! Success<BillModel> || !context.mounted) return;

      // Split items to new bill
      await ref.read(billRepositoryProvider).splitBill(
        sourceBillId: bill.id,
        targetBillId: newBillResult.value.id,
        orderItemIds: splitResult.orderItemIds,
        userId: user.id,
        registerId: register2?.id,
      );
      // Stay on original bill detail (auto-refreshed via stream)
    }
  }

  Future<void> _refundBill(BuildContext context, WidgetRef ref, BillModel bill, dynamic l) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.refundTitle),
        content: Text(l.refundConfirmFull),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
        ],
      ),
    );
    if (confirmed != true) return;

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
  }

  Future<void> _payBill(BuildContext context, WidgetRef ref, BillModel bill) async {
    String? tableName;
    if (bill.tableId != null) {
      final table = await ref.read(tableRepositoryProvider).getById(bill.tableId!);
      tableName = table?.name;
    }

    if (!context.mounted) return;

    final paid = await showDialog<bool>(
      context: context,
      builder: (_) => DialogPayment(bill: bill, tableName: tableName),
    );
    if (paid == true && context.mounted) {
      Navigator.pop(context);
    }
  }
}

// ---------------------------------------------------------------------------
// Side button for right panel
// ---------------------------------------------------------------------------
class _SideButton extends StatelessWidget {
  const _SideButton({required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: null,
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, overflow: TextOverflow.clip, maxLines: 1),
                  ),
                ],
              )
            : Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
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
    final timeFormat = DateFormat('HH:mm', 'cs');

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
                        color: Colors.red,
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
                              color: Colors.red,
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
                onTap: isEditable
                    ? () => _editItemNotes(context, ref, item)
                    : (isPaid &&
                            item.status != PrepStatus.voided &&
                            (ref.read(activeRegisterProvider).value?.allowRefunds ?? true))
                        ? () => _refundItem(context, ref, item)
                        : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 44,
                            child: Text(
                              timeFormat.format(order.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)} ks',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Expanded(child: Text(item.itemName, style: Theme.of(context).textTheme.bodyMedium)),
                          SizedBox(
                            width: 100,
                            child: () {
                              final itemSubtotal = (item.salePriceAtt * item.quantity).round();
                              if (item.discount > 0) {
                                final itemDiscount = item.discountType == DiscountType.percent
                                    ? (itemSubtotal * item.discount / 10000).round()
                                    : item.discount;
                                final discountedPrice = itemSubtotal - itemDiscount;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${itemSubtotal ~/ 100}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${discountedPrice ~/ 100} Kč',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                );
                              }
                              return Text(
                                '${itemSubtotal ~/ 100} Kč',
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.bodyMedium,
                              );
                            }(),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _statusColor(item.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (item.status == PrepStatus.created ||
                              item.status == PrepStatus.inPrep ||
                              item.status == PrepStatus.ready)
                            PopupMenuButton<PrepStatus>(
                              iconSize: 16,
                              padding: EdgeInsets.zero,
                              onSelected: (status) =>
                                  _changeItemStatus(ref, item, status),
                              itemBuilder: (_) =>
                                  _availableTransitions(item.status, l),
                            )
                          else
                            const SizedBox(width: 32),
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
                    ],
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
      builder: (_) => AlertDialog(
        title: Text(context.l10n.sellNote),
        content: SizedBox(
          width: 300,
          child: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.l10n.sellNote,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    );
    if (result != null) {
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
      builder: (_) => AlertDialog(
        title: Text(item.itemName),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _voidSingleItem(context, ref, item);
                  },
                  child: Text(context.l10n.orderItemStorno),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    );
    if (result != null) {
      await ref.read(orderRepositoryProvider).updateItemNotes(
        item.id,
        result.isEmpty ? null : result,
      );
    }
  }

  Future<void> _voidSingleItem(BuildContext context, WidgetRef ref, OrderItemModel item) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.orderItemStornoConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final user = ref.read(activeUserProvider);
    if (user == null) return;

    // Generate storno order number
    final session = ref.read(activeRegisterSessionProvider).valueOrNull;
    final registerModel = ref.read(activeRegisterProvider).value;
    final regNum = registerModel?.registerNumber ?? 0;
    String stornoNumber = 'X$regNum-0000';
    if (session != null) {
      final sessionRepo = ref.read(registerSessionRepositoryProvider);
      final counter = await sessionRepo.incrementOrderCounter(session.id);
      if (counter is Success<int>) {
        stornoNumber = 'X$regNum-${counter.value.toString().padLeft(4, '0')}';
      }
    }

    final orderRepo = ref.read(orderRepositoryProvider);
    await orderRepo.voidItem(
      orderId: order.id,
      orderItemId: item.id,
      companyId: order.companyId,
      userId: user.id,
      stornoOrderNumber: stornoNumber,
      registerId: registerModel?.id,
    );
    await ref.read(billRepositoryProvider).updateTotals(order.billId);
  }

  Future<void> _editItemDiscount(BuildContext context, WidgetRef ref, OrderItemModel item) async {
    final referenceAmount = (item.salePriceAtt * item.quantity).round();
    final result = await showDialog<(DiscountType, int)?>(
      context: context,
      builder: (_) => DialogDiscount(
        currentDiscount: item.discount,
        currentDiscountType: item.discountType ?? DiscountType.absolute,
        referenceAmount: referenceAmount,
      ),
    );
    if (result == null) return;
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
      builder: (_) => AlertDialog(
        title: Text(l.refundTitle),
        content: Text(l.refundConfirmItem),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
        ],
      ),
    );
    if (confirmed != true) return;

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
      WidgetRef ref, OrderItemModel item, PrepStatus status) {
    final repo = ref.read(orderRepositoryProvider);
    repo.updateItemStatus(item.id, order.id, status);
  }

  List<PopupMenuEntry<PrepStatus>> _availableTransitions(PrepStatus current, dynamic l) {
    switch (current) {
      case PrepStatus.created:
        return [
          PopupMenuItem(value: PrepStatus.inPrep, child: Text(l.prepStatusInPrep)),
          PopupMenuItem(value: PrepStatus.cancelled, child: Text(l.prepStatusCancelled)),
        ];
      case PrepStatus.inPrep:
        return [
          PopupMenuItem(value: PrepStatus.ready, child: Text(l.prepStatusReady)),
          PopupMenuItem(value: PrepStatus.voided, child: Text(l.prepStatusVoided)),
        ];
      case PrepStatus.ready:
        return [
          PopupMenuItem(value: PrepStatus.delivered, child: Text(l.prepStatusDelivered)),
          PopupMenuItem(value: PrepStatus.voided, child: Text(l.prepStatusVoided)),
        ];
      default:
        return [];
    }
  }

  Color _statusColor(PrepStatus status) {
    return switch (status) {
      PrepStatus.created => Colors.blue,
      PrepStatus.inPrep => Colors.orange,
      PrepStatus.ready => Colors.green,
      PrepStatus.delivered => Colors.grey,
      PrepStatus.cancelled => Colors.red,
      PrepStatus.voided => Colors.red,
    };
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.totalGross,
  });
  final String name;
  final int unitPrice;
  final double quantity;
  final int totalGross;
}
