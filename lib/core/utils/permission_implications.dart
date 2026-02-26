/// Direct requirements: key requires all values to be granted.
/// Only immediate dependencies — transitivity is resolved by the functions.
const Map<String, List<String>> _directRequirements = {
  // orders
  'orders.view_all': ['orders.view'],
  'orders.view_paid': ['orders.view'],
  'orders.view_cancelled': ['orders.view'],
  'orders.view_detail': ['orders.view'],
  'orders.edit': ['orders.view'],
  'orders.edit_others': ['orders.edit', 'orders.view_all'],
  'orders.void_item': ['orders.view'],
  'orders.void_bill': ['orders.view'],
  'orders.reopen': ['orders.view'],
  'orders.transfer': ['orders.view'],
  'orders.split': ['orders.view'],
  'orders.merge': ['orders.view'],
  'orders.assign_customer': ['orders.view'],
  'orders.bump': ['orders.view'],
  'orders.bump_back': ['orders.view'],

  // discounts
  'discounts.apply_item': ['discounts.apply_item_limited'],
  'discounts.apply_bill': ['discounts.apply_bill_limited'],

  // payments
  'payments.refund': ['payments.accept'],
  'payments.refund_item': ['payments.accept'],
  'payments.skip_cash_dialog': ['payments.method_cash'],
  'payments.adjust_tip': ['payments.accept_tip'],

  // register
  'register.close_session': ['register.view_session'],
  'register.view_all_sessions': ['register.view_session'],

  // shifts
  'shifts.view_all': ['shifts.view_own'],
  'shifts.manage': ['shifts.view_all'],

  // products
  'products.view_cost': ['products.view'],
  'products.manage': ['products.view'],
  'products.manage_categories': ['products.view'],
  'products.manage_modifiers': ['products.view'],
  'products.manage_recipes': ['products.view'],
  'products.manage_purchase_price': ['products.manage', 'products.view_cost'],
  'products.manage_tax': ['products.manage'],
  'products.manage_suppliers': ['products.view'],
  'products.manage_manufacturers': ['products.view'],
  'products.set_availability': ['products.view'],

  // stock
  'stock.receive': ['stock.view_levels', 'stock.view_documents'],
  'stock.wastage': ['stock.view_levels', 'stock.view_documents'],
  'stock.adjust': ['stock.view_levels', 'stock.view_documents'],
  'stock.count': ['stock.view_levels', 'stock.view_documents'],
  'stock.transfer': ['stock.view_levels', 'stock.view_documents'],
  'stock.set_price_strategy': ['stock.receive'],
  'stock.manage_warehouses': ['stock.view_levels'],

  // customers
  'customers.manage': ['customers.view'],
  'customers.manage_credit': ['customers.view'],
  'customers.manage_loyalty': ['customers.view'],

  // vouchers
  'vouchers.manage': ['vouchers.view'],

  // venue
  'venue.reservations_manage': ['venue.reservations_view'],

  // stats
  'stats.receipts_all': ['stats.receipts'],
  'stats.sales_all': ['stats.sales'],
  'stats.orders_all': ['stats.orders'],
  'stats.tips_all': ['stats.tips'],
  'stats.cash_journal_all': ['stats.cash_journal'],

  // users
  'users.manage': ['users.view'],
  'users.assign_roles': ['users.view'],
  'users.manage_permissions': ['users.view'],
};

/// Returns all transitive prerequisites for [code].
///
/// Uses iterative BFS. The result does NOT include [code] itself.
Set<String> getRequiredPermissions(String code) {
  final result = <String>{};
  final queue = <String>[..._directRequirements[code] ?? []];

  while (queue.isNotEmpty) {
    final current = queue.removeLast();
    if (result.add(current)) {
      queue.addAll(_directRequirements[current] ?? []);
    }
  }

  return result;
}

/// Returns all transitive dependents of [code].
///
/// Scans [_directRequirements] in reverse. The result does NOT include [code]
/// itself.
Set<String> getDependentPermissions(String code) {
  final result = <String>{};
  final queue = <String>[];

  // Find all permissions that directly require [code]
  for (final entry in _directRequirements.entries) {
    if (entry.value.contains(code)) {
      queue.add(entry.key);
    }
  }

  while (queue.isNotEmpty) {
    final current = queue.removeLast();
    if (result.add(current)) {
      for (final entry in _directRequirements.entries) {
        if (entry.value.contains(current)) {
          queue.add(entry.key);
        }
      }
    }
  }

  return result;
}
