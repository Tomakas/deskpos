import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/hardware_type.dart';

part 'register_model.freezed.dart';

@freezed
class RegisterModel with _$RegisterModel {
  const factory RegisterModel({
    required String id,
    required String companyId,
    required String code,
    @Default('') String name,
    @Default(1) int registerNumber,
    String? parentRegisterId,
    @Default(true) bool isActive,
    required HardwareType type,
    @Default(true) bool allowCash,
    @Default(true) bool allowCard,
    @Default(true) bool allowTransfer,
    @Default(false) bool allowRefunds,
    @Default(5) int gridRows,
    @Default(8) int gridCols,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _RegisterModel;
}
