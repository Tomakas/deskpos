import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../auth/auth_service.dart';
import '../../auth/session_manager.dart';
import '../models/company_model.dart';
import '../models/currency_model.dart';
import '../models/device_registration_model.dart';
import '../models/register_model.dart';
import '../models/register_session_model.dart';
import '../models/user_model.dart';
import '../result.dart';
import '../services/seed_service.dart';
import 'database_provider.dart';
import 'repository_providers.dart';

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final seedServiceProvider = Provider<SeedService>((ref) {
  return SeedService(ref.watch(appDatabaseProvider));
});

/// Persistent device UUID — identifies this physical device across sessions.
/// Stored in a file next to the database.
final deviceIdProvider = FutureProvider<String>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'epos_device_id.txt'));
  if (file.existsSync()) {
    return file.readAsStringSync().trim();
  }
  final id = const Uuid().v7();
  await file.writeAsString(id);
  return id;
});

/// Pre-company locale override — set during onboarding before any company exists.
/// When non-null, overrides appLocaleProvider for immediate UI language switch.
final pendingLocaleProvider = StateProvider<String?>((ref) => null);

final activeUserProvider = StateProvider<UserModel?>((ref) {
  return ref.watch(sessionManagerProvider).activeUser;
});

final loggedInUsersProvider = StateProvider<List<UserModel>>((ref) {
  return ref.watch(sessionManagerProvider).loggedInUsers;
});

/// Watches the first company from DB to determine if onboarding is needed
final companyStreamProvider = StreamProvider<CompanyModel?>((ref) {
  return ref.watch(companyRepositoryProvider).watchFirst();
});

/// Provides the current company synchronously (set after initial load)
final currentCompanyProvider = StateProvider<CompanyModel?>((ref) {
  return null;
});

/// Notifier for the app initialization state
final appInitProvider = FutureProvider<_AppInitState>((ref) async {
  // Check if device is configured as a display
  final prefs = await SharedPreferences.getInstance();
  final displayCode = prefs.getString('display_code');
  final displayType = prefs.getString('display_type');

  if (displayCode != null && displayType == 'customer_display') {
    return _AppInitState.displayMode;
  }

  final companyRepo = ref.watch(companyRepositoryProvider);
  final result = await companyRepo.getFirst();
  final hasCompany = switch (result) {
    Success(value: final company) => company != null,
    Failure() => false,
  };

  return hasCompany ? _AppInitState.needsLogin : _AppInitState.needsOnboarding;
});

enum _AppInitState { needsOnboarding, needsLogin, displayMode }

/// Re-export for use in routing
typedef AppInitState = _AppInitState;

/// Provides the device registration for the current company (local-only binding)
final deviceRegistrationProvider = FutureProvider<DeviceRegistrationModel?>((ref) async {
  final company = ref.watch(currentCompanyProvider);
  if (company == null) return null;
  return ref.watch(deviceRegistrationRepositoryProvider).getForCompany(company.id);
});

/// Provides the active register for the current company.
/// Returns null if no device binding exists (register selection required).
final activeRegisterProvider = FutureProvider<RegisterModel?>((ref) async {
  final company = ref.watch(currentCompanyProvider);
  if (company == null) return null;

  final deviceReg = await ref.watch(deviceRegistrationProvider.future);
  if (deviceReg != null) {
    return ref.watch(registerRepositoryProvider).getById(deviceReg.registerId);
  }

  return null;
});

/// Watches the active register session (open, not closed).
/// Filters by registerId from device binding when available.
final activeRegisterSessionProvider = StreamProvider<RegisterSessionModel?>((ref) {
  final company = ref.watch(currentCompanyProvider);
  if (company == null) return Stream.value(null);

  final deviceReg = ref.watch(deviceRegistrationProvider).value;
  final registerId = deviceReg?.registerId;

  return ref.watch(registerSessionRepositoryProvider).watchActiveSession(
    company.id,
    registerId: registerId,
  );
});

/// Manual lock trigger — set to true to show lock overlay (e.g. from "Switch/Lock" button)
final manualLockProvider = StateProvider<bool>((ref) => false);

/// Provides the company's default currency for formatting.
/// Reads currency record from DB based on company.defaultCurrencyId.
final currentCurrencyProvider = FutureProvider<CurrencyModel?>((ref) async {
  final company = ref.watch(currentCompanyProvider);
  if (company == null) return null;

  final currencyRepo = ref.watch(currencyRepositoryProvider);
  return currencyRepo.getById(company.defaultCurrencyId);
});

/// Provides the app locale string from company settings (reactive via stream).
final appLocaleProvider = StreamProvider<String>((ref) {
  final company = ref.watch(currentCompanyProvider);
  if (company == null) return Stream.value('cs');

  return ref
      .watch(companySettingsRepositoryProvider)
      .watchByCompany(company.id)
      .map((settings) => settings?.locale ?? 'cs');
});
