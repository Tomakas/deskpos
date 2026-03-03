import 'ai_direct_supabase_service.dart';

/// Client-side rate limiting (complements server-side rate limit
/// in the Edge Function).
class AiRateLimiter {
  AiRateLimiter({required AiDirectSupabaseService aiDirectService})
      : _aiDirectService = aiDirectService;

  final AiDirectSupabaseService _aiDirectService;

  /// Returns true if the user can send another message.
  Future<bool> canSendMessage({
    required String companyId,
    required String userId,
    required int limitPerHour,
  }) async {
    final count = await _aiDirectService.countUserMessagesInLastHour(
      companyId: companyId,
      userId: userId,
    );
    return count < limitPerHour;
  }
}
