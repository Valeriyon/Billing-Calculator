import 'package:drift/drift.dart' hide Column;

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/invoices.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/utils/serial_number.dart';
import '../domain/invoice_model.dart';

abstract class InvoiceRepository {
  Future<List<InvoiceModel>> getInvoices({
    InvoiceFilter filter = const InvoiceFilter(),
  });
  Future<InvoiceDetailModel?> getInvoiceDetail(int id);
  Future<SaveInvoiceResult> saveInvoice(SaveInvoiceRequest request);
}

class DriftInvoiceRepository implements InvoiceRepository {
  DriftInvoiceRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<InvoiceModel>> getInvoices({
    InvoiceFilter filter = const InvoiceFilter(),
  }) async {
    List<Invoice> rows;

    if (filter.startDate != null && filter.endDate != null) {
      rows = await _db.getInvoicesByDateRange(
        DateHelpers.startOfDay(filter.startDate!),
        DateHelpers.endOfDay(filter.endDate!),
      );
    } else if (filter.paymentMode != null) {
      rows = await _db.getInvoicesByPaymentMode(filter.paymentMode!);
    } else {
      rows = await _db.getAllInvoices();
    }

    return rows.map(_mapInvoice).toList();
  }

  @override
  Future<InvoiceDetailModel?> getInvoiceDetail(int id) async {
    final invoice = await _db.getInvoiceById(id);
    if (invoice == null) {
      return null;
    }

    final items = await _db.getItemsForInvoice(id);
    return InvoiceDetailModel(
      invoice: _mapInvoice(invoice),
      items: items.map(_mapLineItem).toList(),
    );
  }

  @override
  Future<SaveInvoiceResult> saveInvoice(SaveInvoiceRequest request) async {
    if (request.paymentMode == PaymentMode.credit &&
        request.customerId == null) {
      throw StateError('Customer is required for credit payment');
    }

    late final String invoiceNo;
    late final int invoiceId;

    await _db.transaction(() async {
      final now = DateTime.now();
      final count = await _db.getInvoiceCountForDate(now);
      invoiceNo = SerialNumberGenerator.generateInvoiceNumber(now, count + 1);

      invoiceId = await _db.insertInvoice(
        InvoicesCompanion.insert(
          invoiceNo: invoiceNo,
          subtotalAmount: Value(request.subtotal),
          discountAmount: Value(request.discount),
          totalAmount: Value(request.grandTotal),
          paidAmount: Value(request.paidAmount),
          paymentMode: request.paymentMode,
          paymentStatus: request.paymentStatus,
          customerId: Value(
            request.paymentMode == PaymentMode.credit
                ? request.customerId
                : null,
          ),
          notes: Value(request.notes?.isEmpty ?? true ? null : request.notes),
        ),
      );

      final invoiceItems = request.items.asMap().entries.map((entry) {
        return InvoiceItemsCompanion.insert(
          invoiceId: invoiceId,
          itemName: entry.value.name,
          quantity: entry.value.quantity,
          rate: entry.value.rate,
          total: entry.value.total,
          serialNo: Value(entry.key + 1),
        );
      }).toList();

      await _db.insertInvoiceItems(invoiceItems);

      if (request.paymentMode == PaymentMode.credit) {
        final customer = await _db.getCustomerById(request.customerId!);
        if (customer == null) {
          throw StateError('Selected customer was not found');
        }

        final balanceDue = request.grandTotal - request.paidAmount;
        final didUpdate = await _db.updateCustomer(
          customer.copyWith(creditDue: customer.creditDue + balanceDue),
        );
        if (!didUpdate) {
          throw StateError('Unable to update customer credit balance');
        }
      }
    });

    return SaveInvoiceResult(invoiceId: invoiceId, invoiceNo: invoiceNo);
  }

  InvoiceModel _mapInvoice(Invoice row) {
    return InvoiceModel(
      id: row.id,
      invoiceNo: row.invoiceNo,
      subtotalAmount: row.subtotalAmount,
      discountAmount: row.discountAmount,
      totalAmount: row.totalAmount,
      paidAmount: row.paidAmount,
      paymentMode: row.paymentMode,
      paymentStatus: row.paymentStatus,
      customerId: row.customerId,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  InvoiceLineItemModel _mapLineItem(InvoiceItem row) {
    return InvoiceLineItemModel(
      id: row.id,
      invoiceId: row.invoiceId,
      itemName: row.itemName,
      quantity: row.quantity,
      rate: row.rate,
      total: row.total,
      serialNo: row.serialNo,
    );
  }
}
