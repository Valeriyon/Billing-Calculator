/// App-level customer entity used by UI and state management.
class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.name,
    required this.creditLimit,
    required this.creditDue,
    this.phone,
    this.address,
    required this.ledgerId,
    required this.createdAt,
  });

  final int id;
  final String name;
  final double creditLimit;
  final double creditDue;
  final String? phone;
  final String? address;
  final int ledgerId;
  final DateTime createdAt;

  CustomerModel copyWith({
    int? id,
    String? name,
    double? creditLimit,
    double? creditDue,
    String? phone,
    String? address,
    int? ledgerId,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      creditLimit: creditLimit ?? this.creditLimit,
      creditDue: creditDue ?? this.creditDue,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      ledgerId: ledgerId ?? this.ledgerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Data needed to create or update a customer.
class CustomerDraft {
  const CustomerDraft({required this.name, this.phone, this.address});

  final String name;
  final String? phone;
  final String? address;
}
