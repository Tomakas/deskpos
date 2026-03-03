import 'package:uuid/uuid.dart';

import '../../../core/ai/models/ai_provider_models.dart';
import '../../../core/data/models/ai_undo_log_model.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';
import '../tool_handlers/ai_tool_handler_registry.dart';
import 'ai_direct_supabase_service.dart';
import 'ai_tool_registry.dart';

const _uuid = Uuid();

/// Central command dispatcher. Checks permissions, delegates to handler,
/// creates undo logs for write operations.
class AiCommandService {
  AiCommandService({
    required AiToolRegistry toolRegistry,
    required AiToolHandlerRegistry handlerRegistry,
    required AiDirectSupabaseService aiDirectService,
  })  : _toolRegistry = toolRegistry,
        _handlerRegistry = handlerRegistry,
        _aiDirectService = aiDirectService;

  final AiToolRegistry _toolRegistry;
  final AiToolHandlerRegistry _handlerRegistry;
  final AiDirectSupabaseService _aiDirectService;

  /// Executes a tool call with permission checks and undo log creation.
  Future<AiCommandResult> executeToolCall({
    required AiToolCall toolCall,
    required String companyId,
    required String userId,
    required String conversationId,
    required String messageId,
    required Set<String> userPermissions,
  }) async {
    final toolName = toolCall.name;
    final isReadOnly = _toolRegistry.isReadOnly(toolName);

    // Check permission
    final requiredPermission = _toolRegistry.getRequiredPermission(toolName);
    if (requiredPermission != null &&
        !userPermissions.contains(requiredPermission)) {
      return AiCommandPermissionDenied(
        'Missing permission: $requiredPermission',
      );
    }

    // Execute the tool
    final result = await _handlerRegistry.dispatch(
      toolName,
      toolCall.arguments,
      companyId,
      userId: userId,
    );

    // Create undo log for successful write operations
    if (!isReadOnly && result is AiCommandSuccess && result.entityId != null) {
      try {
        final operationType = _inferOperationType(toolName);
        final now = DateTime.now();
        final undoLog = AiUndoLogModel(
          id: _uuid.v7(),
          companyId: companyId,
          conversationId: conversationId,
          messageId: messageId,
          toolCallId: toolCall.id,
          operationType: operationType,
          entityType: _inferEntityType(toolName),
          entityId: result.entityId!,
          snapshotBefore: null, // TODO: capture before-snapshot in Phase 3
          snapshotAfter: null, // TODO: capture after-snapshot in Phase 3
          expiresAt: now.add(const Duration(minutes: 30)),
          createdAt: now,
          updatedAt: now,
        );
        await _aiDirectService.saveUndoLog(undoLog);
      } catch (e) {
        // Undo log failure should not block the tool result
        AppLogger.warn(
          'Failed to create undo log for $toolName',
          tag: 'AI',
          error: e,
        );
      }
    }

    return result;
  }

  String _inferOperationType(String toolName) {
    if (toolName.startsWith('create_')) return 'create';
    if (toolName.startsWith('update_') || toolName.startsWith('adjust_')) {
      return 'update';
    }
    if (toolName.startsWith('delete_')) return 'delete';
    return 'update';
  }

  String _inferEntityType(String toolName) {
    // Strip prefix (create_, update_, delete_, search_, get_, list_, adjust_)
    final prefixes = [
      'create_',
      'update_',
      'delete_',
      'search_',
      'get_',
      'list_',
      'adjust_',
    ];
    var name = toolName;
    for (final prefix in prefixes) {
      if (name.startsWith(prefix)) {
        name = name.substring(prefix.length);
        break;
      }
    }
    // Normalize: customer_points -> customer, customer_credit -> customer
    if (name == 'customer_points' || name == 'customer_credit') {
      return 'customer';
    }
    // Normalize: company_settings -> company_settings
    // Remove trailing 's' for plural -> singular (items -> item)
    if (name.endsWith('s') &&
        name != 'company_settings' &&
        name != 'payment_methods') {
      name = name.substring(0, name.length - 1);
    }
    return name;
  }
}
