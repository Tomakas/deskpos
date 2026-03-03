import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

/// Handles statistics/analytics AI tool calls using aggregate queries.
class AiStatsToolHandler {
  AiStatsToolHandler({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        'get_sales_summary' => _getSalesSummary(args, companyId),
        'get_revenue_summary' => _getRevenueSummary(args, companyId),
        'get_tips_summary' => _getTipsSummary(args, companyId),
        'get_orders_summary' => _getOrdersSummary(args, companyId),
        'get_shifts_summary' => _getShiftsSummary(args, companyId),
        'get_register_sessions' => _getRegisterSessions(args, companyId),
        _ => AiCommandError('Unknown stats tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Stats tool handler error',
          tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  DateTime _since(Map<String, dynamic> args) {
    final days = (args['days'] as num?)?.toInt() ?? 30;
    return DateTime.now().subtract(Duration(days: days));
  }

  // ---------------------------------------------------------------------------
  // Sales by item (quantity + revenue)
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _getSalesSummary(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final since = _since(args);
    final oi = _db.orderItems;
    final qtySum = oi.quantity.sum();
    final revenueSum =
        (oi.salePriceAtt.dartCast<double>() * oi.quantity).sum();
    final query = _db.selectOnly(oi)
      ..addColumns([oi.itemId, oi.itemName, qtySum, revenueSum])
      ..where(
        oi.companyId.equals(companyId) &
            oi.deletedAt.isNull() &
            oi.createdAt.isBiggerOrEqualValue(since),
      )
      ..groupBy([oi.itemId, oi.itemName])
      ..orderBy([OrderingTerm.desc(qtySum)]);

    final rows = await query.get();
    final json = rows.map((row) {
      return {
        'item_id': row.read(oi.itemId),
        'item_name': row.read(oi.itemName),
        'total_quantity': row.read(qtySum),
        'total_revenue': row.read(revenueSum)?.round(),
      };
    }).toList();

    return AiCommandSuccess(jsonEncode({
      'period_days': args['days'] ?? 30,
      'items': json,
    }));
  }

  // ---------------------------------------------------------------------------
  // Revenue summary (bills aggregated)
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _getRevenueSummary(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final since = _since(args);
    final b = _db.bills;

    final totalGrossSum = b.totalGross.sum();
    final taxSum = b.taxTotal.sum();
    final discountSum = b.discountAmount.sum();
    final billCount = b.id.count();
    final guestSum = b.numberOfGuests.sum();

    final query = _db.selectOnly(b)
      ..addColumns([totalGrossSum, taxSum, discountSum, billCount, guestSum])
      ..where(
        b.companyId.equals(companyId) &
            b.deletedAt.isNull() &
            b.status.equals('paid') &
            b.closedAt.isBiggerOrEqualValue(since),
      );

    final row = await query.getSingle();

    return AiCommandSuccess(jsonEncode({
      'period_days': args['days'] ?? 30,
      'total_revenue': row.read(totalGrossSum) ?? 0,
      'total_tax': row.read(taxSum) ?? 0,
      'total_discounts': row.read(discountSum) ?? 0,
      'bill_count': row.read(billCount) ?? 0,
      'guest_count': row.read(guestSum) ?? 0,
    }));
  }

  // ---------------------------------------------------------------------------
  // Tips summary (from payments)
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _getTipsSummary(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final since = _since(args);
    final p = _db.payments;

    final tipSum = p.tipIncludedAmount.sum();
    final tipCount = p.id.count();

    // Total tips
    final totalQuery = _db.selectOnly(p)
      ..addColumns([tipSum, tipCount])
      ..where(
        p.companyId.equals(companyId) &
            p.deletedAt.isNull() &
            p.tipIncludedAmount.isBiggerThanValue(0) &
            p.paidAt.isBiggerOrEqualValue(since),
      );
    final totalRow = await totalQuery.getSingle();

    // Tips by user
    final byUserQuery = _db.selectOnly(p).join([
      innerJoin(_db.users, _db.users.id.equalsExp(p.userId)),
    ])
      ..addColumns([p.userId, _db.users.fullName, tipSum, tipCount])
      ..where(
        p.companyId.equals(companyId) &
            p.deletedAt.isNull() &
            p.tipIncludedAmount.isBiggerThanValue(0) &
            p.paidAt.isBiggerOrEqualValue(since),
      )
      ..groupBy([p.userId, _db.users.fullName])
      ..orderBy([OrderingTerm.desc(tipSum)]);

    final byUserRows = await byUserQuery.get();
    final byUser = byUserRows.map((row) {
      return {
        'user_id': row.read(p.userId),
        'user_name': row.read(_db.users.fullName),
        'total_tips': row.read(tipSum) ?? 0,
        'tip_count': row.read(tipCount) ?? 0,
      };
    }).toList();

    return AiCommandSuccess(jsonEncode({
      'period_days': args['days'] ?? 30,
      'total_tips': totalRow.read(tipSum) ?? 0,
      'tip_count': totalRow.read(tipCount) ?? 0,
      'by_user': byUser,
    }));
  }

  // ---------------------------------------------------------------------------
  // Orders summary (counts by status, voided, avg prep time)
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _getOrdersSummary(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final since = _since(args);
    final o = _db.orders;

    final countExpr = o.id.count();
    final query = _db.selectOnly(o)
      ..addColumns([o.status, countExpr])
      ..where(
        o.companyId.equals(companyId) &
            o.deletedAt.isNull() &
            o.createdAt.isBiggerOrEqualValue(since),
      )
      ..groupBy([o.status]);

    final rows = await query.get();
    final byStatus = <String, int>{};
    for (final row in rows) {
      final status = row.read(o.status) ?? 'unknown';
      byStatus[status] = row.read(countExpr) ?? 0;
    }

    // Count voided orders
    final voidedQuery = _db.selectOnly(o)
      ..addColumns([o.id.count()])
      ..where(
        o.companyId.equals(companyId) &
            o.deletedAt.isNull() &
            o.isStorno.equals(true) &
            o.createdAt.isBiggerOrEqualValue(since),
      );
    final voidedRow = await voidedQuery.getSingle();

    return AiCommandSuccess(jsonEncode({
      'period_days': args['days'] ?? 30,
      'by_status': byStatus,
      'voided_count': voidedRow.read(o.id.count()) ?? 0,
    }));
  }

  // ---------------------------------------------------------------------------
  // Shifts summary (hours worked per user)
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _getShiftsSummary(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final since = _since(args);
    final s = _db.shifts;

    // Get closed shifts with user info
    final query = _db.select(s).join([
      innerJoin(_db.users, _db.users.id.equalsExp(s.userId)),
    ])
      ..where(
        s.companyId.equals(companyId) &
            s.deletedAt.isNull() &
            s.logoutAt.isNotNull() &
            s.loginAt.isBiggerOrEqualValue(since),
      )
      ..orderBy([OrderingTerm.desc(s.loginAt)]);

    final rows = await query.get();

    // Aggregate by user
    final userMap = <String, _UserShiftAgg>{};
    for (final row in rows) {
      final shift = row.readTable(s);
      final user = row.readTable(_db.users);
      final duration = shift.logoutAt!.difference(shift.loginAt);

      final agg = userMap.putIfAbsent(
        shift.userId,
        () => _UserShiftAgg(user.fullName),
      );
      agg.totalMinutes += duration.inMinutes;
      agg.shiftCount++;
    }

    final byUser = userMap.entries.map((e) {
      final hours = (e.value.totalMinutes / 60).toStringAsFixed(1);
      return {
        'user_id': e.key,
        'user_name': e.value.name,
        'shift_count': e.value.shiftCount,
        'total_hours': hours,
      };
    }).toList();

    return AiCommandSuccess(jsonEncode({
      'period_days': args['days'] ?? 30,
      'total_shifts': rows.length,
      'by_user': byUser,
    }));
  }

  // ---------------------------------------------------------------------------
  // Register sessions (Z-reports)
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _getRegisterSessions(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final since = _since(args);
    final rs = _db.registerSessions;

    final query = _db.select(rs).join([
      innerJoin(
          _db.registers, _db.registers.id.equalsExp(rs.registerId)),
    ])
      ..where(
        rs.companyId.equals(companyId) &
            rs.deletedAt.isNull() &
            rs.closedAt.isNotNull() &
            rs.closedAt.isBiggerOrEqualValue(since),
      )
      ..orderBy([OrderingTerm.desc(rs.closedAt)]);

    final rows = await query.get();
    final json = rows.map((row) {
      final session = row.readTable(rs);
      final register = row.readTable(_db.registers);
      return {
        'session_id': session.id,
        'register_name': register.registerNumber,
        'opened_at': session.openedAt.toIso8601String(),
        'closed_at': session.closedAt?.toIso8601String(),
        'bill_count': session.billCounter,
        'order_count': session.orderCounter,
        'opening_cash': session.openingCash,
        'closing_cash': session.closingCash,
        'expected_cash': session.expectedCash,
        'difference': session.difference,
      };
    }).toList();

    return AiCommandSuccess(jsonEncode({
      'period_days': args['days'] ?? 30,
      'sessions': json,
    }));
  }
}

class _UserShiftAgg {
  _UserShiftAgg(this.name);
  final String name;
  int totalMinutes = 0;
  int shiftCount = 0;
}
