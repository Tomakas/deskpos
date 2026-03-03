import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/data/enums/enums.dart';
import '../../../core/data/models/voucher_model.dart';
import '../../../core/data/repositories/voucher_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

const _uuid = Uuid();

/// Handles voucher-domain AI tool calls.
class AiVoucherToolHandler {
  AiVoucherToolHandler({required VoucherRepository voucherRepo})
      : _voucherRepo = voucherRepo;

  final VoucherRepository _voucherRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        'list_vouchers' => _listVouchers(args, companyId),
        'get_voucher' => _getVoucher(args, companyId),
        'create_voucher' => _createVoucher(args, companyId),
        'update_voucher' => _updateVoucher(args, companyId),
        'delete_voucher' => _deleteVoucher(args, companyId),
        _ => AiCommandError('Unknown voucher tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Voucher tool handler error', tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  Future<AiCommandResult> _listVouchers(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final typeFilter = args['type'] != null
        ? VoucherType.values.byName(args['type'] as String)
        : null;
    final statusFilter = args['status'] != null
        ? VoucherStatus.values.byName(args['status'] as String)
        : null;

    final vouchers = await _voucherRepo
        .watchFiltered(companyId, type: typeFilter, status: statusFilter)
        .first;

    final json = vouchers
        .take(1000)
        .map((v) => {
              'id': v.id,
              'code': v.code,
              'type': v.type.name,
              'status': v.status.name,
              'value': v.value,
              'max_uses': v.maxUses,
              'used_count': v.usedCount,
              'expires_at': v.expiresAt?.toIso8601String(),
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _getVoucher(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final voucher = await _voucherRepo.getById(id, companyId: companyId);
    if (voucher == null) return const AiCommandError('Voucher not found');
    return AiCommandSuccess(jsonEncode({
      'id': voucher.id,
      'code': voucher.code,
      'type': voucher.type.name,
      'status': voucher.status.name,
      'value': voucher.value,
      'discount_type': voucher.discountType?.name,
      'discount_scope': voucher.discountScope?.name,
      'item_id': voucher.itemId,
      'category_id': voucher.categoryId,
      'min_order_value': voucher.minOrderValue,
      'max_uses': voucher.maxUses,
      'used_count': voucher.usedCount,
      'customer_id': voucher.customerId,
      'expires_at': voucher.expiresAt?.toIso8601String(),
      'note': voucher.note,
    }));
  }

  Future<AiCommandResult> _createVoucher(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final value = (args['value'] as num).toInt();
    if (value <= 0) {
      return const AiCommandError('Voucher value must be positive');
    }

    final now = DateTime.now();
    final voucherType = VoucherType.values.byName(args['type'] as String);
    final code =
        args['code'] as String? ?? _voucherRepo.generateCode(voucherType);

    final model = VoucherModel(
      id: _uuid.v7(),
      companyId: companyId,
      code: code,
      type: voucherType,
      status: VoucherStatus.active,
      value: value,
      discountType: args['discount_type'] != null
          ? DiscountType.values.byName(args['discount_type'] as String)
          : null,
      discountScope: args['discount_scope'] != null
          ? VoucherDiscountScope.values.byName(
              args['discount_scope'] as String)
          : null,
      itemId: args['item_id'] as String?,
      categoryId: args['category_id'] as String?,
      minOrderValue: (args['min_order_value'] as num?)?.toInt(),
      maxUses: (args['max_uses'] as num?)?.toInt() ?? 1,
      customerId: args['customer_id'] as String?,
      expiresAt: args['expires_at'] != null
          ? DateTime.parse(args['expires_at'] as String)
          : null,
      note: args['note'] as String?,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _voucherRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Voucher "${value.code}" created (type: ${value.type.name}, value: ${value.value})',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateVoucher(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final existing = await _voucherRepo.getById(id, companyId: companyId);
    if (existing == null) return const AiCommandError('Voucher not found');

    final updated = existing.copyWith(
      status: args['status'] != null
          ? VoucherStatus.values.byName(args['status'] as String)
          : existing.status,
      discountType: args['discount_type'] != null
          ? DiscountType.values.byName(args['discount_type'] as String)
          : existing.discountType,
      discountScope: args['discount_scope'] != null
          ? VoucherDiscountScope.values.byName(
              args['discount_scope'] as String)
          : existing.discountScope,
      itemId: args.containsKey('item_id')
          ? args['item_id'] as String?
          : existing.itemId,
      categoryId: args.containsKey('category_id')
          ? args['category_id'] as String?
          : existing.categoryId,
      minOrderValue: args.containsKey('min_order_value')
          ? (args['min_order_value'] as num?)?.toInt()
          : existing.minOrderValue,
      maxUses: (args['max_uses'] as num?)?.toInt() ?? existing.maxUses,
      expiresAt: args.containsKey('expires_at')
          ? (args['expires_at'] != null
              ? DateTime.parse(args['expires_at'] as String)
              : null)
          : existing.expiresAt,
      note: args.containsKey('note')
          ? args['note'] as String?
          : existing.note,
      updatedAt: DateTime.now(),
    );
    final result = await _voucherRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Voucher "${value.code}" updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteVoucher(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final existing = await _voucherRepo.getById(id, companyId: companyId);
    if (existing == null) return const AiCommandError('Voucher not found');
    final result = await _voucherRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess('Voucher deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }
}
