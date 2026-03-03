import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/ai/ai_provider.dart';
import '../../../core/ai/ai_provider_factory.dart';
import '../../../core/ai/models/ai_provider_models.dart';
import '../../../core/data/enums/ai_provider_type.dart';
import '../../../core/data/models/ai_conversation_model.dart';
import '../../../core/data/models/ai_message_model.dart';
import '../../../core/data/models/company_settings_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/database_provider.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import 'ai_chat_notifier.dart';
import '../services/ai_command_service.dart';
import '../services/ai_context_builder.dart';
import '../services/ai_conversation_manager.dart';
import '../services/ai_direct_supabase_service.dart';
import '../services/ai_rate_limiter.dart';
import '../services/ai_system_prompt_builder.dart';
import '../services/ai_tool_execution_loop.dart';
import '../services/ai_tool_registry.dart';
import '../services/ai_undo_service.dart';
import '../tool_handlers/ai_bill_order_tool_handler.dart';
import '../tool_handlers/ai_catalog_tool_handler.dart';
import '../tool_handlers/ai_company_tool_handler.dart';
import '../tool_handlers/ai_customer_tool_handler.dart';
import '../tool_handlers/ai_misc_read_tool_handler.dart';
import '../tool_handlers/ai_modifier_tool_handler.dart';
import '../tool_handlers/ai_payment_tool_handler.dart';
import '../tool_handlers/ai_recipe_tool_handler.dart';
import '../tool_handlers/ai_reservation_tool_handler.dart';
import '../tool_handlers/ai_stats_tool_handler.dart';
import '../tool_handlers/ai_stock_tool_handler.dart';
import '../tool_handlers/ai_tool_handler_registry.dart';
import '../tool_handlers/ai_user_tool_handler.dart';
import '../tool_handlers/ai_venue_tool_handler.dart';
import '../tool_handlers/ai_voucher_tool_handler.dart';

part 'ai_providers.freezed.dart';

// ---------------------------------------------------------------------------
// AI Provider instance — reactive to company settings
// ---------------------------------------------------------------------------

/// Watches company settings and creates the appropriate AI provider.
final aiProviderFromSettingsProvider = StreamProvider<AiProvider?>((ref) {
  final company = ref.watch(currentCompanyProvider);
  if (company == null) return Stream.value(null);

  final settingsRepo = ref.watch(companySettingsRepositoryProvider);
  return settingsRepo.watchByCompany(company.id).map((settings) {
    if (settings == null || settings.aiProviderType == AiProviderType.none) {
      return null;
    }
    return createAiProvider(
      type: settings.aiProviderType,
      supabaseClient: Supabase.instance.client,
    );
  });
});

// ---------------------------------------------------------------------------
// Direct Supabase service
// ---------------------------------------------------------------------------

final aiDirectServiceProvider = Provider<AiDirectSupabaseService>((ref) {
  return AiDirectSupabaseService(
    supabaseClient: Supabase.instance.client,
    db: ref.watch(appDatabaseProvider),
  );
});

// ---------------------------------------------------------------------------
// Active conversation
// ---------------------------------------------------------------------------

final aiActiveConversationProvider = StateProvider<AiConversationModel?>((ref) => null);

// ---------------------------------------------------------------------------
// Messages for active conversation
// ---------------------------------------------------------------------------

class AiMessagesNotifier extends StateNotifier<List<AiMessageModel>> {
  AiMessagesNotifier() : super([]);

  void setMessages(List<AiMessageModel> messages) {
    state = messages;
  }

  void addMessage(AiMessageModel message) {
    state = [...state, message];
  }

  void updateMessage(AiMessageModel updated) {
    state = [
      for (final m in state)
        if (m.id == updated.id) updated else m,
    ];
  }

  void clear() {
    state = [];
  }
}

final aiMessagesProvider =
    StateNotifierProvider<AiMessagesNotifier, List<AiMessageModel>>((ref) {
  return AiMessagesNotifier();
});

// ---------------------------------------------------------------------------
// Streaming text (per conversation)
// ---------------------------------------------------------------------------

final aiStreamingTextProvider =
    StateProvider.family<String, String>((ref, conversationId) => '');

// ---------------------------------------------------------------------------
// Pending confirmation (per conversation)
// ---------------------------------------------------------------------------

@freezed
abstract class AiPendingConfirmation with _$AiPendingConfirmation {
  const AiPendingConfirmation._();

  const factory AiPendingConfirmation({
    required String conversationId,
    required String messageId,
    required AiToolCall toolCall,
    required String description,
    required bool isDestructive,
    required DateTime createdAt,
  }) = _AiPendingConfirmation;

  bool get isExpired =>
      DateTime.now().difference(createdAt) > const Duration(minutes: 10);
}

final aiPendingConfirmationProvider =
    StateProvider.family<AiPendingConfirmation?, String>(
  (ref, conversationId) => null,
);

// ---------------------------------------------------------------------------
// Processing flag (per conversation)
// ---------------------------------------------------------------------------

final aiIsProcessingProvider =
    StateProvider.family<bool, String>((ref, conversationId) => false);

// ---------------------------------------------------------------------------
// Context builder (depends on 7 repositories)
// ---------------------------------------------------------------------------

final aiContextBuilderProvider = Provider<AiContextBuilder>((ref) {
  return AiContextBuilder(
    categoryRepo: ref.watch(categoryRepositoryProvider),
    itemRepo: ref.watch(itemRepositoryProvider),
    taxRateRepo: ref.watch(taxRateRepositoryProvider),
    paymentMethodRepo: ref.watch(paymentMethodRepositoryProvider),
    userRepo: ref.watch(userRepositoryProvider),
    sectionRepo: ref.watch(sectionRepositoryProvider),
    tableRepo: ref.watch(tableRepositoryProvider),
  );
});

// ---------------------------------------------------------------------------
// Tool registry (stateless)
// ---------------------------------------------------------------------------

final aiToolRegistryProvider = Provider<AiToolRegistry>((ref) {
  return AiToolRegistry();
});

// ---------------------------------------------------------------------------
// System prompt builder (stateless)
// ---------------------------------------------------------------------------

final aiSystemPromptBuilderProvider = Provider<AiSystemPromptBuilder>((ref) {
  return AiSystemPromptBuilder();
});

// ---------------------------------------------------------------------------
// Tool handlers (7 domain handlers + 1 registry)
// ---------------------------------------------------------------------------

final aiBillOrderToolHandlerProvider = Provider<AiBillOrderToolHandler>((ref) {
  return AiBillOrderToolHandler(
    billRepo: ref.watch(billRepositoryProvider),
    orderRepo: ref.watch(orderRepositoryProvider),
    paymentRepo: ref.watch(paymentRepositoryProvider),
  );
});

final aiCatalogToolHandlerProvider = Provider<AiCatalogToolHandler>((ref) {
  return AiCatalogToolHandler(
    itemRepo: ref.watch(itemRepositoryProvider),
    categoryRepo: ref.watch(categoryRepositoryProvider),
    taxRateRepo: ref.watch(taxRateRepositoryProvider),
    manufacturerRepo: ref.watch(manufacturerRepositoryProvider),
    supplierRepo: ref.watch(supplierRepositoryProvider),
  );
});

final aiCustomerToolHandlerProvider = Provider<AiCustomerToolHandler>((ref) {
  return AiCustomerToolHandler(
    customerRepo: ref.watch(customerRepositoryProvider),
  );
});

final aiVenueToolHandlerProvider = Provider<AiVenueToolHandler>((ref) {
  return AiVenueToolHandler(
    sectionRepo: ref.watch(sectionRepositoryProvider),
    tableRepo: ref.watch(tableRepositoryProvider),
  );
});

final aiVoucherToolHandlerProvider = Provider<AiVoucherToolHandler>((ref) {
  return AiVoucherToolHandler(
    voucherRepo: ref.watch(voucherRepositoryProvider),
  );
});

final aiPaymentToolHandlerProvider = Provider<AiPaymentToolHandler>((ref) {
  return AiPaymentToolHandler(
    paymentMethodRepo: ref.watch(paymentMethodRepositoryProvider),
  );
});

final aiStatsToolHandlerProvider = Provider<AiStatsToolHandler>((ref) {
  return AiStatsToolHandler(
    db: ref.watch(appDatabaseProvider),
  );
});

final aiStockToolHandlerProvider = Provider<AiStockToolHandler>((ref) {
  return AiStockToolHandler(
    stockLevelRepo: ref.watch(stockLevelRepositoryProvider),
    stockDocumentRepo: ref.watch(stockDocumentRepositoryProvider),
    warehouseRepo: ref.watch(warehouseRepositoryProvider),
  );
});

final aiUserToolHandlerProvider = Provider<AiUserToolHandler>((ref) {
  return AiUserToolHandler(
    userRepo: ref.watch(userRepositoryProvider),
  );
});

final aiCompanyToolHandlerProvider = Provider<AiCompanyToolHandler>((ref) {
  return AiCompanyToolHandler(
    companySettingsRepo: ref.watch(companySettingsRepositoryProvider),
  );
});

final aiReservationToolHandlerProvider =
    Provider<AiReservationToolHandler>((ref) {
  return AiReservationToolHandler(
    reservationRepo: ref.watch(reservationRepositoryProvider),
  );
});

final aiModifierToolHandlerProvider = Provider<AiModifierToolHandler>((ref) {
  return AiModifierToolHandler(
    modifierGroupRepo: ref.watch(modifierGroupRepositoryProvider),
    modifierGroupItemRepo: ref.watch(modifierGroupItemRepositoryProvider),
    itemModifierGroupRepo: ref.watch(itemModifierGroupRepositoryProvider),
  );
});

final aiRecipeToolHandlerProvider = Provider<AiRecipeToolHandler>((ref) {
  return AiRecipeToolHandler(
    recipeRepo: ref.watch(productRecipeRepositoryProvider),
  );
});

final aiMiscReadToolHandlerProvider = Provider<AiMiscReadToolHandler>((ref) {
  return AiMiscReadToolHandler(
    customerTransactionRepo: ref.watch(customerTransactionRepositoryProvider),
    stockDocumentRepo: ref.watch(stockDocumentRepositoryProvider),
    stockMovementRepo: ref.watch(stockMovementRepositoryProvider),
    roleRepo: ref.watch(roleRepositoryProvider),
    registerRepo: ref.watch(registerRepositoryProvider),
    companyCurrencyRepo: ref.watch(companyCurrencyRepositoryProvider),
    warehouseRepo: ref.watch(warehouseRepositoryProvider),
  );
});

final aiToolHandlerRegistryProvider = Provider<AiToolHandlerRegistry>((ref) {
  return AiToolHandlerRegistry(
    billOrderHandler: ref.watch(aiBillOrderToolHandlerProvider),
    catalogHandler: ref.watch(aiCatalogToolHandlerProvider),
    customerHandler: ref.watch(aiCustomerToolHandlerProvider),
    venueHandler: ref.watch(aiVenueToolHandlerProvider),
    voucherHandler: ref.watch(aiVoucherToolHandlerProvider),
    paymentHandler: ref.watch(aiPaymentToolHandlerProvider),
    statsHandler: ref.watch(aiStatsToolHandlerProvider),
    stockHandler: ref.watch(aiStockToolHandlerProvider),
    userHandler: ref.watch(aiUserToolHandlerProvider),
    companyHandler: ref.watch(aiCompanyToolHandlerProvider),
    reservationHandler: ref.watch(aiReservationToolHandlerProvider),
    modifierHandler: ref.watch(aiModifierToolHandlerProvider),
    recipeHandler: ref.watch(aiRecipeToolHandlerProvider),
    miscReadHandler: ref.watch(aiMiscReadToolHandlerProvider),
  );
});

// ---------------------------------------------------------------------------
// Command service
// ---------------------------------------------------------------------------

final aiCommandServiceProvider = Provider<AiCommandService>((ref) {
  return AiCommandService(
    toolRegistry: ref.watch(aiToolRegistryProvider),
    handlerRegistry: ref.watch(aiToolHandlerRegistryProvider),
    aiDirectService: ref.watch(aiDirectServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Tool execution loop
// ---------------------------------------------------------------------------

final aiToolExecutionLoopProvider = Provider<AiToolExecutionLoop>((ref) {
  return AiToolExecutionLoop(
    commandService: ref.watch(aiCommandServiceProvider),
    toolRegistry: ref.watch(aiToolRegistryProvider),
  );
});

// ---------------------------------------------------------------------------
// Undo service
// ---------------------------------------------------------------------------

final aiUndoServiceProvider = Provider<AiUndoService>((ref) {
  return AiUndoService(
    aiDirectService: ref.watch(aiDirectServiceProvider),
    itemRepo: ref.watch(itemRepositoryProvider),
    categoryRepo: ref.watch(categoryRepositoryProvider),
    taxRateRepo: ref.watch(taxRateRepositoryProvider),
    supplierRepo: ref.watch(supplierRepositoryProvider),
    manufacturerRepo: ref.watch(manufacturerRepositoryProvider),
    customerRepo: ref.watch(customerRepositoryProvider),
    sectionRepo: ref.watch(sectionRepositoryProvider),
    tableRepo: ref.watch(tableRepositoryProvider),
    voucherRepo: ref.watch(voucherRepositoryProvider),
    paymentMethodRepo: ref.watch(paymentMethodRepositoryProvider),
    companySettingsRepo: ref.watch(companySettingsRepositoryProvider),
  );
});

// ---------------------------------------------------------------------------
// Rate limiter
// ---------------------------------------------------------------------------

final aiRateLimiterProvider = Provider<AiRateLimiter>((ref) {
  return AiRateLimiter(
    aiDirectService: ref.watch(aiDirectServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Conversation manager
// ---------------------------------------------------------------------------

final aiConversationManagerProvider = Provider<AiConversationManager>((ref) {
  return AiConversationManager(
    aiDirectService: ref.watch(aiDirectServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Chat notifier (orchestrator)
// ---------------------------------------------------------------------------

/// Reactive company settings (stream-based, for AI notifier).
final _aiCompanySettingsProvider = StreamProvider<CompanySettingsModel?>((ref) {
  final company = ref.watch(currentCompanyProvider);
  if (company == null) return Stream.value(null);
  return ref.watch(companySettingsRepositoryProvider).watchByCompany(company.id);
});

final aiChatNotifierProvider =
    StateNotifierProvider.autoDispose<AiChatNotifier, AiChatState>((ref) {
  final providerAsync = ref.watch(aiProviderFromSettingsProvider);
  final aiProvider = providerAsync.valueOrNull;
  final company = ref.watch(currentCompanyProvider);
  final user = ref.watch(activeUserProvider);
  final permsAsync = ref.watch(userPermissionCodesProvider);
  final permissions = permsAsync.whenOrNull(data: (codes) => codes) ?? {};
  final settingsAsync = ref.watch(_aiCompanySettingsProvider);
  final companySettings = settingsAsync.valueOrNull;

  return AiChatNotifier(
    provider: aiProvider,
    aiDirectService: ref.watch(aiDirectServiceProvider),
    conversationManager: ref.watch(aiConversationManagerProvider),
    toolExecutionLoop: ref.watch(aiToolExecutionLoopProvider),
    commandService: ref.watch(aiCommandServiceProvider),
    contextBuilder: ref.watch(aiContextBuilderProvider),
    systemPromptBuilder: ref.watch(aiSystemPromptBuilderProvider),
    toolRegistry: ref.watch(aiToolRegistryProvider),
    rateLimiter: ref.watch(aiRateLimiterProvider),
    undoService: ref.watch(aiUndoServiceProvider),
    companySettings: companySettings,
    companyId: company?.id ?? '',
    userId: user?.id ?? '',
    userName: user?.fullName ?? '',
    userPermissions: permissions,
  );
});
