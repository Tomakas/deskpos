import 'models/ai_provider_models.dart';
import 'models/ai_stream_event.dart';

abstract class AiProvider {
  Future<AiProviderResponse> sendMessage({
    required String systemPrompt,
    required List<AiChatMessage> messages,
    required List<AiToolDefinition> tools,
    int maxTokens = 4096,
    double temperature = 0.3,
  });

  Stream<AiStreamEvent> sendMessageStream({
    required String systemPrompt,
    required List<AiChatMessage> messages,
    required List<AiToolDefinition> tools,
    int maxTokens = 4096,
    double temperature = 0.3,
  });

  Future<String> transcribe({
    required List<int> audioBytes,
    required String mimeType,
    String? language,
  });

  void dispose();
}
