/// Bill item model for calculator
class BillItem {
  BillItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.rate,
    this.inventoryItemId,
    this.barcode,
    this.discountAmount = 0.0,
  });

  final String id;
  final String name;
  final double quantity;
  final double rate;
  final int? inventoryItemId;
  final String? barcode;
  final double discountAmount;

  /// Calculate total for this item (qty * rate - discount)
  double get total => (quantity * rate) - discountAmount;

  /// Create a copy with updated values
  BillItem copyWith({
    String? id,
    String? name,
    double? quantity,
    double? rate,
    int? inventoryItemId,
    String? barcode,
    double? discountAmount,
  }) {
    return BillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      barcode: barcode ?? this.barcode,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }

  /// Create from JSON map
  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      inventoryItemId: (json['inventoryItemId'] as num?)?.toInt(),
      barcode: json['barcode'] as String?,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'rate': rate,
      'inventoryItemId': inventoryItemId,
      'barcode': barcode,
      'discountAmount': discountAmount,
    };
  }

  @override
  String toString() {
    return 'BillItem(id: $id, name: $name, qty: $quantity, rate: $rate, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
