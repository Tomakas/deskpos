import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/data/enums/enums.dart';
import '../../../core/data/models/reservation_model.dart';
import '../../../core/data/repositories/reservation_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

const _uuid = Uuid();

/// Handles reservation-domain AI tool calls.
class AiReservationToolHandler {
  AiReservationToolHandler({required ReservationRepository reservationRepo})
      : _reservationRepo = reservationRepo;

  final ReservationRepository _reservationRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        'list_reservations' => _listReservations(args, companyId),
        'get_reservation' => _getReservation(args, companyId),
        'create_reservation' => _createReservation(args, companyId),
        'update_reservation' => _updateReservation(args, companyId),
        'delete_reservation' => _deleteReservation(args, companyId),
        _ => AiCommandError('Unknown reservation tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Reservation tool handler error',
          tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  Future<AiCommandResult> _listReservations(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final dateStr = args['date'] as String?;
    final statusStr = args['status'] as String?;

    List<ReservationModel> reservations;
    if (dateStr != null) {
      final date = DateTime.parse(dateStr);
      final from = DateTime(date.year, date.month, date.day);
      final to = from.add(const Duration(days: 1));
      reservations =
          await _reservationRepo.watchByDateRange(companyId, from, to).first;
    } else {
      reservations = await _reservationRepo.watchAll(companyId).first;
    }

    if (statusStr != null) {
      final status = ReservationStatus.values.byName(statusStr);
      reservations =
          reservations.where((r) => r.status == status).toList();
    }

    final json = reservations
        .take(1000)
        .map((r) => {
              'id': r.id,
              'customer_name': r.customerName,
              'customer_phone': r.customerPhone,
              'customer_id': r.customerId,
              'reservation_date': r.reservationDate.toIso8601String(),
              'party_size': r.partySize,
              'duration_minutes': r.durationMinutes,
              'table_id': r.tableId,
              'status': r.status.name,
              'notes': r.notes,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _getReservation(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final reservation =
        await _reservationRepo.getById(id, companyId: companyId);
    if (reservation == null) {
      return const AiCommandError('Reservation not found');
    }
    return AiCommandSuccess(jsonEncode({
      'id': reservation.id,
      'customer_name': reservation.customerName,
      'customer_phone': reservation.customerPhone,
      'customer_id': reservation.customerId,
      'reservation_date': reservation.reservationDate.toIso8601String(),
      'party_size': reservation.partySize,
      'duration_minutes': reservation.durationMinutes,
      'table_id': reservation.tableId,
      'status': reservation.status.name,
      'notes': reservation.notes,
    }));
  }

  Future<AiCommandResult> _createReservation(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final now = DateTime.now();
    final model = ReservationModel(
      id: _uuid.v7(),
      companyId: companyId,
      customerName: args['customer_name'] as String,
      customerPhone: args['customer_phone'] as String?,
      customerId: args['customer_id'] as String?,
      reservationDate: DateTime.parse(args['reservation_date'] as String),
      partySize: (args['party_size'] as num?)?.toInt() ?? 2,
      durationMinutes: (args['duration_minutes'] as num?)?.toInt() ?? 90,
      tableId: args['table_id'] as String?,
      notes: args['notes'] as String?,
      status: args['status'] != null
          ? ReservationStatus.values.byName(args['status'] as String)
          : ReservationStatus.created,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _reservationRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Reservation for "${value.customerName}" created',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateReservation(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final existing =
        await _reservationRepo.getById(id, companyId: companyId);
    if (existing == null) {
      return const AiCommandError('Reservation not found');
    }

    final updated = existing.copyWith(
      customerName:
          args['customer_name'] as String? ?? existing.customerName,
      customerPhone: args.containsKey('customer_phone')
          ? args['customer_phone'] as String?
          : existing.customerPhone,
      customerId: args.containsKey('customer_id')
          ? args['customer_id'] as String?
          : existing.customerId,
      reservationDate: args['reservation_date'] != null
          ? DateTime.parse(args['reservation_date'] as String)
          : existing.reservationDate,
      partySize: (args['party_size'] as num?)?.toInt() ?? existing.partySize,
      durationMinutes:
          (args['duration_minutes'] as num?)?.toInt() ?? existing.durationMinutes,
      tableId: args.containsKey('table_id')
          ? args['table_id'] as String?
          : existing.tableId,
      notes: args.containsKey('notes')
          ? args['notes'] as String?
          : existing.notes,
      status: args['status'] != null
          ? ReservationStatus.values.byName(args['status'] as String)
          : existing.status,
      updatedAt: DateTime.now(),
    );
    final result = await _reservationRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Reservation for "${value.customerName}" updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteReservation(
      Map<String, dynamic> args, String companyId) async {
    final id = args['id'] as String;
    final existing =
        await _reservationRepo.getById(id, companyId: companyId);
    if (existing == null) {
      return const AiCommandError('Reservation not found');
    }
    final result = await _reservationRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess('Reservation deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }
}
