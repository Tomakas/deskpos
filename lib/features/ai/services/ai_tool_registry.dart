import '../../../core/ai/models/ai_provider_models.dart';

/// Central registry of all AI tool definitions with permission mapping
/// and read-only classification.
class AiToolRegistry {
  AiToolRegistry() {
    for (final tool in _allTools) {
      _toolsByName[tool.name] = tool;
    }
  }

  final Map<String, AiToolDefinition> _toolsByName = {};

  /// Returns tool definitions filtered by user's permissions.
  List<AiToolDefinition> getTools(Set<String> permissions) {
    return _allTools.where((tool) {
      final required = getRequiredPermission(tool.name);
      if (required == null) return true;
      return permissions.contains(required);
    }).toList();
  }

  /// Returns required permission for a tool, or null if no permission needed.
  String? getRequiredPermission(String toolName) {
    return _permissionMap[toolName];
  }

  /// Returns true if tool is read-only (auto-execute, no confirmation).
  bool isReadOnly(String toolName) => _readOnlyTools.contains(toolName);

  /// Returns the tool definition by name, or null if not found.
  AiToolDefinition? getToolDefinition(String toolName) =>
      _toolsByName[toolName];

  /// Returns a short Czech confirmation label for write tools.
  String getConfirmLabel(String toolName, Map<String, dynamic> args) {
    return switch (toolName) {
      // Items
      'create_item' =>
        'Vytvoření položky: ${args['name'] ?? ''}',
      'update_item' => 'Úprava položky',
      'delete_item' => 'Smazání položky',
      // Categories
      'create_category' =>
        'Vytvoření kategorie: ${args['name'] ?? ''}',
      'update_category' => 'Úprava kategorie',
      'delete_category' => 'Smazání kategorie',
      // Tax rates
      'create_tax_rate' =>
        'Vytvoření daňové sazby: ${args['label'] ?? ''}',
      'update_tax_rate' => 'Úprava daňové sazby',
      'delete_tax_rate' => 'Smazání daňové sazby',
      // Manufacturers
      'create_manufacturer' =>
        'Vytvoření výrobce: ${args['name'] ?? ''}',
      'update_manufacturer' => 'Úprava výrobce',
      'delete_manufacturer' => 'Smazání výrobce',
      // Suppliers
      'create_supplier' =>
        'Vytvoření dodavatele: ${args['name'] ?? ''}',
      'update_supplier' => 'Úprava dodavatele',
      'delete_supplier' => 'Smazání dodavatele',
      // Customers
      'create_customer' =>
        'Vytvoření zákazníka: ${args['first_name'] ?? ''} ${args['last_name'] ?? ''}'
            .trim(),
      'update_customer' => 'Úprava zákazníka',
      'delete_customer' => 'Smazání zákazníka',
      'adjust_customer_points' => 'Úprava bodů zákazníka',
      'adjust_customer_credit' => 'Úprava kreditu zákazníka',
      // Venue
      'create_section' =>
        'Vytvoření sekce: ${args['name'] ?? ''}',
      'update_section' => 'Úprava sekce',
      'delete_section' => 'Smazání sekce',
      'create_table' =>
        'Vytvoření stolu: ${args['name'] ?? ''}',
      'update_table' => 'Úprava stolu',
      'delete_table' => 'Smazání stolu',
      // Vouchers
      'create_voucher' => 'Vytvoření voucheru',
      'update_voucher' => 'Úprava voucheru',
      'delete_voucher' => 'Smazání voucheru',
      // Reservations
      'create_reservation' =>
        'Vytvoření rezervace: ${args['customer_name'] ?? ''}',
      'update_reservation' => 'Úprava rezervace',
      'delete_reservation' => 'Smazání rezervace',
      // Modifier groups
      'create_modifier_group' =>
        'Vytvoření skupiny modifikátorů: ${args['name'] ?? ''}',
      'update_modifier_group' => 'Úprava skupiny modifikátorů',
      'delete_modifier_group' => 'Smazání skupiny modifikátorů',
      'add_modifier_group_item' => 'Přidání položky do skupiny modifikátorů',
      'remove_modifier_group_item' =>
        'Odebrání položky ze skupiny modifikátorů',
      'assign_modifier_group_to_item' =>
        'Přiřazení skupiny modifikátorů k položce',
      'unassign_modifier_group_from_item' =>
        'Odebrání skupiny modifikátorů z položky',
      // Recipes
      'create_recipe' => 'Vytvoření receptury',
      'update_recipe' => 'Úprava receptury',
      'delete_recipe' => 'Smazání receptury',
      // Stock
      'create_stock_document' => _stockDocLabel(args),
      // Users
      'update_user' => 'Úprava uživatele',
      // Company
      'update_company_settings' => 'Úprava nastavení firmy',
      _ => toolName.replaceAll('_', ' '),
    };
  }

  static String _stockDocLabel(Map<String, dynamic> args) {
    final type = args['type'] as String? ?? '';
    final lines = args['lines'] as List? ?? [];
    final typeLabel = switch (type) {
      'receipt' => 'Příjem',
      'waste' => 'Odpad',
      'correction' => 'Korekce',
      'inventory' => 'Inventura',
      _ => type,
    };
    return 'Skladový doklad: $typeLabel (${lines.length} položek)';
  }

  // ---------------------------------------------------------------------------
  // Permission mapping
  // ---------------------------------------------------------------------------

  static const _permissionMap = <String, String>{
    // Bills & orders — read
    'list_bills': 'orders.view',
    'get_bill': 'orders.view_detail',
    'list_orders': 'orders.view',
    'get_order': 'orders.view_detail',
    // Products — read
    'list_items': 'products.view',
    'search_items': 'products.view',
    'get_item': 'products.view',
    'list_categories': 'products.view',
    'get_category': 'products.view',
    'list_tax_rates': 'products.view',
    'list_manufacturers': 'products.view',
    'list_suppliers': 'products.view',
    // Products — write
    'create_item': 'products.manage',
    'update_item': 'products.manage',
    'delete_item': 'products.manage',
    'create_category': 'products.manage_categories',
    'update_category': 'products.manage_categories',
    'delete_category': 'products.manage_categories',
    'create_tax_rate': 'settings_register.tax_rates',
    'update_tax_rate': 'settings_register.tax_rates',
    'delete_tax_rate': 'settings_register.tax_rates',
    'create_manufacturer': 'products.manage_manufacturers',
    'update_manufacturer': 'products.manage_manufacturers',
    'delete_manufacturer': 'products.manage_manufacturers',
    'create_supplier': 'products.manage_suppliers',
    'update_supplier': 'products.manage_suppliers',
    'delete_supplier': 'products.manage_suppliers',
    // Customer — read
    'list_customers': 'customers.view',
    'search_customers': 'customers.view',
    'get_customer': 'customers.view',
    // Customer — write
    'create_customer': 'customers.manage',
    'update_customer': 'customers.manage',
    'delete_customer': 'customers.manage',
    'adjust_customer_points': 'customers.manage_loyalty',
    'adjust_customer_credit': 'customers.manage_credit',
    // Venue — read
    'list_sections': 'settings_venue.sections',
    'list_tables': 'settings_venue.tables',
    'get_table': 'settings_venue.tables',
    // Venue — write
    'create_section': 'settings_venue.sections',
    'update_section': 'settings_venue.sections',
    'delete_section': 'settings_venue.sections',
    'create_table': 'settings_venue.tables',
    'update_table': 'settings_venue.tables',
    'delete_table': 'settings_venue.tables',
    // Voucher — read
    'list_vouchers': 'vouchers.view',
    'get_voucher': 'vouchers.view',
    // Voucher — write
    'create_voucher': 'vouchers.manage',
    'update_voucher': 'vouchers.manage',
    'delete_voucher': 'vouchers.manage',
    // Reservations — read
    'list_reservations': 'venue.reservations_view',
    'get_reservation': 'venue.reservations_view',
    // Reservations — write
    'create_reservation': 'venue.reservations_manage',
    'update_reservation': 'venue.reservations_manage',
    'delete_reservation': 'venue.reservations_manage',
    // Modifiers — read
    'list_modifier_groups': 'products.view',
    'get_modifier_group': 'products.view',
    'list_modifier_group_items': 'products.view',
    'list_item_modifier_groups': 'products.view',
    // Modifiers — write
    'create_modifier_group': 'products.manage_modifiers',
    'update_modifier_group': 'products.manage_modifiers',
    'delete_modifier_group': 'products.manage_modifiers',
    'add_modifier_group_item': 'products.manage_modifiers',
    'remove_modifier_group_item': 'products.manage_modifiers',
    'assign_modifier_group_to_item': 'products.manage_modifiers',
    'unassign_modifier_group_from_item': 'products.manage_modifiers',
    // Recipes — read
    'list_recipes': 'products.view',
    'get_recipe': 'products.view',
    // Recipes — write
    'create_recipe': 'products.manage_recipes',
    'update_recipe': 'products.manage_recipes',
    'delete_recipe': 'products.manage_recipes',
    // Stats — read
    'get_sales_summary': 'stats.sales',
    'get_revenue_summary': 'stats.receipts',
    'get_tips_summary': 'stats.tips',
    'get_orders_summary': 'stats.orders',
    'get_shifts_summary': 'stats.shifts',
    'get_register_sessions': 'stats.z_reports',
    // Stock — read
    'list_stock_levels': 'stock.view_levels',
    'list_stock_documents': 'stock.view_documents',
    'get_stock_document': 'stock.view_documents',
    'list_stock_movements': 'stock.view_movements',
    // Stock — write
    'create_stock_document': 'stock.adjust',
    // Payment — read
    'list_payment_methods': 'settings_register.payment_methods',
    // Misc — read
    'list_customer_transactions': 'customers.view',
    'list_roles': 'users.assign_roles',
    'list_registers': 'settings_register.manage',
    'list_currencies': 'settings_company.info',
    'list_warehouses': 'stock.manage_warehouses',
    // User — read
    'list_users': 'users.view',
    'get_user': 'users.view',
    // User — write
    'update_user': 'users.manage',
    // Company — read
    'get_company_settings': 'settings_company.info',
    // Company — write
    'update_company_settings': 'settings_company.info',
  };

  // ---------------------------------------------------------------------------
  // Read-only tools (auto-execute without confirmation)
  // ---------------------------------------------------------------------------

  static const _readOnlyTools = <String>{
    'list_bills',
    'get_bill',
    'list_orders',
    'get_order',
    'list_items',
    'search_items',
    'get_item',
    'list_categories',
    'get_category',
    'list_tax_rates',
    'list_manufacturers',
    'list_suppliers',
    'list_customers',
    'search_customers',
    'get_customer',
    'list_sections',
    'list_tables',
    'get_table',
    'list_vouchers',
    'get_voucher',
    'list_reservations',
    'get_reservation',
    'list_modifier_groups',
    'get_modifier_group',
    'list_modifier_group_items',
    'list_item_modifier_groups',
    'list_recipes',
    'get_recipe',
    'list_customer_transactions',
    'list_stock_documents',
    'get_stock_document',
    'list_stock_movements',
    'list_roles',
    'list_registers',
    'list_currencies',
    'list_warehouses',
    'get_sales_summary',
    'get_revenue_summary',
    'get_tips_summary',
    'get_orders_summary',
    'get_shifts_summary',
    'get_register_sessions',
    'list_stock_levels',
    'list_payment_methods',
    'list_users',
    'get_user',
    'get_company_settings',
  };

  // ---------------------------------------------------------------------------
  // Tool definitions
  // ---------------------------------------------------------------------------

  static final _allTools = <AiToolDefinition>[
    // ---- Bills ----
    const AiToolDefinition(
      name: 'list_bills',
      description:
          'List bills (accounts/receipts). Optional filters: status '
          '(opened/paid/cancelled/refunded) and days (lookback period). '
          'Returns id, bill_number, status, total_gross, paid_amount, '
          'customer, table, opened_at, closed_at. Max 50 results.',
      parameters: {
        'type': 'object',
        'properties': {
          'status': {
            'type': 'string',
            'enum': ['opened', 'paid', 'cancelled', 'refunded'],
            'description': 'Filter by bill status',
          },
          'days': {
            'type': 'integer',
            'description': 'Only bills opened in the last N days',
          },
        },
      },
    ),
    const AiToolDefinition(
      name: 'get_bill',
      description:
          'Get full bill detail including all items and payments. '
          'Returns financial totals, loyalty info, items with prices, '
          'and payment breakdown.',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Bill UUID'},
        },
        'required': ['id'],
      },
    ),
    // ---- Orders ----
    const AiToolDefinition(
      name: 'list_orders',
      description:
          'List orders for a specific bill. '
          'Returns order_number, status, item_count, subtotal, '
          'is_storno, created_by.',
      parameters: {
        'type': 'object',
        'properties': {
          'bill_id': {'type': 'string', 'description': 'Bill UUID'},
        },
        'required': ['bill_id'],
      },
    ),
    const AiToolDefinition(
      name: 'get_order',
      description:
          'Get order detail with all items. '
          'Returns item_name, quantity, unit_price, tax, discount, status.',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Order UUID'},
        },
        'required': ['id'],
      },
    ),
    // ---- Catalog: Items ----
    const AiToolDefinition(
      name: 'list_items',
      description:
          'List all items in the catalog. Optionally filter by category. '
          'Returns id, name, unitPrice, category_id, sku, item_type, is_active.',
      parameters: {
        'type': 'object',
        'properties': {
          'category_id': {
            'type': 'string',
            'description': 'Optional category UUID to filter by',
          },
        },
      },
    ),
    const AiToolDefinition(
      name: 'search_items',
      description: 'Search items/products in the catalog by name or SKU',
      parameters: {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description': 'Search query (name or SKU)',
          },
        },
        'required': ['query'],
      },
    ),
    const AiToolDefinition(
      name: 'get_item',
      description: 'Get detailed information about a specific item by ID',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Item UUID'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'create_item',
      description: 'Create a new item/product in the catalog',
      parameters: {
        'type': 'object',
        'properties': {
          'name': {'type': 'string', 'description': 'Item name'},
          'category_id': {'type': 'string', 'description': 'Category UUID'},
          'unit_price': {
            'type': 'integer',
            'description': 'Price in minor units (e.g. halere)',
          },
          'item_type': {
            'type': 'string',
            'enum': [
              'product',
              'service',
              'counter',
              'recipe',
              'ingredient',
            ],
            'description': 'Type of item',
          },
          'unit': {
            'type': 'string',
            'enum': [
              'ks',
              'g',
              'kg',
              'ml',
              'cl',
              'l',
              'mm',
              'cm',
              'm',
              'min',
              'h',
            ],
            'description': 'Unit of measure',
          },
          'sku': {'type': 'string', 'description': 'Stock keeping unit code'},
          'sale_tax_rate_id': {
            'type': 'string',
            'description': 'Tax rate UUID',
          },
          'is_active': {
            'type': 'boolean',
            'description': 'Whether item is active',
          },
        },
        'required': ['name'],
      },
    ),
    const AiToolDefinition(
      name: 'update_item',
      description: 'Update an existing item in the catalog',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Item UUID'},
          'name': {'type': 'string', 'description': 'New item name'},
          'category_id': {'type': 'string', 'description': 'New category UUID'},
          'unit_price': {
            'type': 'integer',
            'description': 'New price in minor units',
          },
          'item_type': {
            'type': 'string',
            'enum': [
              'product',
              'service',
              'counter',
              'recipe',
              'ingredient',
            ],
            'description': 'New item type',
          },
          'unit': {
            'type': 'string',
            'enum': [
              'ks',
              'g',
              'kg',
              'ml',
              'cl',
              'l',
              'mm',
              'cm',
              'm',
              'min',
              'h',
            ],
            'description': 'New unit of measure',
          },
          'sku': {'type': 'string', 'description': 'New SKU code'},
          'sale_tax_rate_id': {
            'type': 'string',
            'description': 'New tax rate UUID',
          },
          'is_active': {
            'type': 'boolean',
            'description': 'Whether item is active',
          },
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'delete_item',
      description: 'Delete an item from the catalog (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Item UUID to delete'},
        },
        'required': ['id'],
      },
    ),
    // ---- Catalog: Categories ----
    const AiToolDefinition(
      name: 'list_categories',
      description: 'List all categories in the catalog',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'get_category',
      description: 'Get detailed information about a specific category',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Category UUID'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'create_category',
      description: 'Create a new category in the catalog',
      parameters: {
        'type': 'object',
        'properties': {
          'name': {'type': 'string', 'description': 'Category name'},
          'parent_id': {
            'type': 'string',
            'description': 'Parent category UUID for subcategories',
          },
          'is_active': {
            'type': 'boolean',
            'description': 'Whether category is active',
          },
        },
        'required': ['name'],
      },
    ),
    const AiToolDefinition(
      name: 'update_category',
      description: 'Update an existing category',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Category UUID'},
          'name': {'type': 'string', 'description': 'New category name'},
          'parent_id': {
            'type': 'string',
            'description': 'New parent category UUID',
          },
          'is_active': {
            'type': 'boolean',
            'description': 'Whether category is active',
          },
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'delete_category',
      description: 'Delete a category (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'Category UUID to delete',
          },
        },
        'required': ['id'],
      },
    ),
    // ---- Catalog: Tax Rates ----
    const AiToolDefinition(
      name: 'list_tax_rates',
      description: 'List all tax rates',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'create_tax_rate',
      description: 'Create a new tax rate',
      parameters: {
        'type': 'object',
        'properties': {
          'label': {'type': 'string', 'description': 'Tax rate label'},
          'type': {
            'type': 'string',
            'enum': ['regular', 'noTax', 'constant', 'mixed'],
            'description': 'Tax calculation type',
          },
          'rate': {
            'type': 'integer',
            'description': 'Tax rate in hundredths of percent (e.g. 2100 = 21%)',
          },
          'is_default': {
            'type': 'boolean',
            'description': 'Whether this is the default tax rate',
          },
        },
        'required': ['label', 'rate'],
      },
    ),
    const AiToolDefinition(
      name: 'update_tax_rate',
      description: 'Update an existing tax rate',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Tax rate UUID'},
          'label': {'type': 'string', 'description': 'New label'},
          'rate': {'type': 'integer', 'description': 'New rate'},
          'is_default': {
            'type': 'boolean',
            'description': 'Whether this is the default',
          },
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'delete_tax_rate',
      description: 'Delete a tax rate (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'Tax rate UUID to delete',
          },
        },
        'required': ['id'],
      },
    ),
    // ---- Catalog: Manufacturers ----
    const AiToolDefinition(
      name: 'list_manufacturers',
      description: 'List all manufacturers',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'create_manufacturer',
      description: 'Create a new manufacturer',
      parameters: {
        'type': 'object',
        'properties': {
          'name': {'type': 'string', 'description': 'Manufacturer name'},
        },
        'required': ['name'],
      },
    ),
    const AiToolDefinition(
      name: 'update_manufacturer',
      description: 'Update an existing manufacturer',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Manufacturer UUID'},
          'name': {'type': 'string', 'description': 'New name'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'delete_manufacturer',
      description: 'Delete a manufacturer (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'Manufacturer UUID to delete',
          },
        },
        'required': ['id'],
      },
    ),
    // ---- Catalog: Suppliers ----
    const AiToolDefinition(
      name: 'list_suppliers',
      description: 'List all suppliers',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'create_supplier',
      description: 'Create a new supplier',
      parameters: {
        'type': 'object',
        'properties': {
          'supplier_name': {'type': 'string', 'description': 'Supplier name'},
          'contact_person': {
            'type': 'string',
            'description': 'Contact person name',
          },
          'email': {'type': 'string', 'description': 'Email address'},
          'phone': {'type': 'string', 'description': 'Phone number'},
        },
        'required': ['supplier_name'],
      },
    ),
    const AiToolDefinition(
      name: 'update_supplier',
      description: 'Update an existing supplier',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Supplier UUID'},
          'supplier_name': {'type': 'string', 'description': 'New name'},
          'contact_person': {
            'type': 'string',
            'description': 'New contact person',
          },
          'email': {'type': 'string', 'description': 'New email'},
          'phone': {'type': 'string', 'description': 'New phone'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'delete_supplier',
      description: 'Delete a supplier (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'Supplier UUID to delete',
          },
        },
        'required': ['id'],
      },
    ),
    // ---- Customer ----
    const AiToolDefinition(
      name: 'list_customers',
      description:
          'List all customers. '
          'Returns id, first_name, last_name, email, phone, points, credit.',
      parameters: {
        'type': 'object',
        'properties': {},
      },
    ),
    const AiToolDefinition(
      name: 'search_customers',
      description: 'Search customers by name, email, or phone',
      parameters: {
        'type': 'object',
        'properties': {
          'query': {'type': 'string', 'description': 'Search query'},
        },
        'required': ['query'],
      },
    ),
    const AiToolDefinition(
      name: 'get_customer',
      description: 'Get detailed information about a specific customer',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Customer UUID'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'create_customer',
      description: 'Create a new customer',
      parameters: {
        'type': 'object',
        'properties': {
          'first_name': {
            'type': 'string',
            'description': 'Customer first name',
          },
          'last_name': {
            'type': 'string',
            'description': 'Customer last name',
          },
          'email': {'type': 'string', 'description': 'Email address'},
          'phone': {'type': 'string', 'description': 'Phone number'},
          'address': {'type': 'string', 'description': 'Address'},
        },
        'required': ['first_name', 'last_name'],
      },
    ),
    const AiToolDefinition(
      name: 'update_customer',
      description: 'Update an existing customer',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Customer UUID'},
          'first_name': {'type': 'string', 'description': 'New first name'},
          'last_name': {'type': 'string', 'description': 'New last name'},
          'email': {'type': 'string', 'description': 'New email'},
          'phone': {'type': 'string', 'description': 'New phone'},
          'address': {'type': 'string', 'description': 'New address'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'delete_customer',
      description: 'Delete a customer (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'Customer UUID to delete',
          },
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'adjust_customer_points',
      description: 'Add or subtract loyalty points for a customer',
      parameters: {
        'type': 'object',
        'properties': {
          'customer_id': {'type': 'string', 'description': 'Customer UUID'},
          'delta': {
            'type': 'integer',
            'description':
                'Points to add (positive) or subtract (negative)',
          },
          'note': {'type': 'string', 'description': 'Reason for adjustment'},
        },
        'required': ['customer_id', 'delta'],
      },
    ),
    const AiToolDefinition(
      name: 'adjust_customer_credit',
      description: 'Add or subtract credit for a customer',
      parameters: {
        'type': 'object',
        'properties': {
          'customer_id': {'type': 'string', 'description': 'Customer UUID'},
          'delta': {
            'type': 'integer',
            'description':
                'Credit to add (positive) or subtract (negative) in minor units',
          },
          'note': {'type': 'string', 'description': 'Reason for adjustment'},
        },
        'required': ['customer_id', 'delta'],
      },
    ),
    // ---- Venue: Sections ----
    const AiToolDefinition(
      name: 'list_sections',
      description: 'List all venue sections',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'create_section',
      description: 'Create a new venue section',
      parameters: {
        'type': 'object',
        'properties': {
          'name': {'type': 'string', 'description': 'Section name'},
          'color': {'type': 'string', 'description': 'Color hex code'},
          'is_active': {
            'type': 'boolean',
            'description': 'Whether section is active',
          },
        },
        'required': ['name'],
      },
    ),
    const AiToolDefinition(
      name: 'update_section',
      description: 'Update an existing venue section',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Section UUID'},
          'name': {'type': 'string', 'description': 'New name'},
          'color': {'type': 'string', 'description': 'New color'},
          'is_active': {
            'type': 'boolean',
            'description': 'Whether section is active',
          },
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'delete_section',
      description: 'Delete a venue section (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'Section UUID to delete',
          },
        },
        'required': ['id'],
      },
    ),
    // ---- Venue: Tables ----
    const AiToolDefinition(
      name: 'list_tables',
      description: 'List all tables in the venue',
      parameters: {
        'type': 'object',
        'properties': {
          'section_id': {
            'type': 'string',
            'description': 'Filter by section UUID (optional)',
          },
        },
      },
    ),
    const AiToolDefinition(
      name: 'get_table',
      description: 'Get detailed information about a specific table',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Table UUID'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'create_table',
      description: 'Create a new table in the venue',
      parameters: {
        'type': 'object',
        'properties': {
          'name': {'type': 'string', 'description': 'Table name'},
          'section_id': {'type': 'string', 'description': 'Section UUID'},
          'capacity': {
            'type': 'integer',
            'description': 'Seating capacity',
          },
          'is_active': {
            'type': 'boolean',
            'description': 'Whether table is active',
          },
        },
        'required': ['name'],
      },
    ),
    const AiToolDefinition(
      name: 'update_table',
      description: 'Update an existing table',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Table UUID'},
          'name': {'type': 'string', 'description': 'New name'},
          'section_id': {'type': 'string', 'description': 'New section UUID'},
          'capacity': {'type': 'integer', 'description': 'New capacity'},
          'is_active': {
            'type': 'boolean',
            'description': 'Whether table is active',
          },
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'delete_table',
      description: 'Delete a table (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Table UUID to delete'},
        },
        'required': ['id'],
      },
    ),
    // ---- Voucher ----
    const AiToolDefinition(
      name: 'list_vouchers',
      description: 'List vouchers, optionally filtered by type or status',
      parameters: {
        'type': 'object',
        'properties': {
          'type': {
            'type': 'string',
            'enum': ['gift', 'deposit', 'discount'],
            'description': 'Filter by voucher type',
          },
          'status': {
            'type': 'string',
            'enum': ['active', 'redeemed', 'expired', 'cancelled'],
            'description': 'Filter by voucher status',
          },
        },
      },
    ),
    const AiToolDefinition(
      name: 'get_voucher',
      description: 'Get detailed information about a specific voucher',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Voucher UUID'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'create_voucher',
      description: 'Create a new voucher. '
          'For discount vouchers, also set discount_type and discount_scope.',
      parameters: {
        'type': 'object',
        'properties': {
          'type': {
            'type': 'string',
            'enum': ['gift', 'deposit', 'discount'],
            'description': 'Voucher type',
          },
          'value': {
            'type': 'integer',
            'description':
                'Voucher value in minor units (gift/deposit) or hundredths of percent (discount)',
          },
          'code': {
            'type': 'string',
            'description': 'Voucher code (auto-generated if omitted)',
          },
          'discount_type': {
            'type': 'string',
            'enum': ['absolute', 'percent'],
            'description':
                'Discount calculation type (only for type=discount)',
          },
          'discount_scope': {
            'type': 'string',
            'enum': ['bill', 'product', 'category'],
            'description':
                'What the discount applies to (only for type=discount)',
          },
          'item_id': {
            'type': 'string',
            'description':
                'Restrict to specific item UUID (only for discount_scope=product)',
          },
          'category_id': {
            'type': 'string',
            'description':
                'Restrict to specific category UUID (only for discount_scope=category)',
          },
          'min_order_value': {
            'type': 'integer',
            'description':
                'Minimum order value in minor units for voucher to apply',
          },
          'max_uses': {
            'type': 'integer',
            'description': 'Maximum number of uses',
          },
          'customer_id': {
            'type': 'string',
            'description': 'Restrict to specific customer UUID',
          },
          'expires_at': {
            'type': 'string',
            'description': 'Expiration date (ISO 8601)',
          },
          'note': {'type': 'string', 'description': 'Note'},
        },
        'required': ['type', 'value'],
      },
    ),
    const AiToolDefinition(
      name: 'update_voucher',
      description: 'Update an existing voucher',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Voucher UUID'},
          'status': {
            'type': 'string',
            'enum': ['active', 'redeemed', 'expired', 'cancelled'],
            'description': 'New status',
          },
          'discount_type': {
            'type': 'string',
            'enum': ['absolute', 'percent'],
            'description': 'New discount type (discount vouchers only)',
          },
          'discount_scope': {
            'type': 'string',
            'enum': ['bill', 'product', 'category'],
            'description': 'New discount scope (discount vouchers only)',
          },
          'item_id': {
            'type': 'string',
            'description': 'New item UUID (discount_scope=product)',
          },
          'category_id': {
            'type': 'string',
            'description': 'New category UUID (discount_scope=category)',
          },
          'min_order_value': {
            'type': 'integer',
            'description': 'New minimum order value in minor units',
          },
          'max_uses': {'type': 'integer', 'description': 'New max uses'},
          'expires_at': {
            'type': 'string',
            'description': 'New expiration date',
          },
          'note': {'type': 'string', 'description': 'New note'},
        },
        'required': ['id'],
      },
    ),
    // ---- Voucher: Delete ----
    const AiToolDefinition(
      name: 'delete_voucher',
      description: 'Delete a voucher (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Voucher UUID to delete'},
        },
        'required': ['id'],
      },
    ),
    // ---- Reservations ----
    const AiToolDefinition(
      name: 'list_reservations',
      description:
          'List reservations. Optional filters: date (ISO date), '
          'status (created/confirmed/seated/cancelled). '
          'Returns id, customer_name, reservation_date, party_size, status.',
      parameters: {
        'type': 'object',
        'properties': {
          'date': {
            'type': 'string',
            'description': 'Filter by date (ISO 8601, e.g. 2026-03-03)',
          },
          'status': {
            'type': 'string',
            'enum': ['created', 'confirmed', 'seated', 'cancelled'],
            'description': 'Filter by reservation status',
          },
        },
      },
    ),
    const AiToolDefinition(
      name: 'get_reservation',
      description: 'Get detailed information about a specific reservation',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Reservation UUID'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'create_reservation',
      description: 'Create a new reservation',
      parameters: {
        'type': 'object',
        'properties': {
          'customer_name': {
            'type': 'string',
            'description': 'Customer name',
          },
          'customer_phone': {
            'type': 'string',
            'description': 'Customer phone',
          },
          'customer_id': {
            'type': 'string',
            'description': 'Link to existing customer UUID',
          },
          'reservation_date': {
            'type': 'string',
            'description': 'Reservation date and time (ISO 8601)',
          },
          'party_size': {
            'type': 'integer',
            'description': 'Number of guests (default 2)',
          },
          'duration_minutes': {
            'type': 'integer',
            'description': 'Duration in minutes (default 90)',
          },
          'table_id': {
            'type': 'string',
            'description': 'Table UUID',
          },
          'notes': {
            'type': 'string',
            'description': 'Notes for the reservation',
          },
          'status': {
            'type': 'string',
            'enum': ['created', 'confirmed', 'seated', 'cancelled'],
            'description': 'Initial status (default: created)',
          },
        },
        'required': ['customer_name', 'reservation_date'],
      },
    ),
    const AiToolDefinition(
      name: 'update_reservation',
      description: 'Update an existing reservation',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Reservation UUID'},
          'customer_name': {'type': 'string', 'description': 'New customer name'},
          'customer_phone': {'type': 'string', 'description': 'New phone'},
          'customer_id': {'type': 'string', 'description': 'New customer UUID'},
          'reservation_date': {
            'type': 'string',
            'description': 'New date and time (ISO 8601)',
          },
          'party_size': {'type': 'integer', 'description': 'New party size'},
          'duration_minutes': {
            'type': 'integer',
            'description': 'New duration in minutes',
          },
          'table_id': {'type': 'string', 'description': 'New table UUID'},
          'notes': {'type': 'string', 'description': 'New notes'},
          'status': {
            'type': 'string',
            'enum': ['created', 'confirmed', 'seated', 'cancelled'],
            'description': 'New status',
          },
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'delete_reservation',
      description: 'Delete a reservation (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'Reservation UUID to delete',
          },
        },
        'required': ['id'],
      },
    ),
    // ---- Modifier Groups ----
    const AiToolDefinition(
      name: 'list_modifier_groups',
      description: 'List all modifier groups',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'get_modifier_group',
      description: 'Get detailed information about a modifier group',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Modifier group UUID'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'create_modifier_group',
      description: 'Create a new modifier group',
      parameters: {
        'type': 'object',
        'properties': {
          'name': {'type': 'string', 'description': 'Group name'},
          'min_selections': {
            'type': 'integer',
            'description': 'Minimum selections required (default 0)',
          },
          'max_selections': {
            'type': 'integer',
            'description': 'Maximum selections allowed (null = unlimited)',
          },
          'sort_order': {
            'type': 'integer',
            'description': 'Sort order (default 0)',
          },
        },
        'required': ['name'],
      },
    ),
    const AiToolDefinition(
      name: 'update_modifier_group',
      description: 'Update an existing modifier group',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Modifier group UUID'},
          'name': {'type': 'string', 'description': 'New name'},
          'min_selections': {
            'type': 'integer',
            'description': 'New minimum selections',
          },
          'max_selections': {
            'type': 'integer',
            'description': 'New maximum selections',
          },
          'sort_order': {'type': 'integer', 'description': 'New sort order'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'delete_modifier_group',
      description: 'Delete a modifier group (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'Modifier group UUID to delete',
          },
        },
        'required': ['id'],
      },
    ),
    // ---- Modifier Group Items ----
    const AiToolDefinition(
      name: 'list_modifier_group_items',
      description:
          'List items in a modifier group. '
          'Returns id, item_id, sort_order, is_default.',
      parameters: {
        'type': 'object',
        'properties': {
          'modifier_group_id': {
            'type': 'string',
            'description': 'Modifier group UUID',
          },
        },
        'required': ['modifier_group_id'],
      },
    ),
    const AiToolDefinition(
      name: 'add_modifier_group_item',
      description: 'Add an item to a modifier group',
      parameters: {
        'type': 'object',
        'properties': {
          'modifier_group_id': {
            'type': 'string',
            'description': 'Modifier group UUID',
          },
          'item_id': {'type': 'string', 'description': 'Item UUID to add'},
          'sort_order': {
            'type': 'integer',
            'description': 'Sort order (default 0)',
          },
          'is_default': {
            'type': 'boolean',
            'description': 'Whether this is a default selection',
          },
        },
        'required': ['modifier_group_id', 'item_id'],
      },
    ),
    const AiToolDefinition(
      name: 'remove_modifier_group_item',
      description: 'Remove an item from a modifier group (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'Modifier group item UUID to remove',
          },
        },
        'required': ['id'],
      },
    ),
    // ---- Item ↔ Modifier Group Assignments ----
    const AiToolDefinition(
      name: 'list_item_modifier_groups',
      description:
          'List modifier groups assigned to an item. '
          'Returns id, modifier_group_id, sort_order.',
      parameters: {
        'type': 'object',
        'properties': {
          'item_id': {'type': 'string', 'description': 'Item UUID'},
        },
        'required': ['item_id'],
      },
    ),
    const AiToolDefinition(
      name: 'assign_modifier_group_to_item',
      description: 'Assign a modifier group to an item',
      parameters: {
        'type': 'object',
        'properties': {
          'item_id': {'type': 'string', 'description': 'Item UUID'},
          'modifier_group_id': {
            'type': 'string',
            'description': 'Modifier group UUID',
          },
          'sort_order': {
            'type': 'integer',
            'description': 'Sort order (default 0)',
          },
        },
        'required': ['item_id', 'modifier_group_id'],
      },
    ),
    const AiToolDefinition(
      name: 'unassign_modifier_group_from_item',
      description: 'Remove a modifier group assignment from an item',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'Item-modifier-group assignment UUID',
          },
        },
        'required': ['id'],
      },
    ),
    // ---- Recipes ----
    const AiToolDefinition(
      name: 'list_recipes',
      description:
          'List all product recipes. '
          'Returns id, parent_product_id, component_product_id, quantity_required.',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'get_recipe',
      description: 'Get detailed information about a specific recipe',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Recipe UUID'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'create_recipe',
      description: 'Create a new product recipe (component relationship)',
      parameters: {
        'type': 'object',
        'properties': {
          'parent_product_id': {
            'type': 'string',
            'description': 'Parent product UUID (the recipe product)',
          },
          'component_product_id': {
            'type': 'string',
            'description': 'Component product UUID (ingredient)',
          },
          'quantity_required': {
            'type': 'number',
            'description': 'Quantity of component required',
          },
        },
        'required': [
          'parent_product_id',
          'component_product_id',
          'quantity_required',
        ],
      },
    ),
    const AiToolDefinition(
      name: 'update_recipe',
      description: 'Update an existing product recipe',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Recipe UUID'},
          'parent_product_id': {
            'type': 'string',
            'description': 'New parent product UUID',
          },
          'component_product_id': {
            'type': 'string',
            'description': 'New component product UUID',
          },
          'quantity_required': {
            'type': 'number',
            'description': 'New quantity required',
          },
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'delete_recipe',
      description: 'Delete a product recipe (soft delete)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
            'description': 'Recipe UUID to delete',
          },
        },
        'required': ['id'],
      },
    ),
    // ---- Misc Read: Customer Transactions ----
    const AiToolDefinition(
      name: 'list_customer_transactions',
      description:
          'List loyalty/credit transactions for a customer. '
          'Returns points_change, credit_change, reference, note, created_at.',
      parameters: {
        'type': 'object',
        'properties': {
          'customer_id': {
            'type': 'string',
            'description': 'Customer UUID',
          },
        },
        'required': ['customer_id'],
      },
    ),
    // ---- Misc Read: Stock Documents & Movements ----
    const AiToolDefinition(
      name: 'list_stock_documents',
      description:
          'List stock documents (receipts, waste, corrections, inventories) '
          'from the default warehouse. Optional days filter.',
      parameters: {
        'type': 'object',
        'properties': {
          'days': {
            'type': 'integer',
            'description': 'Only documents from the last N days',
          },
        },
      },
    ),
    const AiToolDefinition(
      name: 'get_stock_document',
      description:
          'Get stock document detail including all movements with item names.',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'Stock document UUID'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'list_stock_movements',
      description:
          'List stock movements with item names. '
          'Optional filters: item_id, days.',
      parameters: {
        'type': 'object',
        'properties': {
          'item_id': {
            'type': 'string',
            'description': 'Filter by item UUID',
          },
          'days': {
            'type': 'integer',
            'description': 'Only movements from the last N days',
          },
        },
      },
    ),
    // ---- Misc Read: Roles, Registers, Currencies, Warehouses ----
    const AiToolDefinition(
      name: 'list_roles',
      description: 'List all roles (id and name)',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'list_registers',
      description:
          'List all registers with name, code, type, sell_mode, is_main.',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'list_currencies',
      description: 'List active company currencies with exchange rates',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'list_warehouses',
      description: 'List all warehouses with name, is_default, is_active',
      parameters: {'type': 'object', 'properties': {}},
    ),
    // ---- Stats ----
    const AiToolDefinition(
      name: 'get_sales_summary',
      description:
          'Get sales summary — total quantity sold and revenue per item. '
          'Optional days parameter (default 30). '
          'Returns item_id, item_name, total_quantity, total_revenue.',
      parameters: {
        'type': 'object',
        'properties': {
          'days': {
            'type': 'integer',
            'description':
                'Number of days to look back (default 30)',
          },
        },
      },
    ),
    const AiToolDefinition(
      name: 'get_revenue_summary',
      description:
          'Get revenue summary from paid bills — total revenue, tax, discounts, '
          'bill count, guest count. Optional days parameter (default 30).',
      parameters: {
        'type': 'object',
        'properties': {
          'days': {
            'type': 'integer',
            'description': 'Number of days to look back (default 30)',
          },
        },
      },
    ),
    const AiToolDefinition(
      name: 'get_tips_summary',
      description:
          'Get tips summary — total tips, tip count, and breakdown by user. '
          'Optional days parameter (default 30).',
      parameters: {
        'type': 'object',
        'properties': {
          'days': {
            'type': 'integer',
            'description': 'Number of days to look back (default 30)',
          },
        },
      },
    ),
    const AiToolDefinition(
      name: 'get_orders_summary',
      description:
          'Get orders summary — count by status and voided count. '
          'Optional days parameter (default 30).',
      parameters: {
        'type': 'object',
        'properties': {
          'days': {
            'type': 'integer',
            'description': 'Number of days to look back (default 30)',
          },
        },
      },
    ),
    const AiToolDefinition(
      name: 'get_shifts_summary',
      description:
          'Get shifts summary — total shifts, hours worked per user. '
          'Optional days parameter (default 30).',
      parameters: {
        'type': 'object',
        'properties': {
          'days': {
            'type': 'integer',
            'description': 'Number of days to look back (default 30)',
          },
        },
      },
    ),
    const AiToolDefinition(
      name: 'get_register_sessions',
      description:
          'Get closed register sessions (Z-reports) — opening/closing cash, '
          'bill count, order count, difference. '
          'Optional days parameter (default 30).',
      parameters: {
        'type': 'object',
        'properties': {
          'days': {
            'type': 'integer',
            'description': 'Number of days to look back (default 30)',
          },
        },
      },
    ),
    // ---- Stock ----
    const AiToolDefinition(
      name: 'list_stock_levels',
      description:
          'List stock levels for all stock-tracked items in the default warehouse. '
          'Returns item_id, name, quantity, min_quantity, unit, purchase_price, category_id.',
      parameters: {
        'type': 'object',
        'properties': {},
      },
    ),
    const AiToolDefinition(
      name: 'create_stock_document',
      description:
          'Create a stock document with movements. '
          'Types: receipt (goods received), waste (damaged/expired), '
          'correction (adjust outbound), inventory (set absolute quantities). '
          'Each line needs item_id and quantity. '
          'For inventory: quantity is the target absolute value.',
      parameters: {
        'type': 'object',
        'properties': {
          'type': {
            'type': 'string',
            'enum': ['receipt', 'waste', 'correction', 'inventory'],
            'description': 'Document type',
          },
          'note': {
            'type': 'string',
            'description': 'Optional note for the document',
          },
          'lines': {
            'type': 'array',
            'description': 'Document lines',
            'items': {
              'type': 'object',
              'properties': {
                'item_id': {
                  'type': 'string',
                  'description': 'Item UUID',
                },
                'quantity': {
                  'type': 'number',
                  'description':
                      'Quantity (for inventory: target absolute value)',
                },
                'purchase_price': {
                  'type': 'integer',
                  'description':
                      'Purchase price in minor units (optional, for receipts)',
                },
              },
              'required': ['item_id', 'quantity'],
            },
          },
        },
        'required': ['type', 'lines'],
      },
    ),
    // ---- Payment Methods ----
    const AiToolDefinition(
      name: 'list_payment_methods',
      description: 'List all payment methods',
      parameters: {'type': 'object', 'properties': {}},
    ),
    // ---- Users ----
    const AiToolDefinition(
      name: 'list_users',
      description: 'List all users (sensitive fields stripped)',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'get_user',
      description: 'Get user details (sensitive fields stripped)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'User UUID'},
        },
        'required': ['id'],
      },
    ),
    const AiToolDefinition(
      name: 'update_user',
      description: 'Update a user (cannot change PIN or auth fields)',
      parameters: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'User UUID'},
          'full_name': {'type': 'string', 'description': 'New full name'},
          'email': {'type': 'string', 'description': 'New email'},
          'phone': {'type': 'string', 'description': 'New phone'},
          'is_active': {
            'type': 'boolean',
            'description': 'Whether user is active',
          },
        },
        'required': ['id'],
      },
    ),
    // ---- Company Settings ----
    const AiToolDefinition(
      name: 'get_company_settings',
      description: 'Get current company settings',
      parameters: {'type': 'object', 'properties': {}},
    ),
    const AiToolDefinition(
      name: 'update_company_settings',
      description:
          'Update company settings (safe fields only, not AI provider or security)',
      parameters: {
        'type': 'object',
        'properties': {
          'locale': {'type': 'string', 'description': 'Locale code (e.g. cs)'},
          'loyalty_earn_rate': {
            'type': 'integer',
            'description': 'Loyalty points earned per currency unit',
          },
          'loyalty_point_value': {
            'type': 'integer',
            'description': 'Value of one loyalty point in minor units',
          },
          'max_item_discount_percent': {
            'type': 'integer',
            'description': 'Max item discount in hundredths of percent',
          },
          'max_bill_discount_percent': {
            'type': 'integer',
            'description': 'Max bill discount in hundredths of percent',
          },
          'bill_age_warning_minutes': {
            'type': 'integer',
            'description': 'Bill age warning threshold in minutes',
          },
          'bill_age_danger_minutes': {
            'type': 'integer',
            'description': 'Bill age danger threshold in minutes',
          },
          'bill_age_critical_minutes': {
            'type': 'integer',
            'description': 'Bill age critical threshold in minutes',
          },
        },
      },
    ),
  ];
}
