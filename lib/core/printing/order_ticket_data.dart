class OrderTicketData {
  const OrderTicketData({
    required this.orderNumber,
    this.tableName,
    required this.createdAt,
    required this.stationLabel,
    required this.items,
  });

  final String orderNumber;
  final String? tableName;
  final DateTime createdAt;

  /// e.g. "KITCHEN", "BAR", or "ORDER"
  final String stationLabel;
  final List<OrderTicketItem> items;
}

class OrderTicketItem {
  const OrderTicketItem({
    required this.quantity,
    required this.unitLabel,
    required this.name,
    this.notes,
    this.modifiers = const [],
  });

  final double quantity;
  final String unitLabel;
  final String name;
  final String? notes;
  final List<OrderTicketModifier> modifiers;
}

class OrderTicketModifier {
  const OrderTicketModifier({
    required this.quantity,
    required this.name,
  });

  final double quantity;
  final String name;
}
