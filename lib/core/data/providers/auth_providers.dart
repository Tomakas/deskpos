import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_service.dart';
import '../../auth/session_manager.dart';
import '../models/company_model.dart';
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
  final companyRepo = ref.watch(companyRepositoryProvider);
  final result = await companyRepo.getFirst();
  return switch (result) {
    Success(value: final company) => company == null
        ? _AppInitState.needsOnboarding
        : _AppInitState.needsLogin,
    Failure() => _AppInitState.needsOnboarding,
  };
});

enum _AppInitState { needsOnboarding, needsLogin }

/// Re-export for use in routing
typedef AppInitState = _AppInitState;

/// Provides the active register for the current company
final activeRegisterProvider = FutureProvider<RegisterModel?>((ref) async {
  final company = ref.watch(currentCompanyProvider);
  if (company == null) return null;
  return ref.watch(registerRepositoryProvider).getFirstActive(company.id);
});

/// Watches the active register session (open, not closed)
final activeRegisterSessionProvider = StreamProvider<RegisterSessionModel?>((ref) {
  final company = ref.watch(currentCompanyProvider);
  if (company == null) return Stream.value(null);
  return ref.watch(registerSessionRepositoryProvider).watchActiveSession(company.id);
});
