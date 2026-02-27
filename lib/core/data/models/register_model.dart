import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/hardware_type.dart';
import '../enums/sell_mode.dart';

part 'register_model.freezed.dart';

@freezed
abstract class RegisterModel with _$RegisterModel {
  const factory RegisterModel({
    required String id,
    required String companyId,
    required String code,
    @Default('') String name,
    @Default(1) int registerNumber,
    String? parentRegisterId,
    @Default(false) bool isMain,
    @Default(true) bool isActive,
    required HardwareType type,
    @Default(true) bool allowCash,
    @Default(true) bool allowCard,
    @Default(true) bool allowTransfer,
    @Default(true) bool allowCredit,
    @Default(true) bool allowVoucher,
    @Default(true) bool allowOther,
    @Default(false) bool allowRefunds,
    String? boundDeviceId,
    String? activeBillId,
    @Default(5) int gridRows,
    @Default(8) int gridCols,
    String? displayCartJson,
    @Default(false) bool showStockBadge,
    @Default(SellMode.gastro) SellMode sellMode,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _RegisterModel;
}
