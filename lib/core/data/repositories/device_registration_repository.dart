import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/device_registration_model.dart';
import '../result.dart';
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

  Future<Result<DeviceRegistrationModel>> bind({
    required String companyId,
    required String registerId,
    String? deviceId,
  }) async {
    try {
      // Clear boundDeviceId on the previously bound register (if any)
      if (deviceId != null && registerRepo != null) {
        final existing = await getForCompany(companyId);
        if (existing != null && existing.registerId != registerId) {
          final clearResult = await registerRepo!.clearBoundDevice(existing.registerId);
          if (clearResult case Failure(:final message)) {
            return Failure(message);
          }
        }
      }

      // Local operations in a transaction
      final model = await _db.transaction(() async {
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

        final entity = await (_db.select(_db.deviceRegistrations)
              ..where((t) => t.id.equals(id)))
            .getSingle();
        return deviceRegistrationFromEntity(entity);
      });

      // Set boundDeviceId on the new register
      if (deviceId != null && registerRepo != null) {
        final setResult = await registerRepo!.setBoundDevice(registerId, deviceId);
        if (setResult case Failure(:final message)) {
          return Failure(message);
        }
      }

      return Success(model);
    } catch (e, s) {
      AppLogger.error('Failed to bind device registration', error: e, stackTrace: s);
      return Failure('Failed to bind device registration: $e');
    }
  }

  Future<Result<void>> unbind(String companyId, {String? registerId}) async {
    try {
      // Clear boundDeviceId on the register being unbound
      if (registerRepo != null) {
        final existing = await getForCompany(companyId);
        final regId = registerId ?? existing?.registerId;
        if (regId != null) {
          final clearResult = await registerRepo!.clearBoundDevice(regId);
          if (clearResult case Failure(:final message)) {
            return Failure(message);
          }
        }
      }
      await _unbindLocal(companyId);
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to unbind device registration', error: e, stackTrace: s);
      return Failure('Failed to unbind device registration: $e');
    }
  }

  Future<void> _unbindLocal(String companyId) async {
    await (_db.delete(_db.deviceRegistrations)
          ..where((t) => t.companyId.equals(companyId)))
        .go();
  }
}
