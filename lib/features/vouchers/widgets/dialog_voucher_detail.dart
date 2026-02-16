import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/voucher_status.dart';
import '../../../core/data/enums/voucher_type.dart';
import '../../../core/data/models/voucher_model.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

class DialogVoucherDetail extends ConsumerWidget {
  const DialogVoucherDetail({super.key, required this.voucher});
  final VoucherModel voucher;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return PosDialogShell(
      title: voucher.code,
      titleStyle: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      maxWidth: 400,
      padding: const EdgeInsets.all(20),
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
          _row(l.voucherDiscount, voucher.discountScope?.name ?? '-'),
          _row(l.voucherMaxUses, '${voucher.maxUses}'),
        ],
        _row(l.voucherUsedCount, '${voucher.usedCount}/${voucher.maxUses}'),
        _row(l.voucherExpires,
            voucher.expiresAt != null ? ref.fmtDateTime(voucher.expiresAt!) : '-'),
        if (voucher.redeemedAt != null)
          _row(l.voucherRedeemedAt, ref.fmtDateTime(voucher.redeemedAt!)),
        if (voucher.note != null && voucher.note!.isNotEmpty)
          _row(l.voucherNote, voucher.note!),
        _row(l.voucherIdLabel, voucher.id),
        const SizedBox(height: 16),
        PosDialogActions(
          spacing: 12,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionClose),
            ),
            if (voucher.status == VoucherStatus.active)
              FilledButton(
                style: PosButtonStyles.destructiveFilled(context),
                onPressed: () => _cancelVoucher(context, ref),
                child: Text(l.voucherCancel),
              ),
          ],
        ),
      ],
    );
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

  Future<void> _cancelVoucher(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final updated = voucher.copyWith(
      status: VoucherStatus.cancelled,
      updatedAt: now,
    );
    final result = await ref.read(voucherRepositoryProvider).update(updated);
    if (result is Success && context.mounted) {
      Navigator.pop(context);
    }
  }
}
