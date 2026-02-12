import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_registration_model.freezed.dart';

@freezed
class DeviceRegistrationModel with _$DeviceRegistrationModel {
  const factory DeviceRegistrationModel({
    required String id,
    required String companyId,
    required String registerId,
    required DateTime createdAt,
  }) = _DeviceRegistrationModel;
}
