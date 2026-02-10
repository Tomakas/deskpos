import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/result.dart';
import '../logging/app_logger.dart';

class SupabaseAuthService {
  SupabaseAuthService(this._client);
  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  bool get isAuthenticated => _auth.currentSession != null;

  String? get currentUserId => _auth.currentUser?.id;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  Future<Result<String>> signUp(String email, String password) async {
    try {
      final response = await _auth.signUp(email: email, password: password);
      final userId = response.user?.id;
      if (userId == null) {
        return const Failure('Sign up failed: no user returned');
      }
      AppLogger.info('Supabase sign up successful', tag: 'SYNC');
      return Success(userId);
    } on AuthException catch (e) {
      AppLogger.error('Supabase sign up failed', tag: 'SYNC', error: e);
      return Failure(e.message);
    } catch (e, s) {
      AppLogger.error('Supabase sign up failed', tag: 'SYNC', error: e, stackTrace: s);
      return Failure('Sign up failed: $e');
    }
  }

  Future<Result<String>> signIn(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(email: email, password: password);
      final userId = response.user?.id;
      if (userId == null) {
        return const Failure('Sign in failed: no user returned');
      }
      AppLogger.info('Supabase sign in successful', tag: 'SYNC');
      return Success(userId);
    } on AuthException catch (e) {
      AppLogger.error('Supabase sign in failed', tag: 'SYNC', error: e);
      return Failure(e.message);
    } catch (e, s) {
      AppLogger.error('Supabase sign in failed', tag: 'SYNC', error: e, stackTrace: s);
      return Failure('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      AppLogger.info('Supabase sign out successful', tag: 'SYNC');
    } catch (e, s) {
      AppLogger.error('Supabase sign out failed', tag: 'SYNC', error: e, stackTrace: s);
    }
  }
}
