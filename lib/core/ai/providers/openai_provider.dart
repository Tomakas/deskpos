import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../logging/app_logger.dart';
import '../ai_provider.dart';
import '../models/ai_provider_models.dart';
import '../models/ai_stream_event.dart';

/// OpenAI-compatible provider that routes all requests through the ai-proxy Edge Function.
class OpenAiProvider implements AiProvider {
  OpenAiProvider({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<AiProviderResponse> sendMessage({
    required String systemPrompt,
    required List<AiChatMessage> messages,
    required List<AiToolDefinition> tools,
    int maxTokens = 4096,
    double temperature = 0.3,
  }) async {
    final body = _buildChatBody(
      systemPrompt: systemPrompt,
      messages: messages,
      tools: tools,
      maxTokens: maxTokens,
      temperature: temperature,
      stream: false,
    );

    final response = await _supabaseClient.functions.invoke(
      'ai-proxy',
      body: body,
    );

    final json = response.data as Map<String, dynamic>;
    return _parseResponse(json);
  }

  @override
  Stream<AiStreamEvent> sendMessageStream({
    required String systemPrompt,
    required List<AiChatMessage> messages,
    required List<AiToolDefinition> tools,
    int maxTokens = 4096,
    double temperature = 0.3,
  }) async* {
    final body = _buildChatBody(
      systemPrompt: systemPrompt,
      messages: messages,
      tools: tools,
      maxTokens: maxTokens,
      temperature: temperature,
      stream: true,
    );

    final response = await _supabaseClient.functions.invoke(
      'ai-proxy',
      body: body,
    );

    // The Edge Function returns SSE-style data as text.
    // Depending on Supabase SDK version, data may be String, List<int>, or ByteStream.
    final rawData = response.data;
    String text;
    if (rawData is String) {
      text = rawData;
    } else if (rawData is List<int>) {
      text = utf8.decode(rawData);
    } else {
      // ByteStream or other stream — collect all bytes first
      final bytes = <int>[];
      await for (final chunk in rawData as Stream<List<int>>) {
        bytes.addAll(chunk);
      }
      text = utf8.decode(bytes);
    }

    yield* _parseSseStream(text);
  }

  @override
  Future<String> transcribe({
    required List<int> audioBytes,
    required String mimeType,
    String? language,
  }) async {
    final body = <String, dynamic>{
      'action': 'transcribe',
      'audio': base64Encode(audioBytes),
      'format': _mimeToFormat(mimeType),
      if (language != null) 'language': language,
    };

    final response = await _supabaseClient.functions.invoke(
      'ai-proxy',
      body: body,
    );

    final json = response.data as Map<String, dynamic>;
    return json['text'] as String;
  }

  @override
  void dispose() {
    // No resources to clean up — all requests go through Edge Function.
  }

  // --- Private helpers ---

  Map<String, dynamic> _buildChatBody({
    required String systemPrompt,
    required List<AiChatMessage> messages,
    required List<AiToolDefinition> tools,
    required int maxTokens,
    required double temperature,
    required bool stream,
  }) {
    return {
      'action': 'chat',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map(_serializeMessage),
      ],
      if (tools.isNotEmpty)
        'tools': tools
            .map((t) => {
                  'name': t.name,
                  'description': t.description,
                  'parameters': t.parameters,
                })
            .toList(),
      'maxTokens': maxTokens,
      'temperature': temperature,
      'stream': stream,
    };
  }

  Map<String, dynamic> _serializeMessage(AiChatMessage msg) {
    return switch (msg) {
      UserMessage(:final content) => {'role': 'user', 'content': content},
      AssistantMessage(:final content, :final toolCalls) => <String, dynamic>{
          'role': 'assistant',
          if (content != null) 'content': content,
          if (toolCalls != null)
            'toolCalls': toolCalls
                .map((tc) => {
                      'id': tc.id,
                      'name': tc.name,
                      'arguments': tc.arguments,
                    })
                .toList(),
        },
      ToolResultMessage(:final toolCallId, :final content, :final isError) => {
          'role': 'tool',
          'toolCallId': toolCallId,
          'content': content,
          if (isError) 'isError': true,
        },
    };
  }

  AiProviderResponse _parseResponse(Map<String, dynamic> json) {
    final toolCallsJson = json['toolCalls'] as List?;
    final usage = json['usage'] as Map<String, dynamic>? ?? {};

    return AiProviderResponse(
      content: json['content'] as String?,
      toolCalls: toolCallsJson
          ?.map((tc) => AiToolCall(
                id: tc['id'] as String,
                name: tc['name'] as String,
                arguments: tc['arguments'] as Map<String, dynamic>,
              ))
          .toList(),
      promptTokens: usage['promptTokens'] as int? ?? 0,
      completionTokens: usage['completionTokens'] as int? ?? 0,
      finishReason: json['finishReason'] as String? ?? 'stop',
    );
  }

  Stream<AiStreamEvent> _parseSseStream(String sseText) async* {
    final lines = sseText.split('\n');
    final toolCallBuffers = <int, _ToolCallBuffer>{};

    for (final line in lines) {
      if (!line.startsWith('data: ')) continue;
      final data = line.substring(6).trim();
      if (data == '[DONE]') break;

      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        final choices = json['choices'] as List?;
        if (choices == null || choices.isEmpty) continue;

        final choice = choices[0] as Map<String, dynamic>;
        final delta = choice['delta'] as Map<String, dynamic>?;
        final finishReason = choice['finish_reason'] as String?;

        if (delta != null) {
          // Text content delta
          final content = delta['content'] as String?;
          if (content != null) {
            yield TextDelta(content);
          }

          // Tool calls
          final toolCalls = delta['tool_calls'] as List?;
          if (toolCalls != null) {
            for (final tc in toolCalls) {
              final tcMap = tc as Map<String, dynamic>;
              final index = tcMap['index'] as int;
              final function_ = tcMap['function'] as Map<String, dynamic>?;

              if (tcMap.containsKey('id')) {
                // New tool call starting
                final id = tcMap['id'] as String;
                final name = function_?['name'] as String? ?? '';
                toolCallBuffers[index] = _ToolCallBuffer(id: id, name: name);
                yield ToolCallStart(index: index, id: id, name: name);
              }

              if (function_ != null) {
                final argDelta = function_['arguments'] as String?;
                if (argDelta != null && argDelta.isNotEmpty) {
                  toolCallBuffers[index]?.argumentsBuffer.write(argDelta);
                  yield ToolCallDelta(index: index, argumentsDelta: argDelta);
                }
              }
            }
          }
        }

        if (finishReason != null) {
          // Emit completed tool calls
          for (final entry in toolCallBuffers.entries) {
            final buf = entry.value;
            Map<String, dynamic> args = {};
            try {
              args = jsonDecode(buf.argumentsBuffer.toString()) as Map<String, dynamic>;
            } catch (_) {
              AppLogger.warn('Failed to parse tool call arguments', tag: 'AI');
            }
            yield ToolCallComplete(
              toolCall: AiToolCall(id: buf.id, name: buf.name, arguments: args),
            );
          }
          toolCallBuffers.clear();

          final usage = json['usage'] as Map<String, dynamic>?;
          yield StreamDone(
            promptTokens: usage?['prompt_tokens'] as int? ?? 0,
            completionTokens: usage?['completion_tokens'] as int? ?? 0,
            finishReason: finishReason,
          );
        }
      } catch (e) {
        AppLogger.error('SSE parse error: $e', tag: 'AI');
        yield StreamError('Failed to parse stream event: $e');
      }
    }
  }

  String _mimeToFormat(String mimeType) {
    return switch (mimeType) {
      'audio/wav' || 'audio/wave' => 'wav',
      'audio/mp3' || 'audio/mpeg' => 'mp3',
      'audio/webm' => 'webm',
      'audio/mp4' || 'audio/m4a' => 'mp4',
      _ => 'wav',
    };
  }
}

class _ToolCallBuffer {
  _ToolCallBuffer({required this.id, required this.name});
  final String id;
  final String name;
  final StringBuffer argumentsBuffer = StringBuffer();
}
