import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift_model.freezed.dart';

@freezed
class ShiftModel with _$ShiftModel {
  const factory ShiftModel({
    required String id,
    required String companyId,
    required String registerSessionId,
    required String userId,
    required DateTime loginAt,
    DateTime? logoutAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _ShiftModel;
}
