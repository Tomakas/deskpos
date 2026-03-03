import '../models/ai_command_result.dart';
import 'ai_bill_order_tool_handler.dart';
import 'ai_catalog_tool_handler.dart';
import 'ai_company_tool_handler.dart';
import 'ai_customer_tool_handler.dart';
import 'ai_misc_read_tool_handler.dart';
import 'ai_modifier_tool_handler.dart';
import 'ai_payment_tool_handler.dart';
import 'ai_recipe_tool_handler.dart';
import 'ai_reservation_tool_handler.dart';
import 'ai_stats_tool_handler.dart';
import 'ai_stock_tool_handler.dart';
import 'ai_user_tool_handler.dart';
import 'ai_venue_tool_handler.dart';
import 'ai_voucher_tool_handler.dart';

/// Maps tool names to domain-specific handlers. Central dispatch hub.
class AiToolHandlerRegistry {
  AiToolHandlerRegistry({
    required AiBillOrderToolHandler billOrderHandler,
    required AiCatalogToolHandler catalogHandler,
    required AiCustomerToolHandler customerHandler,
    required AiVenueToolHandler venueHandler,
    required AiVoucherToolHandler voucherHandler,
    required AiPaymentToolHandler paymentHandler,
    required AiStatsToolHandler statsHandler,
    required AiStockToolHandler stockHandler,
    required AiUserToolHandler userHandler,
    required AiCompanyToolHandler companyHandler,
    required AiReservationToolHandler reservationHandler,
    required AiModifierToolHandler modifierHandler,
    required AiRecipeToolHandler recipeHandler,
    required AiMiscReadToolHandler miscReadHandler,
  })  : _billOrderHandler = billOrderHandler,
        _catalogHandler = catalogHandler,
        _customerHandler = customerHandler,
        _venueHandler = venueHandler,
        _voucherHandler = voucherHandler,
        _paymentHandler = paymentHandler,
        _statsHandler = statsHandler,
        _stockHandler = stockHandler,
        _userHandler = userHandler,
        _companyHandler = companyHandler,
        _reservationHandler = reservationHandler,
        _modifierHandler = modifierHandler,
        _recipeHandler = recipeHandler,
        _miscReadHandler = miscReadHandler;

  final AiBillOrderToolHandler _billOrderHandler;
  final AiCatalogToolHandler _catalogHandler;
  final AiCustomerToolHandler _customerHandler;
  final AiVenueToolHandler _venueHandler;
  final AiVoucherToolHandler _voucherHandler;
  final AiPaymentToolHandler _paymentHandler;
  final AiStatsToolHandler _statsHandler;
  final AiStockToolHandler _stockHandler;
  final AiUserToolHandler _userHandler;
  final AiCompanyToolHandler _companyHandler;
  final AiReservationToolHandler _reservationHandler;
  final AiModifierToolHandler _modifierHandler;
  final AiRecipeToolHandler _recipeHandler;
  final AiMiscReadToolHandler _miscReadHandler;

  /// Tool name prefixes mapped to their domain handlers.
  static const _billOrderTools = {
    'list_bills',
    'get_bill',
    'list_orders',
    'get_order',
  };

  static const _catalogTools = {
    'list_items',
    'search_items',
    'get_item',
    'create_item',
    'update_item',
    'delete_item',
    'list_categories',
    'get_category',
    'create_category',
    'update_category',
    'delete_category',
    'list_tax_rates',
    'create_tax_rate',
    'update_tax_rate',
    'delete_tax_rate',
    'list_manufacturers',
    'create_manufacturer',
    'update_manufacturer',
    'delete_manufacturer',
    'list_suppliers',
    'create_supplier',
    'update_supplier',
    'delete_supplier',
  };

  static const _customerTools = {
    'list_customers',
    'search_customers',
    'get_customer',
    'create_customer',
    'update_customer',
    'delete_customer',
    'adjust_customer_points',
    'adjust_customer_credit',
  };

  static const _venueTools = {
    'list_sections',
    'create_section',
    'update_section',
    'delete_section',
    'list_tables',
    'get_table',
    'create_table',
    'update_table',
    'delete_table',
  };

  static const _voucherTools = {
    'list_vouchers',
    'get_voucher',
    'create_voucher',
    'update_voucher',
    'delete_voucher',
  };

  static const _paymentTools = {
    'list_payment_methods',
  };

  static const _statsTools = {
    'get_sales_summary',
    'get_revenue_summary',
    'get_tips_summary',
    'get_orders_summary',
    'get_shifts_summary',
    'get_register_sessions',
  };

  static const _stockTools = {
    'list_stock_levels',
    'create_stock_document',
  };

  static const _userTools = {
    'list_users',
    'get_user',
    'update_user',
  };

  static const _companyTools = {
    'get_company_settings',
    'update_company_settings',
  };

  static const _reservationTools = {
    'list_reservations',
    'get_reservation',
    'create_reservation',
    'update_reservation',
    'delete_reservation',
  };

  static const _modifierTools = {
    'list_modifier_groups',
    'get_modifier_group',
    'create_modifier_group',
    'update_modifier_group',
    'delete_modifier_group',
    'list_modifier_group_items',
    'add_modifier_group_item',
    'remove_modifier_group_item',
    'list_item_modifier_groups',
    'assign_modifier_group_to_item',
    'unassign_modifier_group_from_item',
  };

  static const _recipeTools = {
    'list_recipes',
    'get_recipe',
    'create_recipe',
    'update_recipe',
    'delete_recipe',
  };

  static const _miscReadTools = {
    'list_customer_transactions',
    'list_stock_documents',
    'get_stock_document',
    'list_stock_movements',
    'list_roles',
    'list_registers',
    'list_currencies',
    'list_warehouses',
  };

  /// Dispatches a tool call to the appropriate domain handler.
  Future<AiCommandResult> dispatch(
    String toolName,
    Map<String, dynamic> args,
    String companyId, {
    required String userId,
  }) async {
    if (_billOrderTools.contains(toolName)) {
      return _billOrderHandler.handle(toolName, args, companyId);
    }
    if (_catalogTools.contains(toolName)) {
      return _catalogHandler.handle(toolName, args, companyId);
    }
    if (_customerTools.contains(toolName)) {
      return _customerHandler.handle(
        toolName,
        args,
        companyId,
        userId: userId,
      );
    }
    if (_venueTools.contains(toolName)) {
      return _venueHandler.handle(toolName, args, companyId);
    }
    if (_voucherTools.contains(toolName)) {
      return _voucherHandler.handle(toolName, args, companyId);
    }
    if (_paymentTools.contains(toolName)) {
      return _paymentHandler.handle(toolName, args, companyId);
    }
    if (_statsTools.contains(toolName)) {
      return _statsHandler.handle(toolName, args, companyId);
    }
    if (_stockTools.contains(toolName)) {
      return _stockHandler.handle(toolName, args, companyId, userId: userId);
    }
    if (_userTools.contains(toolName)) {
      return _userHandler.handle(toolName, args, companyId);
    }
    if (_companyTools.contains(toolName)) {
      return _companyHandler.handle(toolName, args, companyId);
    }
    if (_reservationTools.contains(toolName)) {
      return _reservationHandler.handle(toolName, args, companyId);
    }
    if (_modifierTools.contains(toolName)) {
      return _modifierHandler.handle(toolName, args, companyId);
    }
    if (_recipeTools.contains(toolName)) {
      return _recipeHandler.handle(toolName, args, companyId);
    }
    if (_miscReadTools.contains(toolName)) {
      return _miscReadHandler.handle(toolName, args, companyId);
    }
    return AiCommandError('Unknown tool: $toolName');
  }
}
