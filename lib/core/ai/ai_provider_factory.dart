import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/enums/ai_provider_type.dart';
import 'ai_provider.dart';
import 'providers/openai_provider.dart';

/// Creates an [AiProvider] instance based on the configured provider type.
///
/// All providers route through the ai-proxy Edge Function, so the client-side
/// implementation is the same (OpenAI-compatible format). The Edge Function
/// handles provider-specific API differences.
AiProvider? createAiProvider({
  required AiProviderType type,
  required SupabaseClient supabaseClient,
}) {
  return switch (type) {
    AiProviderType.none => null,
    // All providers use the same Edge Function proxy with OpenAI-compatible format.
    AiProviderType.openai ||
    AiProviderType.google ||
    AiProviderType.anthropic =>
      OpenAiProvider(supabaseClient: supabaseClient),
  };
}
