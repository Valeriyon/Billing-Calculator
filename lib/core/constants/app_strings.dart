/// App string constants (fallback for when localization is not loaded)
class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'Store Billing';
  static const String appVersion = '1.0.0';

  // Calculator Screen
  static const String register = 'Register #1';
  static const String statusOpen = 'OPEN';
  static const String quantity = 'Qty';
  static const String rate = 'Rate';
  static const String total = 'Total';
  static const String checkout = 'Checkout';
  static const String addItem = 'Add Item';
  static const String clearAll = 'Clear All';
  static const String currentBill = 'Current Bill';
  static const String emptyBill = 'No items in bill';

  // Checkout Screen
  static const String billSummary = 'Bill Summary';
  static const String subtotal = 'Subtotal';
  static const String discount = 'Discount';
  static const String grandTotal = 'Grand Total';
  static const String paymentMode = 'Payment Mode';
  static const String cash = 'Cash';
  static const String upi = 'GPay/UPI';
  static const String credit = 'Credit';
  static const String notes = 'Notes (Optional)';
  static const String confirmSave = 'Confirm & Save';
  static const String cancel = 'Cancel';
  static const String invoiceSaved = 'Invoice saved successfully!';

  // Invoice List
  static const String invoices = 'Invoices';
  static const String invoiceHistory = 'Invoice History';
  static const String consolidatedView = 'Consolidated';
  static const String detailedView = 'Detailed';
  static const String filter = 'Filter';
  static const String export = 'Export';
  static const String exportPdf = 'Export PDF';
  static const String exportExcel = 'Export Excel';
  static const String noInvoices = 'No invoices found';
  static const String dateRange = 'Date Range';
  static const String searchInvoice = 'Search Invoice No.';

  // Invoice Detail
  static const String invoiceDetail = 'Invoice Detail';
  static const String invoiceNo = 'Invoice No';
  static const String date = 'Date';
  static const String time = 'Time';
  static const String items = 'Items';
  static const String share = 'Share';
  static const String print = 'Print';

  // Settings
  static const String settings = 'Settings';
  static const String theme = 'Theme';
  static const String lightMode = 'Light Mode';
  static const String darkMode = 'Dark Mode';
  static const String contrastMode = 'High Contrast';
  static const String textSize = 'Text Size';
  static const String language = 'Language';
  static const String english = 'English';
  static const String malayalam = 'മലയാളം';
  static const String hindi = 'हिंदी';
  static const String tamil = 'தமிழ்';

  // Common
  static const String ok = 'OK';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String back = 'Back';
  static const String close = 'Close';
  static const String apply = 'Apply';
  static const String reset = 'Reset';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';

  // Errors
  static const String errorGeneric = 'Something went wrong';
  static const String errorEmptyBill = 'Cannot checkout with empty bill';
  static const String errorInvalidInput = 'Invalid input';

  // Currency
  static const String currencySymbol = '₹';
}
