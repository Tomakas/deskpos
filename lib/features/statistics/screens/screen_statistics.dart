import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/enums/discount_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/order_item_model.dart';
import '../../../core/data/models/order_item_modifier_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/enums/prep_status.dart';
import '../../../core/data/result.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/pos_date_range_selector.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';
import '../../bills/providers/z_report_providers.dart';
import '../../bills/widgets/dialog_z_report.dart';

// ---------------------------------------------------------------------------
// Section enum
// ---------------------------------------------------------------------------

enum _StatSection { receipts, sales, orders, shifts, zReports, tips }

// ---------------------------------------------------------------------------
// Sort enums
// ---------------------------------------------------------------------------

enum _ReceiptSort { dateDesc, dateAsc, amountDesc, amountAsc }
enum _SalesSort { dateDesc, dateAsc, nameAsc, nameDesc, qtyDesc, totalDesc }
enum _ShiftSort { dateDesc, dateAsc, durationDesc }
enum _ZReportSort { dateDesc, dateAsc, revenueDesc }
enum _TipSort { dateDesc, dateAsc, amountDesc }
enum _OrderSort { dateDesc, dateAsc, amountDesc }

// ---------------------------------------------------------------------------
// Aggregated row models for Sales tab
// ---------------------------------------------------------------------------

class _SalesRow {
  _SalesRow({
    required this.closedAt,
    required this.itemName,
    required this.qty,
    required this.unitPrice,
    required this.total,
    required this.discount,
    required this.taxRate,
    required this.categoryName,
  });
  final DateTime closedAt;  // bill closedAt (for date/time column)
  final String itemName;
  final double qty;
  final int unitPrice; // effective per-unit price (base + modifiers − discount) / qty
  final int total;     // itemSubtotal − itemDiscount (negative for storno)
  final int discount;  // item-level discount amount in cents (sum for aggregated rows)
  final int taxRate;   // saleTaxRateAtt (e.g. 2100 = 21%)
  final String categoryName;
}

// ---------------------------------------------------------------------------
// Z-report display row
// ---------------------------------------------------------------------------

class _ZReportRow {
  _ZReportRow({
    required this.sessionId,
    required this.closedAt,
    required this.registerName,
    required this.userName,
    required this.revenue,
    required this.difference,
  });
  final String sessionId;
  final DateTime closedAt;
  final String registerName;
  final String userName;
  final int revenue;
  final int difference;
}

// ---------------------------------------------------------------------------
// Tip display row
// ---------------------------------------------------------------------------

class _TipRow {
  _TipRow({
    required this.paidAt,
    required this.userName,
    required this.billNumber,
    required this.amount,
  });
  final DateTime paidAt;
  final String userName;
  final String billNumber;
  final int amount;
}

// ---------------------------------------------------------------------------
// Shift display row
// ---------------------------------------------------------------------------

class _ShiftRow {
  _ShiftRow({
    required this.loginAt,
    required this.userName,
    required this.logoutAt,
    required this.duration,
  });
  final DateTime loginAt;
  final String userName;
  final DateTime? logoutAt;
  final Duration duration;
}

// ---------------------------------------------------------------------------
// Order display row
// ---------------------------------------------------------------------------

class _OrderRow {
  _OrderRow({
    required this.createdAt,
    required this.orderNumber,
    required this.userName,
    required this.itemCount,
    required this.totalGross,
    required this.status,
    required this.isStorno,
  });
  final DateTime createdAt;
  final String orderNumber;
  final String userName;
  final int itemCount;
  final int totalGross;
  final PrepStatus status;
  final bool isStorno;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ScreenStatistics extends ConsumerStatefulWidget {
  const ScreenStatistics({super.key});

  @override
  ConsumerState<ScreenStatistics> createState() => _ScreenStatisticsState();
}

class _ScreenStatisticsState extends ConsumerState<ScreenStatistics>
    with SingleTickerProviderStateMixin {
  static const _sections = _StatSection.values;

  late TabController _tabController;
  _StatSection _section = _StatSection.receipts;
  bool _loading = false;

  // Date range
  DateTime? _from;
  DateTime? _to;

  // Search
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Per-section sort
  _ReceiptSort _receiptSort = _ReceiptSort.dateDesc;
  _SalesSort _salesSort = _SalesSort.dateDesc;
  _ShiftSort _shiftSort = _ShiftSort.dateDesc;
  _ZReportSort _zReportSort = _ZReportSort.dateDesc;
  _TipSort _tipSort = _TipSort.dateDesc;
  _OrderSort _orderSort = _OrderSort.dateDesc;

  // Per-section data
  List<BillModel> _receipts = [];
  Map<String, String> _customerNames = {}; // customerId → display name
  Map<String, String> _paymentMethods = {}; // billId → comma-separated method names
  List<_SalesRow> _salesRows = [];
  int _salesTotalBillDiscount = 0;
  int _salesTotalLoyaltyDiscount = 0;
  int _salesTotalVoucherDiscount = 0;
  int _salesTotalRounding = 0;
  List<_ShiftRow> _shiftRows = [];
  List<_ZReportRow> _zReportRows = [];
  List<_TipRow> _tipRows = [];
  List<_OrderRow> _orderRows = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sections.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return; // wait for animation to finish
    _onSectionChanged(_sections[_tabController.index]);
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadData() async {
    if (_from == null || _to == null) return;
    setState(() => _loading = true);

    final company = ref.read(currentCompanyProvider);
    if (company == null) {
      setState(() => _loading = false);
      return;
    }

    switch (_section) {
      case _StatSection.receipts:
        await _loadReceipts(company.id);
      case _StatSection.sales:
        await _loadSales(company.id);
      case _StatSection.orders:
        await _loadOrders(company.id);
      case _StatSection.shifts:
        await _loadShifts(company.id);
      case _StatSection.zReports:
        await _loadZReports(company.id);
      case _StatSection.tips:
        await _loadTips(company.id);
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadReceipts(String companyId) async {
    final bills = await ref.read(billRepositoryProvider).getPaidOrRefundedInRange(companyId, _from!, _to!);
    if (!mounted) return;

    // Resolve customerId → display name
    final customerRepo = ref.read(customerRepositoryProvider);
    final customerIds = bills.map((b) => b.customerId).whereType<String>().toSet();
    final names = <String, String>{};
    for (final cid in customerIds) {
      final customer = await customerRepo.getById(cid, includeDeleted: true);
      if (customer != null) {
        names[cid] = '${customer.firstName} ${customer.lastName}'.trim();
      }
    }
    if (!mounted) return;

    // Resolve payment methods per bill
    final billIds = bills.map((b) => b.id).toList();
    final payments = await ref.read(paymentRepositoryProvider).getByBillIds(billIds);
    if (!mounted) return;
    final allMethods = await ref.read(paymentMethodRepositoryProvider).getAll(companyId);
    if (!mounted) return;
    final methodNameMap = {for (final m in allMethods) m.id: m.name};

    final methods = <String, String>{};
    final billMethodNames = <String, List<String>>{};
    for (final p in payments) {
      final name = methodNameMap[p.paymentMethodId] ?? '-';
      billMethodNames.putIfAbsent(p.billId, () => []);
      if (!billMethodNames[p.billId]!.contains(name)) {
        billMethodNames[p.billId]!.add(name);
      }
    }
    for (final entry in billMethodNames.entries) {
      methods[entry.key] = entry.value.join(', ');
    }

    setState(() {
      _receipts = bills;
      _customerNames = names;
      _paymentMethods = methods;
    });
  }

  Future<void> _loadSales(String companyId) async {
    final billRepo = ref.read(billRepositoryProvider);
    final orderRepo = ref.read(orderRepositoryProvider);
    final modifierRepo = ref.read(orderItemModifierRepositoryProvider);

    // 1. Load bills (paid + refunded)
    final bills = await billRepo.getPaidOrRefundedInRange(companyId, _from!, _to!);
    if (!mounted) return;
    if (bills.isEmpty) {
      setState(() {
        _salesRows = [];
        _salesTotalBillDiscount = 0;
        _salesTotalLoyaltyDiscount = 0;
        _salesTotalVoucherDiscount = 0;
        _salesTotalRounding = 0;
      });
      return;
    }
    final billIds = bills.map((b) => b.id).toList();

    // Build billId → closedAt map
    final billClosedAt = <String, DateTime>{};
    for (final bill in bills) {
      billClosedAt[bill.id] = bill.closedAt ?? bill.openedAt;
    }

    // 2. Load orders → build stornoOrderIds set + orderId→billId map
    final orders = await orderRepo.getOrdersByBillIds(billIds);
    if (!mounted) return;
    final activeOrders = orders.where((o) =>
        o.status != PrepStatus.cancelled && o.status != PrepStatus.voided).toList();
    final stornoOrderIds = <String>{};
    final activeOrderIds = <String>[];
    final orderBillMap = <String, String>{}; // orderId → billId
    for (final o in activeOrders) {
      if (o.isStorno) stornoOrderIds.add(o.id);
      activeOrderIds.add(o.id);
      orderBillMap[o.id] = o.billId;
    }

    // 3. Load items for active orders
    final allItems = activeOrderIds.isEmpty
        ? <OrderItemModel>[]
        : await orderRepo.getOrderItemsByBillIds(billIds);
    if (!mounted) return;
    // Filter: only items belonging to active orders, not cancelled/voided
    final activeOrderIdSet = activeOrderIds.toSet();
    final items = allItems.where((i) =>
        activeOrderIdSet.contains(i.orderId) &&
        i.status != PrepStatus.cancelled &&
        i.status != PrepStatus.voided).toList();

    // 4. Load modifiers for all active items
    final itemIds = items.map((i) => i.id).toList();
    final allMods = await modifierRepo.getByOrderItemIds(itemIds);
    if (!mounted) return;
    final modsByItem = <String, List<OrderItemModifierModel>>{};
    for (final mod in allMods) {
      modsByItem.putIfAbsent(mod.orderItemId, () => []).add(mod);
    }

    // 5. Resolve itemId → categoryName
    final itemRepo = ref.read(itemRepositoryProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final allCategories = await categoryRepo.watchAll(companyId).first;
    if (!mounted) return;
    final categoryMap = {for (final c in allCategories) c.id: c.name};
    final catalogItemIds = items.map((i) => i.itemId).toSet();
    final itemCategoryMap = <String, String>{};
    for (final catalogId in catalogItemIds) {
      final catalogItem = await itemRepo.getById(catalogId, includeDeleted: true);
      if (catalogItem != null && catalogItem.categoryId != null) {
        itemCategoryMap[catalogId] = categoryMap[catalogItem.categoryId!] ?? '';
      }
    }
    if (!mounted) return;

    // 6. Calculate per item (matching updateTotals logic)
    final map = <String, _SalesRow>{};
    for (final item in items) {
      final isStorno = stornoOrderIds.contains(item.orderId);
      final sign = isStorno ? -1 : 1;

      // Item subtotal = base price × qty + modifier costs
      int itemSubtotal = (item.salePriceAtt * item.quantity).round();
      final itemMods = modsByItem[item.id] ?? [];
      for (final mod in itemMods) {
        itemSubtotal += (mod.unitPrice * mod.quantity * item.quantity).round();
      }

      // Item discount (on subtotal including modifiers)
      int itemDiscount = 0;
      if (item.discount > 0) {
        if (item.discountType == DiscountType.percent) {
          itemDiscount = (itemSubtotal * item.discount / 10000).round();
        } else {
          itemDiscount = item.discount;
        }
      }

      final itemTotal = (itemSubtotal - itemDiscount) * sign;
      final qty = item.quantity * sign;
      // Effective per-unit price (always positive — for display)
      final effectiveUnitPrice = item.quantity > 0
          ? ((itemSubtotal - itemDiscount) / item.quantity).round()
          : 0;

      final category = itemCategoryMap[item.itemId] ?? '';
      final billId = orderBillMap[item.orderId] ?? '';
      final closedAt = billClosedAt[billId] ?? DateTime.now();
      // Aggregate per bill: same item + effective price + tax + category on same bill
      final key = '$billId|${item.itemName}|$effectiveUnitPrice|${item.saleTaxRateAtt}|$category';
      final existing = map[key];
      if (existing != null) {
        map[key] = _SalesRow(
          closedAt: closedAt,
          itemName: item.itemName,
          qty: existing.qty + qty,
          unitPrice: effectiveUnitPrice,
          total: existing.total + itemTotal,
          discount: existing.discount + itemDiscount,
          taxRate: item.saleTaxRateAtt,
          categoryName: category,
        );
      } else {
        map[key] = _SalesRow(
          closedAt: closedAt,
          itemName: item.itemName,
          qty: qty,
          unitPrice: effectiveUnitPrice,
          total: itemTotal,
          discount: itemDiscount,
          taxRate: item.saleTaxRateAtt,
          categoryName: category,
        );
      }
    }

    // 7. Bill-level discounts
    int totalBillDiscount = 0;
    int totalLoyalty = 0;
    int totalVoucher = 0;
    int totalRounding = 0;
    for (final bill in bills) {
      if (bill.discountAmount > 0) {
        if (bill.discountType == DiscountType.percent) {
          totalBillDiscount += (bill.subtotalGross * bill.discountAmount / 10000).round();
        } else {
          totalBillDiscount += bill.discountAmount;
        }
      }
      totalLoyalty += bill.loyaltyDiscountAmount;
      totalVoucher += bill.voucherDiscountAmount;
      totalRounding += bill.roundingAmount;
    }

    setState(() {
      _salesRows = map.values.toList();
      _salesTotalBillDiscount = totalBillDiscount;
      _salesTotalLoyaltyDiscount = totalLoyalty;
      _salesTotalVoucherDiscount = totalVoucher;
      _salesTotalRounding = totalRounding;
    });
  }

  Future<void> _loadOrders(String companyId) async {
    final orders = await ref.read(orderRepositoryProvider).getByCompanyInRange(companyId, _from!, _to!);
    if (!mounted) return;

    final userRepo = ref.read(userRepositoryProvider);
    final userIds = orders.map((o) => o.createdByUserId).toSet();
    final userMap = <String, String>{};
    for (final uid in userIds) {
      final user = await userRepo.getById(uid, includeDeleted: true);
      if (user != null) userMap[uid] = user.username;
    }
    if (!mounted) return;

    final rows = orders.map((o) => _OrderRow(
      createdAt: o.createdAt,
      orderNumber: o.orderNumber,
      userName: userMap[o.createdByUserId] ?? '-',
      itemCount: o.itemCount,
      totalGross: o.subtotalGross,
      status: o.status,
      isStorno: o.isStorno,
    )).toList();
    setState(() => _orderRows = rows);
  }

  Future<void> _loadShifts(String companyId) async {
    final shifts = await ref.read(shiftRepositoryProvider).getByCompanyInRange(companyId, _from!, _to!);
    if (!mounted) return;

    final userRepo = ref.read(userRepositoryProvider);
    final userIds = shifts.map((s) => s.userId).toSet();
    final userMap = <String, UserModel?>{};
    for (final uid in userIds) {
      userMap[uid] = await userRepo.getById(uid, includeDeleted: true);
    }
    if (!mounted) return;

    final rows = shifts.map((s) {
      final logoutAt = s.logoutAt;
      final duration = logoutAt != null
          ? logoutAt.difference(s.loginAt)
          : DateTime.now().difference(s.loginAt);
      return _ShiftRow(
        loginAt: s.loginAt,
        userName: userMap[s.userId]?.username ?? '-',
        logoutAt: logoutAt,
        duration: duration,
      );
    }).toList();
    setState(() => _shiftRows = rows);
  }

  Future<void> _loadZReports(String companyId) async {
    final sessions = await ref.read(registerSessionRepositoryProvider)
        .getClosedSessionsInRange(companyId, _from!, _to!);
    if (!mounted) return;

    final userRepo = ref.read(userRepositoryProvider);
    final registerRepo = ref.read(registerRepositoryProvider);
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final billRepo = ref.read(billRepositoryProvider);

    final rows = <_ZReportRow>[];
    for (final session in sessions) {
      final user = await userRepo.getById(session.openedByUserId, includeDeleted: true);
      final register = await registerRepo.getById(session.registerId, includeDeleted: true);

      // Compute revenue: sum of payments on bills paid within this session
      final bills = await billRepo.getPaidInRange(
        companyId,
        session.openedAt,
        session.closedAt!,
      );
      final billIds = bills.map((b) => b.id).toList();
      final payments = await paymentRepo.getByBillIds(billIds);
      final revenue = payments.fold(0, (sum, p) => sum + p.amount - p.tipIncludedAmount);

      rows.add(_ZReportRow(
        sessionId: session.id,
        closedAt: session.closedAt!,
        registerName: register?.name ?? register?.code ?? '-',
        userName: user?.username ?? '-',
        revenue: revenue,
        difference: session.difference ?? 0,
      ));
    }
    if (!mounted) return;
    setState(() => _zReportRows = rows);
  }

  Future<void> _loadTips(String companyId) async {
    final payments = await ref.read(paymentRepositoryProvider).getTipsInRange(companyId, _from!, _to!);
    if (!mounted) return;

    final userRepo = ref.read(userRepositoryProvider);
    final billRepo = ref.read(billRepositoryProvider);

    final userIds = payments.map((p) => p.userId).whereType<String>().toSet();
    final userMap = <String, UserModel?>{};
    for (final uid in userIds) {
      userMap[uid] = await userRepo.getById(uid, includeDeleted: true);
    }

    final billIds = payments.map((p) => p.billId).toSet();
    final billMap = <String, BillModel?>{};
    for (final bid in billIds) {
      final result = await billRepo.getById(bid);
      billMap[bid] = result is Success<BillModel> ? result.value : null;
    }
    if (!mounted) return;

    final rows = payments.map((p) => _TipRow(
      paidAt: p.paidAt,
      userName: p.userId != null ? (userMap[p.userId]?.username ?? '-') : '-',
      billNumber: billMap[p.billId]?.billNumber ?? '-',
      amount: p.tipIncludedAmount,
    )).toList();
    setState(() => _tipRows = rows);
  }

  // ---------------------------------------------------------------------------
  // Filtering + sorting
  // ---------------------------------------------------------------------------

  String _customerDisplayName(BillModel b) {
    if (b.customerName != null && b.customerName!.isNotEmpty) return b.customerName!;
    if (b.customerId != null) return _customerNames[b.customerId!] ?? '';
    return '';
  }

  List<BillModel> get _filteredReceipts {
    var list = _receipts;
    if (_query.isNotEmpty) {
      final q = normalizeSearch(_query);
      list = list.where((b) =>
          normalizeSearch(b.billNumber).contains(q) ||
          normalizeSearch(_customerDisplayName(b)).contains(q)).toList();
    }
    switch (_receiptSort) {
      case _ReceiptSort.dateDesc:
        list.sort((a, b) => (b.closedAt ?? b.openedAt).compareTo(a.closedAt ?? a.openedAt));
      case _ReceiptSort.dateAsc:
        list.sort((a, b) => (a.closedAt ?? a.openedAt).compareTo(b.closedAt ?? b.openedAt));
      case _ReceiptSort.amountDesc:
        list.sort((a, b) => b.totalGross.compareTo(a.totalGross));
      case _ReceiptSort.amountAsc:
        list.sort((a, b) => a.totalGross.compareTo(b.totalGross));
    }
    return list;
  }

  List<_SalesRow> get _filteredSales {
    var list = _salesRows;
    if (_query.isNotEmpty) {
      final q = normalizeSearch(_query);
      list = list.where((r) => normalizeSearch(r.itemName).contains(q)).toList();
    }
    switch (_salesSort) {
      case _SalesSort.dateDesc:
        list.sort((a, b) => b.closedAt.compareTo(a.closedAt));
      case _SalesSort.dateAsc:
        list.sort((a, b) => a.closedAt.compareTo(b.closedAt));
      case _SalesSort.nameAsc:
        list.sort((a, b) => a.itemName.compareTo(b.itemName));
      case _SalesSort.nameDesc:
        list.sort((a, b) => b.itemName.compareTo(a.itemName));
      case _SalesSort.qtyDesc:
        list.sort((a, b) => b.qty.compareTo(a.qty));
      case _SalesSort.totalDesc:
        list.sort((a, b) => b.total.compareTo(a.total));
    }
    return list;
  }

  List<_OrderRow> get _filteredOrders {
    var list = _orderRows;
    if (_query.isNotEmpty) {
      final q = normalizeSearch(_query);
      list = list.where((r) =>
          normalizeSearch(r.orderNumber).contains(q) ||
          normalizeSearch(r.userName).contains(q)).toList();
    }
    switch (_orderSort) {
      case _OrderSort.dateDesc:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _OrderSort.dateAsc:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _OrderSort.amountDesc:
        list.sort((a, b) => b.totalGross.compareTo(a.totalGross));
    }
    return list;
  }

  List<_ShiftRow> get _filteredShifts {
    var list = _shiftRows;
    if (_query.isNotEmpty) {
      final q = normalizeSearch(_query);
      list = list.where((r) => normalizeSearch(r.userName).contains(q)).toList();
    }
    switch (_shiftSort) {
      case _ShiftSort.dateDesc:
        list.sort((a, b) => b.loginAt.compareTo(a.loginAt));
      case _ShiftSort.dateAsc:
        list.sort((a, b) => a.loginAt.compareTo(b.loginAt));
      case _ShiftSort.durationDesc:
        list.sort((a, b) => b.duration.compareTo(a.duration));
    }
    return list;
  }

  List<_ZReportRow> get _filteredZReports {
    var list = _zReportRows;
    if (_query.isNotEmpty) {
      final q = normalizeSearch(_query);
      list = list.where((r) =>
          normalizeSearch(r.userName).contains(q) ||
          normalizeSearch(r.registerName).contains(q)).toList();
    }
    switch (_zReportSort) {
      case _ZReportSort.dateDesc:
        list.sort((a, b) => b.closedAt.compareTo(a.closedAt));
      case _ZReportSort.dateAsc:
        list.sort((a, b) => a.closedAt.compareTo(b.closedAt));
      case _ZReportSort.revenueDesc:
        list.sort((a, b) => b.revenue.compareTo(a.revenue));
    }
    return list;
  }

  List<_TipRow> get _filteredTips {
    var list = _tipRows;
    if (_query.isNotEmpty) {
      final q = normalizeSearch(_query);
      list = list.where((r) =>
          normalizeSearch(r.userName).contains(q) ||
          normalizeSearch(r.billNumber).contains(q)).toList();
    }
    switch (_tipSort) {
      case _TipSort.dateDesc:
        list.sort((a, b) => b.paidAt.compareTo(a.paidAt));
      case _TipSort.dateAsc:
        list.sort((a, b) => a.paidAt.compareTo(b.paidAt));
      case _TipSort.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
    }
    return list;
  }

  // ---------------------------------------------------------------------------
  // Section change
  // ---------------------------------------------------------------------------

  void _onSectionChanged(_StatSection section) {
    if (section == _section) return;
    setState(() {
      _section = section;
      _searchCtrl.clear();
      _query = '';
    });
    _loadData();
  }

  void _onDateRangeChanged(DateTime from, DateTime to) {
    _from = from;
    _to = to;
    _loadData();
  }

  // ---------------------------------------------------------------------------
  // Sort menu
  // ---------------------------------------------------------------------------

  void _showSortMenu() {
    final l = context.l10n;
    switch (_section) {
      case _StatSection.receipts:
        _showSortPopup<_ReceiptSort>(
          items: {
            _ReceiptSort.dateDesc: l.statsSortDate,
            _ReceiptSort.dateAsc: l.statsSortDateAsc,
            _ReceiptSort.amountDesc: l.statsSortAmount,
            _ReceiptSort.amountAsc: l.statsSortAmountAsc,
          },
          current: _receiptSort,
          onSelected: (v) => setState(() => _receiptSort = v),
        );
      case _StatSection.sales:
        _showSortPopup<_SalesSort>(
          items: {
            _SalesSort.dateDesc: l.statsSortDate,
            _SalesSort.dateAsc: l.statsSortDateAsc,
            _SalesSort.nameAsc: l.statsSortName,
            _SalesSort.nameDesc: l.statsSortNameDesc,
            _SalesSort.qtyDesc: l.statsSortQty,
            _SalesSort.totalDesc: l.statsSortAmount,
          },
          current: _salesSort,
          onSelected: (v) => setState(() => _salesSort = v),
        );
      case _StatSection.orders:
        _showSortPopup<_OrderSort>(
          items: {
            _OrderSort.dateDesc: l.statsSortDate,
            _OrderSort.dateAsc: l.statsSortDateAsc,
            _OrderSort.amountDesc: l.statsSortAmount,
          },
          current: _orderSort,
          onSelected: (v) => setState(() => _orderSort = v),
        );
      case _StatSection.shifts:
        _showSortPopup<_ShiftSort>(
          items: {
            _ShiftSort.dateDesc: l.statsSortDate,
            _ShiftSort.dateAsc: l.statsSortDateAsc,
            _ShiftSort.durationDesc: l.statsSortDuration,
          },
          current: _shiftSort,
          onSelected: (v) => setState(() => _shiftSort = v),
        );
      case _StatSection.zReports:
        _showSortPopup<_ZReportSort>(
          items: {
            _ZReportSort.dateDesc: l.statsSortDate,
            _ZReportSort.dateAsc: l.statsSortDateAsc,
            _ZReportSort.revenueDesc: l.statsSortRevenue,
          },
          current: _zReportSort,
          onSelected: (v) => setState(() => _zReportSort = v),
        );
      case _StatSection.tips:
        _showSortPopup<_TipSort>(
          items: {
            _TipSort.dateDesc: l.statsSortDate,
            _TipSort.dateAsc: l.statsSortDateAsc,
            _TipSort.amountDesc: l.statsSortAmount,
          },
          current: _tipSort,
          onSelected: (v) => setState(() => _tipSort = v),
        );
    }
  }

  void _showSortPopup<T>({
    required Map<T, String> items,
    required T current,
    required ValueChanged<T> onSelected,
  }) {
    final button = context.findRenderObject()! as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      button.localToGlobal(Offset.zero, ancestor: overlay) & button.size,
      Offset.zero & overlay.size,
    );
    showMenu<T>(
      context: context,
      position: position,
      items: items.entries.map((e) => PopupMenuItem<T>(
        value: e.key,
        height: 48,
        child: Row(
          children: [
            if (e.key == current)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.check, size: 18),
              ),
            Text(e.value),
          ],
        ),
      )).toList(),
    ).then((value) {
      if (value != null) onSelected(value);
    });
  }

  // ---------------------------------------------------------------------------
  // Summary dialog
  // ---------------------------------------------------------------------------

  void _showSummary() {
    final l = context.l10n;
    List<(String, String)> rows;

    switch (_section) {
      case _StatSection.receipts:
        final data = _filteredReceipts;
        final total = data.fold(0, (s, b) => s + b.totalGross);
        final avg = data.isEmpty ? 0 : total ~/ data.length;
        rows = [
          (l.statsReceiptCount, '${data.length}'),
          (l.statsReceiptTotal, ref.money(total)),
          (l.statsReceiptAvg, ref.money(avg)),
        ];
      case _StatSection.sales:
        // Always use unfiltered data for summary — bill-level discounts are global
        final all = _salesRows;
        final totalQty = all.fold(0.0, (s, r) => s + r.qty);
        final grossRevenue = all.fold(0, (s, r) => s + r.total);
        final totalItemDiscount = all.fold(0, (s, r) => s + r.discount);
        final uniqueItems = all.map((r) => r.itemName).toSet().length;
        final finalTotal = grossRevenue - _salesTotalBillDiscount - _salesTotalLoyaltyDiscount - _salesTotalVoucherDiscount + _salesTotalRounding;
        rows = [
          (l.statsSalesGrossRevenue, ref.money(grossRevenue)),
          if (totalItemDiscount != 0)
            (l.statsSalesItemDiscounts, '– ${ref.money(totalItemDiscount)}'),
          if (_salesTotalBillDiscount != 0)
            (l.statsSalesBillDiscount, '– ${ref.money(_salesTotalBillDiscount)}'),
          if (_salesTotalLoyaltyDiscount != 0)
            (l.statsSalesLoyaltyDiscount, '– ${ref.money(_salesTotalLoyaltyDiscount)}'),
          if (_salesTotalVoucherDiscount != 0)
            (l.statsSalesVoucherDiscount, '– ${ref.money(_salesTotalVoucherDiscount)}'),
          if (_salesTotalRounding != 0)
            (l.statsSalesRounding, ref.money(_salesTotalRounding)),
          (l.statsSalesFinalTotal, ref.money(finalTotal)),
          (l.statsSalesItemCount, '${totalQty.round()}'),
          (l.statsSalesUniqueItems, '$uniqueItems'),
        ];
      case _StatSection.orders:
        final data = _filteredOrders;
        final totalAmount = data.fold(0, (s, r) => s + r.totalGross);
        final totalItems = data.fold(0, (s, r) => s + r.itemCount);
        rows = [
          (l.statsOrderCount, '${data.length}'),
          (l.statsOrderTotalItems, '$totalItems'),
          (l.statsOrderTotal, ref.money(totalAmount)),
        ];
      case _StatSection.shifts:
        final data = _filteredShifts;
        final totalDuration = data.fold(Duration.zero, (s, r) => s + r.duration);
        final totalHours = (totalDuration.inMinutes / 60).toStringAsFixed(1);
        final avgDuration = data.isEmpty
            ? Duration.zero
            : Duration(minutes: totalDuration.inMinutes ~/ data.length);
        rows = [
          (l.statsShiftCount, '${data.length}'),
          (l.statsShiftTotalHours, '$totalHours h'),
          (l.statsShiftAvgDuration, _fmtDuration(avgDuration)),
        ];
      case _StatSection.zReports:
        final data = _filteredZReports;
        final totalRev = data.fold(0, (s, r) => s + r.revenue);
        final totalDiff = data.fold(0, (s, r) => s + r.difference);
        rows = [
          (l.statsZReportCount, '${data.length}'),
          (l.statsZReportTotalRevenue, ref.money(totalRev)),
          (l.statsZReportTotalDiff, ref.money(totalDiff)),
        ];
      case _StatSection.tips:
        final data = _filteredTips;
        final totalAmount = data.fold(0, (s, r) => s + r.amount);
        final avg = data.isEmpty ? 0 : totalAmount ~/ data.length;
        rows = [
          (l.statsTipCount, '${data.length}'),
          (l.statsTipTotal, ref.money(totalAmount)),
          (l.statsTipAvg, ref.money(avg)),
        ];
    }

    showDialog(
      context: context,
      builder: (_) => PosDialogShell(
        title: l.statsSummary,
        scrollable: true,
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          PosDialogActions(actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionClose),
            ),
          ]),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Z-report row tap
  // ---------------------------------------------------------------------------

  Future<void> _onZReportTap(_ZReportRow row) async {
    final zReportService = ref.read(zReportServiceProvider);
    final zReport = await zReportService.buildZReport(row.sessionId);
    if (zReport != null && mounted) {
      showDialog(
        context: context,
        builder: (_) => DialogZReport(data: zReport),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _fmtDuration(Duration d) {
    final l = context.l10n;
    return formatDuration(d, hm: l.durationHoursMinutes, hOnly: l.durationHoursOnly, mOnly: l.durationMinutesOnly);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = ref.watch(appLocaleProvider).value ?? 'cs';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/bills'),
        ),
        title: Text(l.statsTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l.statsTabReceipts),
            Tab(text: l.statsTabSales),
            Tab(text: l.statsTabOrders),
            Tab(text: l.statsTabShifts),
            Tab(text: l.statsTabZReports),
            Tab(text: l.statsTabTips),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date range selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PosDateRangeSelector(
              onChanged: _onDateRangeChanged,
              locale: locale,
              l10n: l,
            ),
          ),
          // Toolbar
          PosTableToolbar(
            searchController: _searchCtrl,
            searchHint: l.searchHint,
            onSearchChanged: (v) => setState(() => _query = v),
            trailing: [
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: _showSortMenu,
              ),
              IconButton(
                icon: const Icon(Icons.summarize),
                onPressed: _showSummary,
              ),
            ],
          ),
          // Table
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildTable(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Table builders
  // ---------------------------------------------------------------------------

  Widget _buildTable() {
    final l = context.l10n;
    switch (_section) {
      case _StatSection.receipts:
        return _buildReceiptsTable(l);
      case _StatSection.sales:
        return _buildSalesTable(l);
      case _StatSection.orders:
        return _buildOrdersTable(l);
      case _StatSection.shifts:
        return _buildShiftsTable(l);
      case _StatSection.zReports:
        return _buildZReportsTable(l);
      case _StatSection.tips:
        return _buildTipsTable(l);
    }
  }

  Widget _buildReceiptsTable(dynamic l) {
    final data = _filteredReceipts;
    return PosTable<BillModel>(
      emptyMessage: l.statsEmpty,
      columns: [
        PosColumn(
          label: l.statsColumnDateTime,
          flex: 14,
          cellBuilder: (b) => Text(ref.fmtDateTime(b.closedAt ?? b.openedAt)),
        ),
        PosColumn(
          label: l.statsColumnBillNumber,
          flex: 8,
          cellBuilder: (b) => Text(b.billNumber),
        ),
        PosColumn(
          label: l.statsColumnCustomer,
          flex: 15,
          cellBuilder: (b) => Text(_customerDisplayName(b), overflow: TextOverflow.ellipsis),
        ),
        PosColumn(
          label: l.statsColumnPaymentMethod,
          flex: 12,
          cellBuilder: (b) => Text(_paymentMethods[b.id] ?? '', overflow: TextOverflow.ellipsis),
        ),
        PosColumn(
          label: l.statsColumnTotal,
          flex: 10,
          numeric: true,
          cellBuilder: (b) => Text(ref.money(b.totalGross), textAlign: TextAlign.right),
        ),
      ],
      items: data,
    );
  }

  Widget _buildSalesTable(dynamic l) {
    final data = _filteredSales;
    return PosTable<_SalesRow>(
      emptyMessage: l.statsEmpty,
      columns: [
        PosColumn(
          label: l.statsColumnDateTime,
          flex: 14,
          cellBuilder: (r) => Text(ref.fmtDateTime(r.closedAt)),
        ),
        PosColumn(
          label: l.statsColumnItemName,
          flex: 16,
          cellBuilder: (r) => Text(r.itemName, overflow: TextOverflow.ellipsis),
        ),
        PosColumn(
          label: l.statsColumnCategory,
          flex: 10,
          cellBuilder: (r) => Text(r.categoryName, overflow: TextOverflow.ellipsis),
        ),
        PosColumn(
          label: l.statsColumnQty,
          flex: 5,
          numeric: true,
          cellBuilder: (r) => Text(
            r.qty == r.qty.roundToDouble() ? '${r.qty.round()}' : r.qty.toStringAsFixed(2),
            textAlign: TextAlign.right,
          ),
        ),
        PosColumn(
          label: l.statsColumnUnitPrice,
          flex: 10,
          numeric: true,
          cellBuilder: (r) => Text(ref.money(r.unitPrice), textAlign: TextAlign.right),
        ),
        PosColumn(
          label: l.statsColumnTax,
          flex: 6,
          numeric: true,
          cellBuilder: (r) => Text('${(r.taxRate / 100).toStringAsFixed(0)} %', textAlign: TextAlign.right),
        ),
        PosColumn(
          label: l.statsColumnTotal,
          flex: 10,
          numeric: true,
          cellBuilder: (r) => Text(ref.money(r.total), textAlign: TextAlign.right),
        ),
      ],
      items: data,
    );
  }

  Widget _buildOrdersTable(dynamic l) {
    final data = _filteredOrders;
    return PosTable<_OrderRow>(
      emptyMessage: l.statsEmpty,
      columns: [
        PosColumn(
          label: l.statsColumnDateTime,
          flex: 14,
          cellBuilder: (r) => Text(ref.fmtDateTime(r.createdAt)),
        ),
        PosColumn(
          label: l.statsColumnOrderNumber,
          flex: 8,
          cellBuilder: (r) => Text(r.orderNumber),
        ),
        PosColumn(
          label: l.zReportColumnUser,
          flex: 12,
          cellBuilder: (r) => Text(r.userName, overflow: TextOverflow.ellipsis),
        ),
        PosColumn(
          label: l.statsColumnQty,
          flex: 5,
          numeric: true,
          cellBuilder: (r) => Text('${r.itemCount}', textAlign: TextAlign.right),
        ),
        PosColumn(
          label: l.statsColumnTotal,
          flex: 10,
          numeric: true,
          cellBuilder: (r) => Text(ref.money(r.totalGross), textAlign: TextAlign.right),
        ),
        PosColumn(
          label: l.statsColumnStatus,
          flex: 10,
          headerAlign: TextAlign.center,
          cellBuilder: (r) => Text(
            r.isStorno ? l.orderStorno : _prepStatusLabel(r.status, l),
            textAlign: TextAlign.center,
            style: TextStyle(color: r.status.color(context)),
          ),
        ),
      ],
      items: data,
    );
  }

  String _prepStatusLabel(PrepStatus status, dynamic l) {
    return switch (status) {
      PrepStatus.created => l.prepStatusCreated,
      PrepStatus.ready => l.prepStatusReady,
      PrepStatus.delivered => l.prepStatusDelivered,
      PrepStatus.cancelled => l.prepStatusCancelled,
      PrepStatus.voided => l.prepStatusVoided,
    };
  }

  Widget _buildShiftsTable(dynamic l) {
    final data = _filteredShifts;
    return PosTable<_ShiftRow>(
      emptyMessage: l.statsEmpty,
      columns: [
        PosColumn(
          label: l.shiftsColumnDate,
          flex: 10,
          cellBuilder: (r) => Text(ref.fmtDate(r.loginAt)),
        ),
        PosColumn(
          label: l.shiftsColumnUser,
          flex: 15,
          cellBuilder: (r) => Text(r.userName, overflow: TextOverflow.ellipsis),
        ),
        PosColumn(
          label: l.shiftsColumnLogin,
          flex: 6,
          cellBuilder: (r) => Text(ref.fmtTime(r.loginAt)),
        ),
        PosColumn(
          label: l.shiftsColumnLogout,
          flex: 8,
          numeric: true,
          cellBuilder: (r) => Text(
            r.logoutAt != null ? ref.fmtTime(r.logoutAt!) : l.shiftsOngoing,
            textAlign: TextAlign.right,
          ),
        ),
        PosColumn(
          label: l.shiftsColumnDuration,
          flex: 8,
          numeric: true,
          cellBuilder: (r) => Text(_fmtDuration(r.duration), textAlign: TextAlign.right),
        ),
      ],
      items: data,
    );
  }

  Widget _buildZReportsTable(dynamic l) {
    final data = _filteredZReports;
    return PosTable<_ZReportRow>(
      emptyMessage: l.statsEmpty,
      onRowTap: _onZReportTap,
      columns: [
        PosColumn(
          label: l.zReportColumnDate,
          flex: 10,
          cellBuilder: (r) => Text(ref.fmtDate(r.closedAt)),
        ),
        PosColumn(
          label: l.zReportColumnTime,
          flex: 6,
          cellBuilder: (r) => Text(ref.fmtTime(r.closedAt)),
        ),
        PosColumn(
          label: l.zReportRegisterColumn,
          flex: 12,
          cellBuilder: (r) => Text(r.registerName, overflow: TextOverflow.ellipsis),
        ),
        PosColumn(
          label: l.zReportColumnUser,
          flex: 12,
          cellBuilder: (r) => Text(r.userName, overflow: TextOverflow.ellipsis),
        ),
        PosColumn(
          label: l.zReportColumnRevenue,
          flex: 10,
          numeric: true,
          cellBuilder: (r) => Text(ref.money(r.revenue), textAlign: TextAlign.right),
        ),
        PosColumn(
          label: l.zReportColumnDifference,
          flex: 8,
          numeric: true,
          cellBuilder: (r) => Text(
            ref.money(r.difference),
            textAlign: TextAlign.right,
            style: TextStyle(color: cashDifferenceColor(r.difference, context)),
          ),
        ),
      ],
      items: data,
    );
  }

  Widget _buildTipsTable(dynamic l) {
    final data = _filteredTips;
    return PosTable<_TipRow>(
      emptyMessage: l.statsEmpty,
      columns: [
        PosColumn(
          label: l.zReportColumnDate,
          flex: 10,
          cellBuilder: (r) => Text(ref.fmtDate(r.paidAt)),
        ),
        PosColumn(
          label: l.zReportColumnTime,
          flex: 6,
          cellBuilder: (r) => Text(ref.fmtTime(r.paidAt)),
        ),
        PosColumn(
          label: l.zReportColumnUser,
          flex: 15,
          cellBuilder: (r) => Text(r.userName, overflow: TextOverflow.ellipsis),
        ),
        PosColumn(
          label: l.statsColumnBill,
          flex: 8,
          cellBuilder: (r) => Text(r.billNumber),
        ),
        PosColumn(
          label: l.tipStatsColumnAmount,
          flex: 12,
          numeric: true,
          cellBuilder: (r) => Text(ref.money(r.amount), textAlign: TextAlign.right),
        ),
      ],
      items: data,
    );
  }
}
