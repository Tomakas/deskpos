import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/payment_type.dart';
import '../../../core/data/models/bill_model.dart';
import '../../../core/data/models/company_currency_model.dart';
import '../../../core/data/models/currency_model.dart';
import '../../../core/data/models/customer_model.dart';
import '../../../core/data/models/payment_method_model.dart';
import '../../../core/data/models/payment_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import 'dialog_change_total.dart';

class DialogPayment extends ConsumerStatefulWidget {
  const DialogPayment({
    super.key,
    required this.bill,
    this.tableName,
  });
  final BillModel bill;
  final String? tableName;

  @override
  ConsumerState<DialogPayment> createState() => _DialogPaymentState();
}

class _DialogPaymentState extends ConsumerState<DialogPayment> {
  bool _processing = false;
  bool _printReceipt = true;
  bool _showOtherPayments = false;
  bool _showCurrencySelector = false;
  late BillModel _bill;
  int? _customAmount;
  int? _customForeignAmount;
  CustomerModel? _customer;
  Future<List<PaymentMethodModel>>? _paymentMethodsFuture;
  Stream<List<PaymentMethodModel>>? _paymentMethodsStream;

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
          maxHeight: (MediaQuery.sizeOf(context).height - 24).clamp(0, 270),
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
                          Expanded(child: _SideButton(label: l.paymentEet, onPressed: null)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _SideButton(
                              label: l.paymentMoreActions,
                              onPressed: null,
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
                      if (_customer != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_customer!.firstName} ${_customer!.lastName} | ${l.loyaltyCustomerInfo(
                              _customer!.points,
                              ref.money(_customer!.credit),
                            )}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Already-made payments
                      StreamBuilder<List<PaymentModel>>(
                        stream: ref.watch(paymentRepositoryProvider).watchByBill(_bill.id),
                        builder: (context, snap) {
                          final payments = snap.data ?? [];
                          if (payments.isEmpty) return const SizedBox.shrink();
                          return _buildPaymentsList(context, payments);
                        },
                      ),
                      const Spacer(),
                      // Remaining amount
                      if (_selectedForeignCurrencyId != null) ...[
                        // Foreign currency mode
                        Text(
                          ref.money(_remaining),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
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
                        Text(
                          ref.money(_remaining),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        if (_customAmount! != _remaining)
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
                        const SizedBox(height: 4),
                        _amountBlock(
                          context,
                          ref.money(_customAmount!),
                          onTap: _remaining > 0 ? () => _editAmount(context) : null,
                        ),
                      ] else ...[
                        _amountBlock(
                          context,
                          ref.money(_remaining),
                          onTap: _remaining > 0 ? () => _editAmount(context) : null,
                        ),
                      ],
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => setState(() => _printReceipt = !_printReceipt),
                        child: Text(
                          '${l.paymentPrintReceipt}: ${_printReceipt ? l.paymentPrintYes : l.paymentPrintNo}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
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

        return Column(
          children: [
            for (final p in payments)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      methodMap[p.paymentMethodId] ?? '?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 12),
                    if (p.foreignCurrencyId != null && p.foreignAmount != null) ...[
                      // Show foreign currency amount
                      Builder(builder: (context) {
                        final fc = _availableForeignCurrencies
                            .where((e) => e.$1.currencyId == p.foreignCurrencyId)
                            .firstOrNull;
                        final foreignStr = fc != null
                            ? formatMoney(p.foreignAmount!, fc.$2)
                            : '${p.foreignAmount}';
                        return Text(
                          '$foreignStr (× ${p.exchangeRate})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ] else ...[
                      Text(
                        ref.money(p.amount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (p.tipIncludedAmount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(+${ref.money(p.tipIncludedAmount)})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const Divider(),
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

  Future<void> _pay(BuildContext context, String methodId) async {
    setState(() => _processing = true);

    if (_remaining <= 0) return;

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

    // Load loyalty settings for auto-earn
    int loyaltyEarn = 0;
    final company = ref.read(currentCompanyProvider);
    if (company != null && _bill.customerId != null) {
      final settingsRepo = ref.read(companySettingsRepositoryProvider);
      final settings = await settingsRepo.getOrCreate(company.id);
      if (!mounted) return;
      loyaltyEarn = settings.loyaltyEarnRate;
    }

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
  const _SideButton({required this.label, required this.onPressed, this.color});
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: color != null
          ? FilledButton(
              style: FilledButton.styleFrom(backgroundColor: color),
              onPressed: onPressed,
              child: Text(
                label,
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            )
          : FilledButton.tonal(
              onPressed: onPressed,
              child: Text(
                label,
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  const _PaymentMethodButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: FilledButton(
        style: PosButtonStyles.confirm(context),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
