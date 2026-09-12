// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Store Billing';

  @override
  String get checkout => 'Checkout';

  @override
  String get invoiceHistory => 'Invoice History';

  @override
  String get settings => 'Settings';

  @override
  String get confirmSave => 'Confirm & Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get goBack => 'Go Back';

  @override
  String get emptyCart => 'Your cart is empty';

  @override
  String get noInvoices => 'No invoices found';

  @override
  String get invoiceNotFound => 'Invoice not found';

  @override
  String get failedToLoadInvoices => 'Failed to load invoices';

  @override
  String get retry => 'Retry';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get print => 'Print';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get quantity => 'Qty';

  @override
  String get rate => 'Rate';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get cash => 'Cash';

  @override
  String get upi => 'UPI';

  @override
  String get credit => 'Credit';

  @override
  String get exitApp => 'Exit app';

  @override
  String get exitConfirmMessage => 'Are you sure you want to exit the app?';

  @override
  String get exit => 'Exit';
}
