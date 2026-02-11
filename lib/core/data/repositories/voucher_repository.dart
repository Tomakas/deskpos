import 'dart:math';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../enums/voucher_status.dart';
import '../enums/voucher_type.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/bill_model.dart';
import '../models/voucher_model.dart';
import '../result.dart';
import 'base_company_scoped_repository.dart';

class VoucherRepository
    extends BaseCompanyScopedRepository<$VouchersTable, Voucher, VoucherModel> {
  VoucherRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$VouchersTable, Voucher> get table => db.vouchers;

  @override
  String get entityName => 'voucher';

  @override
  String get supabaseTableName => 'vouchers';

  @override
  VoucherModel fromEntity(Voucher e) => voucherFromEntity(e);

  @override
  Insertable<Voucher> toCompanion(VoucherModel m) => voucherToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(VoucherModel m) => voucherToSupabaseJson(m);

  @override
  Expression<bool> whereId($VouchersTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($VouchersTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($VouchersTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.desc(t.createdAt)];

  @override
  Insertable<Voucher> toUpdateCompanion(VoucherModel m) => VouchersCompanion(
        status: Value(m.status),
        value: Value(m.value),
        discountType: Value(m.discountType),
        discountScope: Value(m.discountScope),
        itemId: Value(m.itemId),
        categoryId: Value(m.categoryId),
        minOrderValue: Value(m.minOrderValue),
        maxUses: Value(m.maxUses),
        usedCount: Value(m.usedCount),
        customerId: Value(m.customerId),
        expiresAt: Value(m.expiresAt),
        redeemedAt: Value(m.redeemedAt),
        redeemedOnBillId: Value(m.redeemedOnBillId),
        sourceBillId: Value(m.sourceBillId),
        note: Value(m.note),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<Voucher> toDeleteCompanion(DateTime now) => VouchersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  /// Find voucher by code
  Future<VoucherModel?> getByCode(String companyId, String code) async {
    final entity = await (db.select(db.vouchers)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.code.equals(code) &
              t.deletedAt.isNull()))
        .getSingleOrNull();
    return entity == null ? null : voucherFromEntity(entity);
  }

  /// Validate voucher for bill redemption
  Future<Result<VoucherModel>> validateForBill(
    String code,
    String companyId,
    BillModel bill,
  ) async {
    final voucher = await getByCode(companyId, code);
    if (voucher == null) {
      return const Failure('voucherInvalid');
    }
    if (voucher.status != VoucherStatus.active) {
      return const Failure('voucherAlreadyUsed');
    }
    if (voucher.expiresAt != null && voucher.expiresAt!.isBefore(DateTime.now())) {
      return const Failure('voucherExpiredError');
    }
    if (voucher.usedCount >= voucher.maxUses) {
      return const Failure('voucherAlreadyUsed');
    }
    if (voucher.customerId != null && voucher.customerId != bill.customerId) {
      return const Failure('voucherCustomerMismatch');
    }
    if (voucher.minOrderValue != null && bill.subtotalGross < voucher.minOrderValue!) {
      return const Failure('voucherMinOrderNotMet');
    }
    return Success(voucher);
  }

  /// Mark voucher as redeemed
  Future<Result<VoucherModel>> redeem(String voucherId, String billId) async {
    try {
      final now = DateTime.now();
      final entity = await (db.select(db.vouchers)
            ..where((t) => t.id.equals(voucherId)))
          .getSingle();
      final current = voucherFromEntity(entity);

      final newUsedCount = current.usedCount + 1;
      final newStatus = newUsedCount >= current.maxUses
          ? VoucherStatus.redeemed
          : current.status;

      final updated = current.copyWith(
        usedCount: newUsedCount,
        status: newStatus,
        redeemedAt: now,
        redeemedOnBillId: billId,
        updatedAt: now,
      );

      return update(updated);
    } catch (e) {
      return Failure('Failed to redeem voucher: $e');
    }
  }

  /// Generate unique voucher code
  String generateCode(VoucherType type) {
    const chars = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
    final rng = Random.secure();
    String block() => List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join();
    final prefix = switch (type) {
      VoucherType.gift => 'GIFT',
      VoucherType.deposit => 'DEP',
      VoucherType.discount => 'DISC',
    };
    return '$prefix-${block()}-${block()}';
  }

  /// Watch vouchers by status
  Stream<List<VoucherModel>> watchByStatus(String companyId, VoucherStatus status) {
    return (db.select(db.vouchers)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.status.equals(status.name) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(voucherFromEntity).toList());
  }

  /// Watch vouchers optionally filtered by type and/or status
  Stream<List<VoucherModel>> watchFiltered(
    String companyId, {
    VoucherType? type,
    VoucherStatus? status,
  }) {
    return (db.select(db.vouchers)
          ..where((t) {
            var expr = t.companyId.equals(companyId) & t.deletedAt.isNull();
            if (type != null) {
              expr = expr & t.type.equals(type.name);
            }
            if (status != null) {
              expr = expr & t.status.equals(status.name);
            }
            return expr;
          })
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(voucherFromEntity).toList());
  }
}
