import 'dart:typed_data';

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/tables/invoices.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_helpers.dart';
import '../domain/invoice_model.dart';

class InvoiceExportService {
  const InvoiceExportService();

  Future<void> sharePdf(InvoiceDetailModel detail) async {
    final bytes = await buildPdfBytes(detail);
    final file = await _writeTempFile('${detail.invoice.invoiceNo}.pdf', bytes);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  Future<void> printInvoice(InvoiceDetailModel detail) async {
    final bytes = await buildPdfBytes(detail);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> shareExcel(List<InvoiceModel> invoices) async {
    final bytes = buildExcelBytes(invoices);
    final file = await _writeTempFile('invoice_export.xlsx', bytes);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  Future<Uint8List> buildPdfBytes(InvoiceDetailModel detail) async {
    final invoice = detail.invoice;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              invoice.invoiceNo,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(DateHelpers.formatDateTime(invoice.createdAt)),
          pw.SizedBox(height: 12),
          pw.Text('Payment: ${_paymentModeLabel(invoice.paymentMode)}'),
          pw.Divider(),
          pw.TableHelper.fromTextArray(
            headers: const ['#', 'Item', 'Qty', 'Rate', 'Total'],
            data: detail.items.asMap().entries.map((entry) {
              final item = entry.value;
              return [
                '${entry.key + 1}',
                item.itemName,
                CurrencyFormatter.formatQuantity(item.quantity),
                CurrencyFormatter.formatWithoutSymbol(item.rate),
                CurrencyFormatter.formatWithoutSymbol(item.total),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Subtotal'),
              pw.Text(CurrencyFormatter.format(invoice.subtotalAmount)),
            ],
          ),
          if (invoice.discountAmount > 0)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Discount'),
                pw.Text(
                  '- ${CurrencyFormatter.format(invoice.discountAmount)}',
                ),
              ],
            ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Grand Total',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                CurrencyFormatter.format(invoice.totalAmount),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text('Notes: ${invoice.notes}'),
          ],
        ],
      ),
    );

    return doc.save();
  }

  List<int> buildExcelBytes(List<InvoiceModel> invoices) {
    final excel = Excel.createExcel();
    final sheet = excel['Invoices'];
    excel.delete('Sheet1');

    sheet.appendRow([
      TextCellValue('Invoice No'),
      TextCellValue('Date'),
      TextCellValue('Subtotal'),
      TextCellValue('Discount'),
      TextCellValue('Total'),
      TextCellValue('Payment Mode'),
      TextCellValue('Status'),
    ]);

    for (final invoice in invoices) {
      sheet.appendRow([
        TextCellValue(invoice.invoiceNo),
        TextCellValue(DateHelpers.formatDateTime(invoice.createdAt)),
        DoubleCellValue(invoice.subtotalAmount),
        DoubleCellValue(invoice.discountAmount),
        DoubleCellValue(invoice.totalAmount),
        TextCellValue(_paymentModeLabel(invoice.paymentMode)),
        TextCellValue(_paymentStatusLabel(invoice.paymentStatus)),
      ]);
    }

    return excel.encode()!;
  }

  Future<File> _writeTempFile(String name, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes);
    return file;
  }

  String _paymentModeLabel(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.credit:
        return 'Credit';
    }
  }

  String _paymentStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.fulfilled:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.partial:
        return 'Partial';
    }
  }
}
