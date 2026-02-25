import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/display_device_type.dart';

part 'display_device_model.freezed.dart';

@freezed
abstract class DisplayDeviceModel with _$DisplayDeviceModel {
  const factory DisplayDeviceModel({
    required String id,
    required String companyId,
    String? parentRegisterId,
    required String code,
    @Default('') String name,
    @Default('') String welcomeText,
    @Default(DisplayDeviceType.customerDisplay) DisplayDeviceType type,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _DisplayDeviceModel;
}
