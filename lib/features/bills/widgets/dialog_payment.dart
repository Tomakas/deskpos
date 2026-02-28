import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/cash_movement_type.dart';
import '../../../core/data/enums/payment_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/company_currency_model.dart';
import '../../../core/data/models/currency_model.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/payment_method_model.dart';
import '../../../core/data/models/payment_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import 'dialog_cash_tender.dart';
import 'dialog_change_total.dart';
import 'dialog_loyalty_redeem.dart';

class DialogPayment extends ConsumerStatefulWidget {
  const DialogPayment({
    super.key,
    required this.bill,
    this.tableName,
    this.skipLoyaltyEarn = false,
  });
  final BillModel bill;
  final String? tableName;
  final bool skipLoyaltyEarn;

  @override
  ConsumerState<DialogPayment> createState() => _DialogPaymentState();
}

class _DialogPaymentState extends ConsumerState<DialogPayment> {
  bool _processing = false;
  bool _printReceipt = true;
  bool _showOtherPayments = false;
  bool _showCurrencySelector = false;
  bool _showMoreActions = false;
  late BillModel _bill;
  int? _customAmount;
  int? _customForeignAmount;
  CustomerModel? _customer;
  Future<List<PaymentMethodModel>>? _paymentMethodsFuture;
  Stream<List<PaymentMethodModel>>? _paymentMethodsStream;
  int _loyaltyPointValue = 0;
  int _loyaltyEarnRate = 0;

  // Foreign currency state
  String? _selectedForeignCurrencyId;
  CompanyCurrencyModel? _selectedCompanyCurrency;
  CurrencyModel? _selectedForeignCurrencyDetail;
  List<(CompanyCurrencyModel, CurrencyModel)> _availableForeignCurrencies = [];

  @override
  void initState() {
    super.initState();
    _bill = widget.bill;
    _loadCustomer();
    final company = ref.read(currentCompanyProvider);
    if (company != null) {
      _paymentMethodsFuture = ref.read(paymentMethodRepositoryProvider).getAll(company.id);
      _paymentMethodsStream = ref.read(paymentMethodRepositoryProvider).watchAll(company.id);
      _loadForeignCurrencies(company.id);
      _loadLoyaltySettings(company.id);
    }
  }

  Future<void> _loadForeignCurrencies(String companyId) async {
    final ccRepo = ref.read(companyCurrencyRepositoryProvider);
    final currencyRepo = ref.read(currencyRepositoryProvider);
    final active = await ccRepo.getActive(companyId);
    final result = <(CompanyCurrencyModel, CurrencyModel)>[];
    for (final cc in active) {
      final currResult = await currencyRepo.getById(cc.currencyId);
      if (currResult != null) {
        result.add((cc, currResult));
      }
    }
    if (mounted) {
      setState(() => _availableForeignCurrencies = result);
    }
  }

  Future<void> _loadCustomer() async {
    if (_bill.customerId == null) return;
    final customer = await ref.read(customerRepositoryProvider).getById(_bill.customerId!);
    if (mounted && customer != null) {
      setState(() => _customer = customer);
    }
  }

  Future<void> _loadLoyaltySettings(String companyId) async {
    final settings = await ref.read(companySettingsRepositoryProvider).getOrCreate(companyId);
    if (mounted) {
      setState(() {
        _loyaltyPointValue = settings.loyaltyPointValue;
        _loyaltyEarnRate = settings.loyaltyEarnRate;
      });
    }
  }

  bool get _hasMoreActions => _canRedeemLoyalty;

  bool get _canRedeemLoyalty =>
      _customer != null &&
      _customer!.points > 0 &&
      _bill.loyaltyPointsUsed == 0 &&
      _bill.paidAmount == 0 &&
      _loyaltyPointValue > 0 &&
      ref.read(hasPermissionProvider('discounts.loyalty')) &&
      !_processing;

  int get _remaining => _bill.totalGross - _bill.paidAmount;

  int get _payAmount => _customAmount ?? _remaining;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: (MediaQuery.sizeOf(context).height - 24).clamp(0, 240),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left sidebar — action buttons or currency selector
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _showCurrencySelector
                    ? _buildCurrencySelector(context, l)
                    : _showMoreActions
                        ? _buildMoreActions(context, l)
                        : Column(
                            children: [
                              Expanded(
                                child: _SideButton(
                                  label: _selectedForeignCurrencyId != null
                                      ? '${_selectedForeignCurrencyDetail!.code} (${_selectedForeignCurrencyDetail!.symbol})'
                                      : l.paymentOtherCurrency,
                                  onPressed: _availableForeignCurrencies.isNotEmpty
                                      ? () {
                                          if (_selectedForeignCurrencyId != null) {
                                            _clearForeignCurrency();
                                          } else {
                                            setState(() => _showCurrencySelector = true);
                                          }
                                        }
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: _SideButton(
                                  label: l.paymentPrintReceipt,
                                  onPressed: () => setState(() => _printReceipt = !_printReceipt),
                                  icon: _printReceipt
                                      ? Icon(Icons.check_circle, size: 16, color: Colors.green.shade300)
                                      : Icon(Icons.block, size: 16, color: Colors.red.shade300),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: _SideButton(
                                  label: l.paymentMoreActions,
                                  onPressed: _hasMoreActions ? () => setState(() => _showMoreActions = true) : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: _SideButton(
                                  label: l.actionCancel,
                                  onPressed: () => Navigator.pop(context, _bill.paidAmount > widget.bill.paidAmount),
                                  color: context.appColors.danger,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
              // Center — bill info + payments list
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    children: [
                      // 25% — title + bill number
                      Expanded(
                        flex: 5,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l.paymentTitle.toUpperCase(),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l.paymentBillSubtitle(
                                  _bill.billNumber,
                                  widget.tableName ?? l.billDetailNoTable,
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 25% — customer banner (or empty)
                      Expanded(
                        flex: 5,
                        child: _customer != null
                            ? FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Material(
                                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: _canRedeemLoyalty ? () => _redeemLoyalty(context) : null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${_customer!.firstName} ${_customer!.lastName}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            l.loyaltyCustomerInfo(
                                              _customer!.points,
                                              ref.money(_customer!.credit),
                                            ),
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      // 15% — payments list
                      Expanded(
                        flex: 3,
                        child: StreamBuilder<List<PaymentModel>>(
                          stream: ref.watch(paymentRepositoryProvider).watchByBill(_bill.id),
                          builder: (context, snap) {
                            final payments = snap.data ?? [];
                            if (payments.isEmpty) return const SizedBox.shrink();
                            return LayoutBuilder(
                              builder: (context, constraints) => FittedBox(
                                fit: BoxFit.scaleDown,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  child: _buildPaymentsList(context, payments),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // 35% — amount to pay
                      Expanded(
                        flex: 7,
                        child: LayoutBuilder(
                          builder: (context, constraints) => FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_selectedForeignCurrencyId != null) ...[
                                    _amountBlock(
                                      context,
                                      _formatForeignMoney(_foreignPayAmount),
                                      onTap: _remaining > 0 ? () => _editAmount(context) : null,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l.paymentForeignRate(
                                        _selectedCompanyCurrency!.exchangeRate.toString(),
                                        ref.money(_foreignToBase(_foreignPayAmount)),
                                      ),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    if (_foreignToBase(_foreignPayAmount) > _remaining)
                                      Text(
                                        '(${l.paymentTip(ref.money(_foreignToBase(_foreignPayAmount) - _remaining))})',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.green,
                                        ),
                                      ),
                                  ] else if (_customAmount != null) ...[
                                    _amountBlock(
                                      context,
                                      ref.money(_customAmount!),
                                      onTap: _remaining > 0 ? () => _editAmount(context) : null,
                                    ),
                                    if (_customAmount! != _remaining) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _customAmount! > _remaining
                                            ? '(${l.paymentTip(ref.money(_customAmount! - _remaining))})'
                                            : '(${l.paymentRemaining(ref.money(_customAmount! - _remaining))})',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: _customAmount! > _remaining
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ] else ...[
                                    _amountBlock(
                                      context,
                                      ref.money(_remaining),
                                      onTap: _remaining > 0 ? () => _editAmount(context) : null,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right sidebar — payment methods (4 slots: 3 methods + 1 action)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: StreamBuilder<List<PaymentMethodModel>>(
                    stream: _paymentMethodsStream,
                    builder: (context, snap) {
                      final methods = (snap.data ?? []).where((m) => m.isActive).toList();
                      final register = ref.watch(activeRegisterProvider).value;

                      // Filter all methods by register flags
                      bool isAllowedByRegister(PaymentMethodModel m) {
                        if (register == null) return true;
                        return switch (m.type) {
                          PaymentType.cash => register.allowCash,
                          PaymentType.card => register.allowCard,
                          PaymentType.bank => register.allowTransfer,
                          PaymentType.credit => register.allowCredit,
                          PaymentType.voucher => register.allowVoucher,
                          PaymentType.other => register.allowOther,
                        };
                      }

                      // Primary: cash, card, bank (foreign currency = cash only)
                      const primaryTypes = {PaymentType.cash, PaymentType.card, PaymentType.bank};
                      final primaryMethods = methods
                          .where((m) => primaryTypes.contains(m.type))
                          .where(isAllowedByRegister)
                          .where((m) => _selectedForeignCurrencyId == null || m.type == PaymentType.cash)
                          .toList();

                      // Secondary: credit (only with customer + credit), voucher, other
                      // Disabled when foreign currency selected
                      final List<PaymentMethodModel> secondaryMethods;
                      if (_selectedForeignCurrencyId != null) {
                        secondaryMethods = [];
                      } else {
                        final creditMethod = methods
                            .where((m) => m.type == PaymentType.credit)
                            .where(isAllowedByRegister)
                            .firstOrNull;
                        secondaryMethods = <PaymentMethodModel>[
                          ...methods.where((m) => m.type == PaymentType.voucher).where(isAllowedByRegister),
                          if (creditMethod != null && _customer != null && _customer!.credit > 0)
                            creditMethod,
                          ...methods.where((m) => m.type == PaymentType.other).where(isAllowedByRegister),
                        ];
                      }

                      if (!_showOtherPayments) {
                        // Primary view: up to 3 payment methods + "Jiná platba"
                        return Column(
                          children: [
                            for (var i = 0; i < 3; i++) ...[
                              if (i > 0) const SizedBox(height: 8),
                              Expanded(
                                child: i < primaryMethods.length
                                    ? _PaymentMethodButton(
                                        label: primaryMethods[i].name.toUpperCase(),
                                        onPressed: _processing || _remaining <= 0
                                            ? null
                                            : () => _pay(context, primaryMethods[i].id),
                                        onLongPress: _processing || _remaining <= 0 || primaryMethods[i].type != PaymentType.cash
                                            ? null
                                            : () => _pay(context, primaryMethods[i].id, forceTender: true),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Expanded(
                              child: _SideButton(
                                label: l.paymentOtherPayment,
                                onPressed: secondaryMethods.isNotEmpty
                                    ? () => setState(() => _showOtherPayments = true)
                                    : null,
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Secondary view: up to 3 secondary methods + "Zpět"
                        return Column(
                          children: [
                            for (var i = 0; i < 3; i++) ...[
                              if (i > 0) const SizedBox(height: 8),
                              Expanded(
                                child: i < secondaryMethods.length
                                    ? _PaymentMethodButton(
                                        label: (secondaryMethods[i].type == PaymentType.credit
                                            ? l.paymentTypeCredit
                                            : secondaryMethods[i].name).toUpperCase(),
                                        onPressed: _processing || _remaining <= 0
                                            ? null
                                            : secondaryMethods[i].type == PaymentType.credit
                                                ? () => _payWithCredit(context, secondaryMethods[i].id)
                                                : () => _pay(context, secondaryMethods[i].id),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Expanded(
                              child: _SideButton(
                                label: l.wizardBack,
                                onPressed: () => setState(() => _showOtherPayments = false),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildPaymentsList(BuildContext context, List<PaymentModel> payments) {
    final theme = Theme.of(context);
    return FutureBuilder<List<PaymentMethodModel>>(
      future: _paymentMethodsFuture ?? Future.value([]),
      builder: (context, snap) {
        final methods = snap.data ?? [];
        final methodMap = {for (final m in methods) m.id: m.name};

        final parts = <String>[];
        for (final p in payments) {
          final name = methodMap[p.paymentMethodId] ?? '?';
          String amount;
          if (p.foreignCurrencyId != null && p.foreignAmount != null) {
            final fc = _availableForeignCurrencies
                .where((e) => e.$1.currencyId == p.foreignCurrencyId)
                .firstOrNull;
            amount = fc != null
                ? '${formatMoney(p.foreignAmount!, fc.$2)} (× ${p.exchangeRate})'
                : '${p.foreignAmount}';
          } else {
            amount = ref.money(p.amount);
          }
          final tip = p.tipIncludedAmount > 0 ? ' (+${ref.money(p.tipIncludedAmount)})' : '';
          parts.add('$name $amount$tip');
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              parts.join(', '),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const Divider(height: 8),
          ],
        );
      },
    );
  }

  Widget _amountBlock(BuildContext context, String amount, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context, dynamic l) {
    return Column(
      children: [
        for (final (i, entry) in _availableForeignCurrencies.indexed) ...[
          if (i > 0) const SizedBox(height: 8),
          Expanded(
            child: _SideButton(
              label: '${entry.$2.code} (${entry.$2.symbol})',
              onPressed: () {
                setState(() {
                  _selectedForeignCurrencyId = entry.$1.currencyId;
                  _selectedCompanyCurrency = entry.$1;
                  _selectedForeignCurrencyDetail = entry.$2;
                  _showCurrencySelector = false;
                  _customAmount = null;
                  _customForeignAmount = null;
                });
              },
            ),
          ),
        ],
        if (_availableForeignCurrencies.length < 3) ...[
          for (var i = _availableForeignCurrencies.length; i < 3; i++) ...[
            const SizedBox(height: 8),
            const Expanded(child: SizedBox.shrink()),
          ],
        ],
        const SizedBox(height: 8),
        Expanded(
          child: _SideButton(
            label: l.currencySelectorBack,
            onPressed: () => setState(() => _showCurrencySelector = false),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreActions(BuildContext context, dynamic l) {
    return Column(
      children: [
        Expanded(
          child: _SideButton(
            label: l.loyaltyRedeem,
            onPressed: _canRedeemLoyalty ? () => _redeemLoyalty(context) : null,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _SideButton(label: l.paymentEet, onPressed: null)),
        const SizedBox(height: 8),
        const Expanded(child: SizedBox.shrink()),
        const SizedBox(height: 8),
        Expanded(
          child: _SideButton(
            label: l.wizardBack,
            onPressed: () => setState(() => _showMoreActions = false),
          ),
        ),
      ],
    );
  }

  Future<void> _redeemLoyalty(BuildContext context) async {
    if (!_canRedeemLoyalty) return;
    setState(() => _processing = true);
    try {
      final freshCustomer = await ref.read(customerRepositoryProvider)
          .getById(_bill.customerId!, includeDeleted: true);
      if (!context.mounted || freshCustomer == null || freshCustomer.points <= 0) return;

      final result = await showDialog<bool>(
        context: context,
        builder: (_) => DialogLoyaltyRedeem(
          bill: _bill,
          customer: freshCustomer,
          pointValue: _loyaltyPointValue,
        ),
      );
      if (result == true && mounted) {
        final updatedBill = await ref.read(billRepositoryProvider).getById(_bill.id);
        await _loadCustomer();
        if (mounted && updatedBill is Success<BillModel>) {
          _bill = updatedBill.value;
          _customAmount = null;
          _showMoreActions = false;
          // Auto-pay if fully covered by loyalty discount
          if (_bill.totalGross - _bill.paidAmount <= 0) {
            await _recordZeroPayment();
            if (context.mounted) Navigator.pop(context, true);
            return;
          }
          setState(() {});
        }
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _recordZeroPayment() async {
    final methods = await (_paymentMethodsFuture ?? Future.value(<PaymentMethodModel>[]));
    final cashMethod = methods.where((m) => m.type == PaymentType.cash).firstOrNull;
    if (cashMethod == null) return;
    final register = ref.read(activeRegisterProvider).value;
    final session = ref.read(activeRegisterSessionProvider).valueOrNull;
    await ref.read(billRepositoryProvider).recordPayment(
      companyId: _bill.companyId,
      billId: _bill.id,
      paymentMethodId: cashMethod.id,
      currencyId: _bill.currencyId,
      amount: 0,
      userId: ref.read(activeUserProvider)?.id,
      registerId: register?.id,
      registerSessionId: session?.id,
      loyaltyEarnRate: widget.skipLoyaltyEarn ? 0 : _loyaltyEarnRate,
    );
  }

  void _clearForeignCurrency() {
    setState(() {
      _selectedForeignCurrencyId = null;
      _selectedCompanyCurrency = null;
      _selectedForeignCurrencyDetail = null;
      _customAmount = null;
      _customForeignAmount = null;
    });
  }

  int get _remainingInForeign {
    if (_selectedCompanyCurrency == null || _selectedForeignCurrencyDetail == null) return 0;
    final rate = _selectedCompanyCurrency!.exchangeRate;
    if (rate <= 0) return 0;
    final baseCurrency = ref.read(currentCurrencyProvider).value;
    final baseDecimals = baseCurrency?.decimalPlaces ?? 2;
    final baseDivisor = pow(10, baseDecimals);
    final foreignDecimals = _selectedForeignCurrencyDetail!.decimalPlaces;
    final foreignDivisor = foreignDecimals > 0 ? pow(10, foreignDecimals) : 1;
    // Convert remaining (base minor units) to foreign minor units, rounded up
    return (_remaining / baseDivisor / rate * foreignDivisor.toDouble()).ceil();
  }

  int get _foreignPayAmount => _customForeignAmount ?? _remainingInForeign;

  int _foreignToBase(int foreignMinorUnits) {
    if (_selectedCompanyCurrency == null || _selectedForeignCurrencyDetail == null) return 0;
    final rate = _selectedCompanyCurrency!.exchangeRate;
    if (rate <= 0) return 0;
    final baseCurrency = ref.read(currentCurrencyProvider).value;
    final baseDecimals = baseCurrency?.decimalPlaces ?? 2;
    final baseDivisor = pow(10, baseDecimals);
    final foreignDecimals = _selectedForeignCurrencyDetail!.decimalPlaces;
    final foreignDivisor = foreignDecimals > 0 ? pow(10, foreignDecimals) : 1;
    return ((foreignMinorUnits / foreignDivisor.toDouble()) * rate * baseDivisor).round();
  }

  String _formatForeignMoney(int minorUnits) {
    return formatMoney(minorUnits, _selectedForeignCurrencyDetail);
  }

  Future<void> _editAmount(BuildContext context) async {
    if (_selectedForeignCurrencyId != null) {
      // Foreign currency mode — edit in foreign currency
      final result = await showDialog<int>(
        context: context,
        builder: (_) => DialogChangeTotalToPay(
          originalAmount: _remainingInForeign,
          currency: _selectedForeignCurrencyDetail,
        ),
      );
      if (result != null && mounted) {
        setState(() => _customForeignAmount = result);
      }
    } else {
      final result = await showDialog<int>(
        context: context,
        builder: (_) => DialogChangeTotalToPay(originalAmount: _remaining),
      );
      if (result != null && mounted) {
        setState(() => _customAmount = result);
      }
    }
  }

  Future<void> _pay(BuildContext context, String methodId, {bool forceTender = false}) async {
    setState(() => _processing = true);

    if (_remaining <= 0) return;

    // --- Cash tender dialog for cash payments ---
    final methods =
        await (_paymentMethodsFuture ?? Future.value(<PaymentMethodModel>[]));
    if (!context.mounted) return;
    final method = methods.where((m) => m.id == methodId).firstOrNull;
    final isCash = method?.type == PaymentType.cash;

    CashTenderResult? tenderResult;
    if (isCash) {
      final canSkip = !forceTender &&
          ref.read(hasPermissionProvider('payments.skip_cash_dialog'));
      if (!canSkip) {
        final baseCurrency = ref.read(currentCurrencyProvider).value;
        if (baseCurrency == null) {
          setState(() => _processing = false);
          return;
        }

        final payCurrency = _selectedForeignCurrencyDetail ?? baseCurrency;
        tenderResult = await showDialog<CashTenderResult>(
          context: context,
          builder: (_) => DialogCashTender(
            amountDue: _remaining,
            currency: payCurrency,
            baseCurrency: baseCurrency,
            exchangeRate: _selectedForeignCurrencyId != null
                ? _selectedCompanyCurrency!.exchangeRate
                : null,
          ),
        );

        if (!context.mounted) return;
        // tenderResult == null → user dismissed (close button) → cancel payment
        if (tenderResult == null) {
          setState(() => _processing = false);
          return;
        }
        // tenderResult.skipped → "Bez zadání" → proceed without tender evidence
      }
    }

    // Foreign currency payment
    String? foreignCurrencyId;
    int? foreignAmount;
    double? payExchangeRate;
    int effectiveAmount;
    int tipAmount;

    if (_selectedForeignCurrencyId != null) {
      final foreignAmt = _foreignPayAmount;
      final baseAmount = _foreignToBase(foreignAmt);

      effectiveAmount = baseAmount > _remaining ? _remaining : baseAmount;
      tipAmount = baseAmount > _remaining ? baseAmount - _remaining : 0;
      foreignCurrencyId = _selectedForeignCurrencyId;
      foreignAmount = foreignAmt;
      payExchangeRate = _selectedCompanyCurrency!.exchangeRate;
    } else {
      final amount = _payAmount;
      tipAmount = amount > _remaining ? amount - _remaining : 0;
      effectiveAmount = amount > _remaining ? _remaining : amount;
    }

    // Use pre-loaded loyalty earn rate (skip for non-sale bills like credit top-up)
    final loyaltyEarn = _bill.customerId != null && !widget.skipLoyaltyEarn ? _loyaltyEarnRate : 0;

    final repo = ref.read(billRepositoryProvider);
    final register = ref.read(activeRegisterProvider).value;
    final session = ref.read(activeRegisterSessionProvider).valueOrNull;
    final result = await repo.recordPayment(
      companyId: _bill.companyId,
      billId: _bill.id,
      paymentMethodId: methodId,
      currencyId: _bill.currencyId,
      amount: effectiveAmount,
      tipAmount: tipAmount,
      userId: ref.read(activeUserProvider)?.id,
      registerId: register?.id,
      registerSessionId: session?.id,
      loyaltyEarnRate: loyaltyEarn,
      foreignCurrencyId: foreignCurrencyId,
      foreignAmount: foreignAmount,
      exchangeRate: payExchangeRate,
    );

    if (!context.mounted) return;

    if (result is Success<BillModel>) {
      // Create CashMovement for foreign currency change returned in base currency
      if (tenderResult != null &&
          _selectedForeignCurrencyId != null &&
          tenderResult.changeAmount > 0) {
        final user = ref.read(activeUserProvider);
        if (session != null && user != null) {
          final l = context.l10n;
          await ref.read(cashMovementRepositoryProvider).create(
                companyId: _bill.companyId,
                registerSessionId: session.id,
                userId: user.id,
                type: CashMovementType.withdrawal,
                amount: tenderResult.changeAmount,
                reason: l.cashTenderChangeReason(
                    _selectedForeignCurrencyDetail!.code),
              );
        }
      }

      if (!context.mounted) return;

      final updatedBill = result.value;
      final fullyPaid = updatedBill.paidAmount >= updatedBill.totalGross;

      if (fullyPaid) {
        Navigator.pop(context, true);
      } else {
        // Stay open — update state for next payment
        setState(() {
          _bill = updatedBill;
          _customAmount = null;
          _customForeignAmount = null;
          _processing = false;
        });
      }
    } else {
      setState(() => _processing = false);
    }
  }

  Future<void> _payWithCredit(BuildContext context, String creditMethodId) async {
    if (_customer == null || _remaining <= 0) return;
    setState(() => _processing = true);

    final creditAvailable = _customer!.credit;
    final effectiveAmount = creditAvailable < _remaining ? creditAvailable : _remaining;

    // Deduct credit from customer
    final customerRepo = ref.read(customerRepositoryProvider);
    final creditResult = await customerRepo.adjustCredit(
      customerId: _customer!.id,
      delta: -effectiveAmount,
      processedByUserId: ref.read(activeUserProvider)?.id ?? '',
      orderId: _bill.id,
      reference: _bill.billNumber,
    );
    if (creditResult is! Success) {
      if (mounted) setState(() => _processing = false);
      return;
    }
    if (!mounted) return;

    // Record the payment
    final repo = ref.read(billRepositoryProvider);
    final register2 = ref.read(activeRegisterProvider).value;
    final session2 = ref.read(activeRegisterSessionProvider).valueOrNull;
    final result = await repo.recordPayment(
      companyId: _bill.companyId,
      billId: _bill.id,
      paymentMethodId: creditMethodId,
      currencyId: _bill.currencyId,
      amount: effectiveAmount,
      tipAmount: 0,
      userId: ref.read(activeUserProvider)?.id,
      registerId: register2?.id,
      registerSessionId: session2?.id,
    );

    if (!context.mounted) return;

    if (result is Success<BillModel>) {
      final updatedBill = result.value;
      final fullyPaid = updatedBill.paidAmount >= updatedBill.totalGross;

      if (fullyPaid) {
        Navigator.pop(context, true);
      } else {
        // Reload customer to get updated credit
        await _loadCustomer();
        if (!mounted) return;
        setState(() {
          _bill = updatedBill;
          _customAmount = null;
          _processing = false;
        });
      }
    } else {
      setState(() => _processing = false);
    }
  }

}

class _SideButton extends StatelessWidget {
  const _SideButton({required this.label, required this.onPressed, this.color, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        : Text(
            label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          );
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: color != null
          ? FilledButton(
              style: FilledButton.styleFrom(backgroundColor: color),
              onPressed: onPressed,
              child: child,
            )
          : FilledButton.tonal(
              onPressed: onPressed,
              child: child,
            ),
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  const _PaymentMethodButton({required this.label, required this.onPressed, this.onLongPress});
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      style: PosButtonStyles.confirm(context),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: onLongPress != null
          ? GestureDetector(
              onLongPress: onLongPress,
              child: button,
            )
          : button,
    );
  }
}
