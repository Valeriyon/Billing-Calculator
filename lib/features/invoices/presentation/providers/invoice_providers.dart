import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/invoice_export_service.dart';
import '../../data/invoice_repository.dart';
import '../../domain/invoice_model.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DriftInvoiceRepository(database);
});

/// Loads invoices matching the given filter.
final invoiceListProvider =
    FutureProvider.family<List<InvoiceModel>, InvoiceFilter>((ref, filter) {
      final repository = ref.watch(invoiceRepositoryProvider);
      return repository.getInvoices(filter: filter);
    });

/// Loads a single invoice with line items.
final invoiceDetailProvider = FutureProvider.family<InvoiceDetailModel?, int>((
  ref,
  invoiceId,
) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getInvoiceDetail(invoiceId);
});

final invoiceExportServiceProvider = Provider<InvoiceExportService>((ref) {
  return const InvoiceExportService();
});
