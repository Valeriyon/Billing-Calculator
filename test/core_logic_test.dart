import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:billing_app_pos/core/database/app_database.dart';
import 'package:billing_app_pos/features/calculator/domain/bill_item.dart';
import 'package:billing_app_pos/features/calculator/domain/calc_logic.dart';
import 'package:billing_app_pos/features/calculator/presentation/providers/calculator_providers.dart';
import 'package:billing_app_pos/features/customers/data/customer_repository.dart';
import 'package:billing_app_pos/features/customers/domain/customer_model.dart';
import 'package:billing_app_pos/features/invoices/data/invoice_repository.dart';
import 'package:billing_app_pos/features/invoices/domain/invoice_model.dart';
import 'package:billing_app_pos/core/database/tables/invoices.dart';

void main() {
  group('CalculatorNotifier', () {
    late ProviderContainer container;
    late CalculatorNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(calculatorProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('appendDigit builds rate input', () {
      notifier.appendDigit('1');
      notifier.appendDigit('2');
      notifier.appendDigit('5');

      expect(notifier.state.rateInput, '125');
      expect(notifier.state.rate, 125);
    });

    test('appendDigit limits decimal places to two', () {
      notifier.appendDigit('1');
      notifier.appendDigit('.');
      notifier.appendDigit('2');
      notifier.appendDigit('3');
      notifier.appendDigit('4');

      expect(notifier.state.rateInput, '1.23');
    });

    test('addBillItem requires quantity and rate', () {
      notifier.appendDigit('0');
      expect(notifier.state.canAddItem, isFalse);

      notifier.clearInput();
      notifier.appendDigit('2');
      notifier.setMode(CalcInputMode.quantity);
      expect(notifier.state.canAddItem, isFalse);
    });

    test('addItem adds line and clears inputs', () {
      notifier.setMode(CalcInputMode.quantity);
      notifier.appendDigit('2');
      notifier.setMode(CalcInputMode.rate);
      notifier.appendDigit('5');
      notifier.appendDigit('0');

      notifier.addItem();

      expect(notifier.state.billItems, hasLength(1));
      expect(notifier.state.billItems.first.total, 100);
      expect(notifier.state.quantityInput, isEmpty);
      expect(notifier.state.rateInput, isEmpty);
    });

    test('addBillItem merges by barcode', () {
      notifier.addBillItem(
        BillItem(id: '1', name: 'Rice', quantity: 1, rate: 10, barcode: '123'),
      );
      notifier.addBillItem(
        BillItem(id: '2', name: 'Rice', quantity: 2, rate: 10, barcode: '123'),
      );

      expect(notifier.state.billItems, hasLength(1));
      expect(notifier.state.billItems.first.quantity, 3);
    });

    test('clearBill resets items', () {
      notifier.setMode(CalcInputMode.quantity);
      notifier.appendDigit('1');
      notifier.setMode(CalcInputMode.rate);
      notifier.appendDigit('1');
      notifier.addItem();

      notifier.clearBill();

      expect(notifier.state.billItems, isEmpty);
      expect(notifier.state.subtotal, 0);
    });
  });

  group('DriftCustomerRepository', () {
    late AppDatabase db;
    late DriftCustomerRepository repository;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.ensureDefaultItemSeries();
      repository = DriftCustomerRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insertCustomer creates customer with ledger', () async {
      final id = await repository.insertCustomer(
        const CustomerDraft(name: 'Alice', phone: '9876543210'),
      );

      final customer = await repository.getCustomerById(id);
      expect(customer, isNotNull);
      expect(customer!.name, 'Alice');
      expect(customer.ledgerId, greaterThan(0));
    });

    test('insertCustomer rejects empty name', () async {
      expect(
        () => repository.insertCustomer(const CustomerDraft(name: '  ')),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('DriftInvoiceRepository', () {
    late AppDatabase db;
    late DriftInvoiceRepository invoiceRepository;
    late DriftCustomerRepository customerRepository;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.ensureDefaultItemSeries();
      invoiceRepository = DriftInvoiceRepository(db);
      customerRepository = DriftCustomerRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('saveInvoice persists invoice and line items', () async {
      final result = await invoiceRepository.saveInvoice(
        SaveInvoiceRequest(
          items: [BillItem(id: '1', name: 'Rice', quantity: 2, rate: 50)],
          subtotal: 100,
          discount: 0,
          grandTotal: 100,
          paymentMode: PaymentMode.cash,
          paidAmount: 100,
          paymentStatus: PaymentStatus.fulfilled,
        ),
      );

      expect(result.invoiceNo, startsWith('INV-'));

      final detail = await invoiceRepository.getInvoiceDetail(result.invoiceId);
      expect(detail, isNotNull);
      expect(detail!.items, hasLength(1));
      expect(detail.invoice.totalAmount, 100);
    });

    test('saveInvoice updates customer credit for credit payment', () async {
      final customerId = await customerRepository.insertCustomer(
        const CustomerDraft(name: 'Bob'),
      );

      await invoiceRepository.saveInvoice(
        SaveInvoiceRequest(
          items: [BillItem(id: '1', name: 'Oil', quantity: 1, rate: 200)],
          subtotal: 200,
          discount: 0,
          grandTotal: 200,
          paymentMode: PaymentMode.credit,
          paidAmount: 0,
          paymentStatus: PaymentStatus.pending,
          customerId: customerId,
        ),
      );

      final customer = await customerRepository.getCustomerById(customerId);
      expect(customer!.creditDue, 200);
    });
  });

  group('AppDatabase migrations', () {
    test('creates schema on fresh database', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final count = await db.getTotalItemsCount();
      expect(count, 0);

      expect(db.schemaVersion, 8);
    });
  });
}
