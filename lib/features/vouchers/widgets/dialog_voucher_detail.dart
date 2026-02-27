import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/voucher_discount_scope.dart';
import '../../../core/data/enums/voucher_status.dart';
import '../../../core/data/enums/voucher_type.dart';
import '../../../core/data/models/voucher_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/printing_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/printing/voucher_pdf_builder.dart';
import '../../../core/utils/file_opener.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

class DialogVoucherDetail extends ConsumerStatefulWidget {
  const DialogVoucherDetail({super.key, required this.voucher});
  final VoucherModel voucher;

  @override
  ConsumerState<DialogVoucherDetail> createState() => _DialogVoucherDetailState();
}

class _DialogVoucherDetailState extends ConsumerState<DialogVoucherDetail> {
  String? _scopeTargetName;
  String? _createdByName;
  bool _printing = false;

  @override
  void initState() {
    super.initState();
    _loadAsyncData();
  }

  Future<void> _loadAsyncData() async {
    final v = widget.voucher;

    // Load scope target name (product / category)
    if (v.type == VoucherType.discount) {
      String? name;
      if (v.discountScope == VoucherDiscountScope.product && v.itemId != null) {
        final item = await ref.read(itemRepositoryProvider).getById(v.itemId!, includeDeleted: true);
        name = item?.name;
      } else if (v.discountScope == VoucherDiscountScope.category && v.categoryId != null) {
        final cat = await ref.read(categoryRepositoryProvider).getById(v.categoryId!, includeDeleted: true);
        name = cat?.name;
      }
      if (name != null && mounted) {
        setState(() => _scopeTargetName = name);
      }
    }

    // Load created-by user name
    if (v.createdByUserId != null) {
      final user = await ref.read(userRepositoryProvider).getById(v.createdByUserId!, includeDeleted: true);
      if (user != null && mounted) {
        setState(() => _createdByName = user.fullName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final voucher = widget.voucher;
    final l = context.l10n;
    final theme = Theme.of(context);

    return PosDialogShell(
      showCloseButton: true,
      title: voucher.code,
      titleStyle: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      maxWidth: 400,
      padding: const EdgeInsets.all(20),
      scrollable: true,
      children: [
        _row(l.filterTitle, _typeLabel(voucher.type, l)),
        _row(l.reservationStatus, _statusLabel(voucher.status, l)),
        _row(
          l.voucherValue,
          voucher.type == VoucherType.discount && voucher.discountType?.name == 'percent'
              ? '${voucher.value / 100}%'
              : ref.money(voucher.value),
        ),
        if (voucher.type == VoucherType.discount) ...[
          _row(l.voucherDiscount, _scopeLabel(voucher, l)),
          _row(l.voucherMaxUses, '${voucher.maxUses}'),
        ],
        _row(l.voucherUsedCount, '${voucher.usedCount}/${voucher.maxUses}'),
        _row(l.voucherExpires,
            voucher.expiresAt != null ? ref.fmtDateTime(voucher.expiresAt!) : '-'),
        if (voucher.redeemedAt != null)
          _row(l.voucherRedeemedAt, ref.fmtDateTime(voucher.redeemedAt!)),
        _row(l.voucherCreatedAt, ref.fmtDateTime(voucher.createdAt)),
        if (_createdByName != null)
          _row(l.voucherCreatedBy, _createdByName!),
        _row(l.voucherNote, voucher.note ?? '-'),
        const SizedBox(height: 16),
      ],
      bottomActions: PosDialogActions(
        leading: OutlinedButton.icon(
          onPressed: _printing ? null : () => _printVoucher(context),
          icon: const Icon(Icons.print_outlined),
          label: Text(l.voucherPrint),
        ),
        actions: [
          if (voucher.status == VoucherStatus.active)
            FilledButton(
              style: PosButtonStyles.destructiveFilled(context),
              onPressed: () => _cancelVoucher(context, ref),
              child: Text(l.voucherCancel),
            ),
        ],
      ),
    );
  }

  String _scopeLabel(VoucherModel voucher, AppLocalizations l) {
    final scopeName = switch (voucher.discountScope) {
      VoucherDiscountScope.bill => l.voucherScopeBill,
      VoucherDiscountScope.product => l.voucherScopeProduct,
      VoucherDiscountScope.category => l.voucherScopeCategory,
      null => '-',
    };
    if (_scopeTargetName != null) {
      return '$scopeName: $_scopeTargetName';
    }
    return scopeName;
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _typeLabel(VoucherType type, AppLocalizations l) => switch (type) {
        VoucherType.gift => l.voucherTypeGift,
        VoucherType.deposit => l.voucherTypeDeposit,
        VoucherType.discount => l.voucherTypeDiscount,
      };

  String _statusLabel(VoucherStatus status, AppLocalizations l) => switch (status) {
        VoucherStatus.active => l.voucherStatusActive,
        VoucherStatus.redeemed => l.voucherStatusRedeemed,
        VoucherStatus.expired => l.voucherStatusExpired,
        VoucherStatus.cancelled => l.voucherStatusCancelled,
      };

  Future<void> _printVoucher(BuildContext context) async {
    setState(() => _printing = true);
    try {
      final voucher = widget.voucher;
      final l = context.l10n;
      final locale = ref.read(appLocaleProvider).value ?? 'cs';
      final company = ref.read(currentCompanyProvider);

      String valueLine;
      if (voucher.type == VoucherType.discount && voucher.discountType?.name == 'percent') {
        valueLine = '${voucher.value / 100}%';
      } else {
        valueLine = ref.read(currentCurrencyProvider).value != null
            ? formatMoney(voucher.value, ref.read(currentCurrencyProvider).value, appLocale: locale)
            : '${voucher.value}';
      }

      String? scopeLine;
      if (voucher.type == VoucherType.discount) {
        scopeLine = _scopeLabel(voucher, l);
      }

      final data = VoucherPdfData(
        code: voucher.code,
        typeName: _typeLabel(voucher.type, l),
        valueLine: valueLine,
        scopeLine: scopeLine,
        maxUses: voucher.type == VoucherType.discount ? '${voucher.maxUses}' : null,
        expiresAt: voucher.expiresAt != null
            ? formatDateForPrint(voucher.expiresAt!, locale)
            : null,
        note: voucher.note,
        companyName: company?.name,
      );

      final labels = VoucherPdfLabels(
        title: l.voucherPdfTitle,
        type: l.filterTitle,
        value: l.voucherValue,
        scope: l.voucherDiscount,
        maxUses: l.voucherMaxUses,
        expires: l.voucherExpires,
        note: l.voucherNote,
      );

      final bytes = await ref.read(printingServiceProvider)
          .generateVoucherPdf(data, labels);
      await FileOpener.shareBytes('voucher_${voucher.code}.pdf', bytes);
    } catch (e, s) {
      AppLogger.error('Failed to print voucher', error: e, stackTrace: s);
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  Future<void> _cancelVoucher(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final updated = widget.voucher.copyWith(
      status: VoucherStatus.cancelled,
      updatedAt: now,
    );
    final result = await ref.read(voucherRepositoryProvider).update(updated);
    if (result is Success && context.mounted) {
      Navigator.pop(context);
    }
  }
}
