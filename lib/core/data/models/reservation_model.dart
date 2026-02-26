import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/reservation_status.dart';
import 'company_scoped_model.dart';

part 'reservation_model.freezed.dart';

@freezed
abstract class ReservationModel with _$ReservationModel implements CompanyScopedModel {
  const factory ReservationModel({
    required String id,
    required String companyId,
    String? customerId,
    required String customerName,
    String? customerPhone,
    required DateTime reservationDate,
    @Default(2) int partySize,
    @Default(90) int durationMinutes,
    String? tableId,
    String? notes,
    required ReservationStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _ReservationModel;
}
