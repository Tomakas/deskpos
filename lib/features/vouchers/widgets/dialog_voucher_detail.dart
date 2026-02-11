import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/data/enums/voucher_status.dart';
import '../../../core/data/enums/voucher_type.dart';
import '../../../core/data/models/voucher_model.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class DialogVoucherDetail extends ConsumerWidget {
  const DialogVoucherDetail({super.key, required this.voucher});
  final VoucherModel voucher;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d.M.yyyy HH:mm', 'cs');

    return Dialog(
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  voucher.code,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _row(l.filterTitle, _typeLabel(voucher.type, l)),
              _row(l.reservationStatus, _statusLabel(voucher.status, l)),
              _row(
                l.voucherValue,
                voucher.type == VoucherType.discount && voucher.discountType?.name == 'percent'
                    ? '${voucher.value / 100}%'
                    : '${voucher.value ~/ 100} Kč',
              ),
              if (voucher.type == VoucherType.discount) ...[
                _row(l.voucherDiscount, voucher.discountScope?.name ?? '-'),
                _row(l.voucherMaxUses, '${voucher.maxUses}'),
              ],
              _row(l.voucherUsedCount, '${voucher.usedCount}/${voucher.maxUses}'),
              _row(l.voucherExpires,
                  voucher.expiresAt != null ? dateFormat.format(voucher.expiresAt!) : '-'),
              if (voucher.redeemedAt != null)
                _row('Redeemed', dateFormat.format(voucher.redeemedAt!)),
              if (voucher.note != null && voucher.note!.isNotEmpty)
                _row(l.voucherNote, voucher.note!),
              _row('ID', voucher.id),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l.actionClose),
                      ),
                    ),
                  ),
                  if (voucher.status == VoucherStatus.active) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => _cancelVoucher(context, ref),
                          child: Text(l.voucherCancel),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
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

  String _typeLabel(VoucherType type, dynamic l) => switch (type) {
        VoucherType.gift => l.voucherTypeGift,
        VoucherType.deposit => l.voucherTypeDeposit,
        VoucherType.discount => l.voucherTypeDiscount,
      };

  String _statusLabel(VoucherStatus status, dynamic l) => switch (status) {
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
