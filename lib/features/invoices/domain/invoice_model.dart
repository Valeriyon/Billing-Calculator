import '../../../core/database/tables/invoices.dart';
import '../../calculator/domain/bill_item.dart';

/// App-level invoice entity used by UI and state management.
class InvoiceModel {
  const InvoiceModel({
    required this.id,
    required this.invoiceNo,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentMode,
    required this.paymentStatus,
    this.customerId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String invoiceNo;
  final double subtotalAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final PaymentMode paymentMode;
  final PaymentStatus paymentStatus;
  final int? customerId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// Line item on a saved invoice.
class InvoiceLineItemModel {
  const InvoiceLineItemModel({
    required this.id,
    required this.invoiceId,
    required this.itemName,
    required this.quantity,
    required this.rate,
    required this.total,
    required this.serialNo,
  });

  final int id;
  final int invoiceId;
  final String itemName;
  final double quantity;
  final double rate;
  final double total;
  final int serialNo;
}

/// Full invoice with line items for detail views and export.
class InvoiceDetailModel {
  const InvoiceDetailModel({required this.invoice, required this.items});

  final InvoiceModel invoice;
  final List<InvoiceLineItemModel> items;
}

/// Filter criteria for invoice list queries.
class InvoiceFilter {
  const InvoiceFilter({this.startDate, this.endDate, this.paymentMode});

  final DateTime? startDate;
  final DateTime? endDate;
  final PaymentMode? paymentMode;

  InvoiceFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    PaymentMode? paymentMode,
    bool clearDates = false,
    bool clearPaymentMode = false,
  }) {
    return InvoiceFilter(
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      paymentMode: clearPaymentMode ? null : (paymentMode ?? this.paymentMode),
    );
  }
}

/// Input for saving a new invoice from checkout.
class SaveInvoiceRequest {
  const SaveInvoiceRequest({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.paymentMode,
    required this.paidAmount,
    required this.paymentStatus,
    this.customerId,
    this.notes,
  });

  final List<BillItem> items;
  final double subtotal;
  final double discount;
  final double grandTotal;
  final PaymentMode paymentMode;
  final double paidAmount;
  final PaymentStatus paymentStatus;
  final int? customerId;
  final String? notes;
}

/// Result of a successful invoice save.
class SaveInvoiceResult {
  const SaveInvoiceResult({required this.invoiceId, required this.invoiceNo});

  final int invoiceId;
  final String invoiceNo;
}
