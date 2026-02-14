/// Sealed state for customer display broadcast content.
/// Serialized to JSON for Supabase Broadcast.
sealed class CustomerDisplayContent {
  const CustomerDisplayContent();

  Map<String, dynamic> toJson();

  factory CustomerDisplayContent.fromJson(Map<String, dynamic> json) {
    return switch (json['state']) {
      'idle' => const DisplayIdle(),
      'items' => DisplayItems.fromJson(json),
      'message' => DisplayMessage.fromJson(json),
      _ => const DisplayIdle(),
    };
  }
}

class DisplayIdle extends CustomerDisplayContent {
  const DisplayIdle();

  @override
  Map<String, dynamic> toJson() => {'state': 'idle'};
}

class DisplayItems extends CustomerDisplayContent {
  const DisplayItems({
    required this.items,
    required this.subtotal,
    required this.total,
    this.currencySymbol = '',
    this.discountAmount = 0,
    this.taxTotal = 0,
  });

  final List<DisplayItem> items;
  final int subtotal;
  final int total;
  final String currencySymbol;
  final int discountAmount;
  final int taxTotal;

  @override
  Map<String, dynamic> toJson() => {
        'state': 'items',
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'total': total,
        'currencySymbol': currencySymbol,
        'discountAmount': discountAmount,
        'taxTotal': taxTotal,
      };

  factory DisplayItems.fromJson(Map<String, dynamic> json) {
    return DisplayItems(
      items: (json['items'] as List?)
              ?.map((i) => DisplayItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: json['subtotal'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      currencySymbol: json['currencySymbol'] as String? ?? '',
      discountAmount: json['discountAmount'] as int? ?? 0,
      taxTotal: json['taxTotal'] as int? ?? 0,
    );
  }
}

class DisplayItem {
  const DisplayItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  final String name;
  final double quantity;
  final int unitPrice;
  final int totalPrice;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        if (notes != null) 'notes': notes,
      };

  factory DisplayItem.fromJson(Map<String, dynamic> json) {
    return DisplayItem(
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPrice: json['unitPrice'] as int? ?? 0,
      totalPrice: json['totalPrice'] as int? ?? 0,
      notes: json['notes'] as String?,
    );
  }
}

class DisplayMessage extends CustomerDisplayContent {
  const DisplayMessage({
    required this.text,
    this.messageType,
    this.autoClearAfterMs,
  });

  final String text;
  final String? messageType; // 'success', 'info'
  final int? autoClearAfterMs;

  @override
  Map<String, dynamic> toJson() => {
        'state': 'message',
        'text': text,
        if (messageType != null) 'messageType': messageType,
        if (autoClearAfterMs != null) 'autoClearAfterMs': autoClearAfterMs,
      };

  factory DisplayMessage.fromJson(Map<String, dynamic> json) {
    return DisplayMessage(
      text: json['text'] as String? ?? '',
      messageType: json['messageType'] as String?,
      autoClearAfterMs: json['autoClearAfterMs'] as int?,
    );
  }
}
