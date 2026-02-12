import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../models/device_registration_model.dart';
import 'register_repository.dart';

/// Local-only repository — device_registrations are NOT synced.
/// Also updates register.boundDeviceId (which IS synced) for cross-device exclusivity.
class DeviceRegistrationRepository {
  DeviceRegistrationRepository(this._db, {this.registerRepo});
  final AppDatabase _db;
  final RegisterRepository? registerRepo;

  Future<DeviceRegistrationModel?> getForCompany(String companyId) async {
    final entity = await (_db.select(_db.deviceRegistrations)
          ..where((t) => t.companyId.equals(companyId))
          ..limit(1))
        .getSingleOrNull();
    return entity == null ? null : deviceRegistrationFromEntity(entity);
  }

  Future<DeviceRegistrationModel> bind({
    required String companyId,
    required String registerId,
    String? deviceId,
  }) async {
    // Clear boundDeviceId on the previously bound register (if any)
    if (deviceId != null && registerRepo != null) {
      final existing = await getForCompany(companyId);
      if (existing != null && existing.registerId != registerId) {
        await registerRepo!.clearBoundDevice(existing.registerId);
      }
    }

    // Remove existing local binding (safe rebind)
    await _unbindLocal(companyId);

    final id = const Uuid().v7();
    final now = DateTime.now();
    await _db.into(_db.deviceRegistrations).insert(
      DeviceRegistrationsCompanion.insert(
        id: id,
        companyId: companyId,
        registerId: registerId,
        createdAt: now,
      ),
    );

    // Set boundDeviceId on the new register
    if (deviceId != null && registerRepo != null) {
      await registerRepo!.setBoundDevice(registerId, deviceId);
    }

    final entity = await (_db.select(_db.deviceRegistrations)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return deviceRegistrationFromEntity(entity);
  }

  Future<void> unbind(String companyId, {String? registerId}) async {
    // Clear boundDeviceId on the register being unbound
    if (registerRepo != null) {
      final existing = await getForCompany(companyId);
      final regId = registerId ?? existing?.registerId;
      if (regId != null) {
        await registerRepo!.clearBoundDevice(regId);
      }
    }
    await _unbindLocal(companyId);
  }

  Future<void> _unbindLocal(String companyId) async {
    await (_db.delete(_db.deviceRegistrations)
          ..where((t) => t.companyId.equals(companyId)))
        .go();
  }
}
