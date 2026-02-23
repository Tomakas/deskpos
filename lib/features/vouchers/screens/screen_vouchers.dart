import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/voucher_status.dart';
import '../../../core/data/enums/voucher_type.dart';
import '../../../core/data/models/voucher_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_table.dart';
import '../widgets/dialog_voucher_create.dart';
import '../widgets/dialog_voucher_detail.dart';

class ScreenVouchers extends ConsumerStatefulWidget {
  const ScreenVouchers({super.key});

  @override
  ConsumerState<ScreenVouchers> createState() => _ScreenVouchersState();
}

class _ScreenVouchersState extends ConsumerState<ScreenVouchers> {
  VoucherType? _typeFilter;
  VoucherStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.vouchersTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: () => _createVoucher(context),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.voucherCreate),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Type filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                for (final entry in {
                  null: l.voucherFilterAll,
                  VoucherType.gift: l.voucherTypeGift,
                  VoucherType.deposit: l.voucherTypeDeposit,
                  VoucherType.discount: l.voucherTypeDiscount,
                }.entries) ...[
                  if (entry.key != null || entry == {null: l.voucherFilterAll}.entries.first)
                    const SizedBox(width: 0),
                  if (entry.key == null && _typeFilter != null ||
                      entry.key != null && entry.key != _typeFilter)
                    const SizedBox(width: 0),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FilterChip(
                        label: SizedBox(
                          width: double.infinity,
                          child: Text(entry.value, textAlign: TextAlign.center),
                        ),
                        selected: _typeFilter == entry.key,
                        onSelected: (_) => setState(() => _typeFilter = entry.key),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          // Status filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final entry in {
                  null: l.voucherFilterAll,
                  VoucherStatus.active: l.voucherStatusActive,
                  VoucherStatus.redeemed: l.voucherStatusRedeemed,
                  VoucherStatus.expired: l.voucherStatusExpired,
                }.entries) ...[
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FilterChip(
                        label: SizedBox(
                          width: double.infinity,
                          child: Text(entry.value, textAlign: TextAlign.center),
                        ),
                        selected: _statusFilter == entry.key,
                        onSelected: (_) => setState(() => _statusFilter = entry.key),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Voucher table
          Expanded(
            child: StreamBuilder<List<VoucherModel>>(
              stream: ref.watch(voucherRepositoryProvider).watchFiltered(
                    company.id,
                    type: _typeFilter,
                    status: _statusFilter,
                  ),
              builder: (context, snap) {
                final vouchers = snap.data ?? [];
                return PosTable<VoucherModel>(
                  columns: _buildColumns(l),
                  items: vouchers,
                  onRowTap: (v) => _showDetail(context, v),
                  emptyMessage: l.voucherFilterAll,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<PosColumn<VoucherModel>> _buildColumns(AppLocalizations l) {
    return [
      PosColumn<VoucherModel>(
        label: l.voucherCode,
        flex: 2,
        cellBuilder: (v) => Text(v.code, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      PosColumn<VoucherModel>(
        label: l.filterTitle,
        flex: 1,
        cellBuilder: (v) => Text(_typeLabel(v.type, l)),
      ),
      PosColumn<VoucherModel>(
        label: l.voucherValue,
        flex: 1,
        numeric: true,
        cellBuilder: (v) => v.type == VoucherType.discount
            ? Text(
                v.discountType?.name == 'percent'
                    ? '${v.value / 100}%'
                    : ref.money(v.value),
                textAlign: TextAlign.right,
              )
            : Text(ref.money(v.value), textAlign: TextAlign.right),
      ),
      PosColumn<VoucherModel>(
        label: l.reservationStatus,
        flex: 1,
        headerAlign: TextAlign.center,
        cellBuilder: (v) => Text(_statusLabel(v.status, l), textAlign: TextAlign.center),
      ),
      PosColumn<VoucherModel>(
        label: l.voucherCreatedAt,
        flex: 1,
        cellBuilder: (v) => Text(ref.fmtDate(v.createdAt)),
      ),
      PosColumn<VoucherModel>(
        label: l.voucherExpires,
        flex: 1,
        cellBuilder: (v) =>
            Text(v.expiresAt != null ? ref.fmtDate(v.expiresAt!) : '-'),
      ),
      PosColumn<VoucherModel>(
        label: l.voucherUsedCount,
        flex: 1,
        headerAlign: TextAlign.center,
        cellBuilder: (v) => Text('${v.usedCount}/${v.maxUses}', textAlign: TextAlign.center),
      ),
      PosColumn<VoucherModel>(
        label: l.voucherNote,
        flex: 2,
        cellBuilder: (v) => Text(v.note ?? '', overflow: TextOverflow.ellipsis),
      ),
    ];
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

  Future<void> _createVoucher(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const DialogVoucherCreate(),
    );
  }

  void _showDetail(BuildContext context, VoucherModel voucher) {
    showDialog(
      context: context,
      builder: (_) => DialogVoucherDetail(voucher: voucher),
    );
  }
}
