// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _invoiceNoMeta =
      const VerificationMeta('invoiceNo');
  @override
  late final GeneratedColumn<String> invoiceNo = GeneratedColumn<String>(
      'invoice_no', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _subtotalAmountMeta =
      const VerificationMeta('subtotalAmount');
  @override
  late final GeneratedColumn<double> subtotalAmount = GeneratedColumn<double>(
      'subtotal_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _discountAmountMeta =
      const VerificationMeta('discountAmount');
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
      'discount_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _paymentModeMeta =
      const VerificationMeta('paymentMode');
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMode, int> paymentMode =
      GeneratedColumn<int>('payment_mode', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<PaymentMode>($InvoicesTable.$converterpaymentMode);
  static const VerificationMeta _paymentStatusMeta =
      const VerificationMeta('paymentStatus');
  @override
  late final GeneratedColumnWithTypeConverter<PaymentStatus, int>
      paymentStatus = GeneratedColumn<int>('payment_status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<PaymentStatus>($InvoicesTable.$converterpaymentStatus);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceNo,
        subtotalAmount,
        discountAmount,
        totalAmount,
        paymentMode,
        paymentStatus,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(Insertable<Invoice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_no')) {
      context.handle(_invoiceNoMeta,
          invoiceNo.isAcceptableOrUnknown(data['invoice_no']!, _invoiceNoMeta));
    } else if (isInserting) {
      context.missing(_invoiceNoMeta);
    }
    if (data.containsKey('subtotal_amount')) {
      context.handle(
          _subtotalAmountMeta,
          subtotalAmount.isAcceptableOrUnknown(
              data['subtotal_amount']!, _subtotalAmountMeta));
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
          _discountAmountMeta,
          discountAmount.isAcceptableOrUnknown(
              data['discount_amount']!, _discountAmountMeta));
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    }
    context.handle(_paymentModeMeta, const VerificationResult.success());
    context.handle(_paymentStatusMeta, const VerificationResult.success());
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      invoiceNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_no'])!,
      subtotalAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}subtotal_amount'])!,
      discountAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}discount_amount'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      paymentMode: $InvoicesTable.$converterpaymentMode.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}payment_mode'])!),
      paymentStatus: $InvoicesTable.$converterpaymentStatus.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}payment_status'])!),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMode, int, int> $converterpaymentMode =
      const EnumIndexConverter<PaymentMode>(PaymentMode.values);
  static JsonTypeConverter2<PaymentStatus, int, int> $converterpaymentStatus =
      const EnumIndexConverter<PaymentStatus>(PaymentStatus.values);
}

class Invoice extends DataClass implements Insertable<Invoice> {
  /// Primary key - auto increment
  final int id;

  /// Unique invoice number (e.g., INV-20260125-001)
  final String invoiceNo;

  /// Total amount before discount
  final double subtotalAmount;

  /// Discount amount
  final double discountAmount;

  /// Total amount after discount
  final double totalAmount;

  /// Payment mode (cash, upi, credit)
  final PaymentMode paymentMode;

  /// Payment status (pending, partial, fulfilled)
  final PaymentStatus paymentStatus;

  /// Optional notes
  final String? notes;

  /// Created timestamp
  final DateTime createdAt;

  /// Updated timestamp
  final DateTime updatedAt;
  const Invoice(
      {required this.id,
      required this.invoiceNo,
      required this.subtotalAmount,
      required this.discountAmount,
      required this.totalAmount,
      required this.paymentMode,
      required this.paymentStatus,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_no'] = Variable<String>(invoiceNo);
    map['subtotal_amount'] = Variable<double>(subtotalAmount);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['total_amount'] = Variable<double>(totalAmount);
    {
      map['payment_mode'] = Variable<int>(
          $InvoicesTable.$converterpaymentMode.toSql(paymentMode));
    }
    {
      map['payment_status'] = Variable<int>(
          $InvoicesTable.$converterpaymentStatus.toSql(paymentStatus));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      invoiceNo: Value(invoiceNo),
      subtotalAmount: Value(subtotalAmount),
      discountAmount: Value(discountAmount),
      totalAmount: Value(totalAmount),
      paymentMode: Value(paymentMode),
      paymentStatus: Value(paymentStatus),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<int>(json['id']),
      invoiceNo: serializer.fromJson<String>(json['invoiceNo']),
      subtotalAmount: serializer.fromJson<double>(json['subtotalAmount']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paymentMode: $InvoicesTable.$converterpaymentMode
          .fromJson(serializer.fromJson<int>(json['paymentMode'])),
      paymentStatus: $InvoicesTable.$converterpaymentStatus
          .fromJson(serializer.fromJson<int>(json['paymentStatus'])),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceNo': serializer.toJson<String>(invoiceNo),
      'subtotalAmount': serializer.toJson<double>(subtotalAmount),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paymentMode': serializer.toJson<int>(
          $InvoicesTable.$converterpaymentMode.toJson(paymentMode)),
      'paymentStatus': serializer.toJson<int>(
          $InvoicesTable.$converterpaymentStatus.toJson(paymentStatus)),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Invoice copyWith(
          {int? id,
          String? invoiceNo,
          double? subtotalAmount,
          double? discountAmount,
          double? totalAmount,
          PaymentMode? paymentMode,
          PaymentStatus? paymentStatus,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Invoice(
        id: id ?? this.id,
        invoiceNo: invoiceNo ?? this.invoiceNo,
        subtotalAmount: subtotalAmount ?? this.subtotalAmount,
        discountAmount: discountAmount ?? this.discountAmount,
        totalAmount: totalAmount ?? this.totalAmount,
        paymentMode: paymentMode ?? this.paymentMode,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      invoiceNo: data.invoiceNo.present ? data.invoiceNo.value : this.invoiceNo,
      subtotalAmount: data.subtotalAmount.present
          ? data.subtotalAmount.value
          : this.subtotalAmount,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('subtotalAmount: $subtotalAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, invoiceNo, subtotalAmount, discountAmount,
      totalAmount, paymentMode, paymentStatus, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.invoiceNo == this.invoiceNo &&
          other.subtotalAmount == this.subtotalAmount &&
          other.discountAmount == this.discountAmount &&
          other.totalAmount == this.totalAmount &&
          other.paymentMode == this.paymentMode &&
          other.paymentStatus == this.paymentStatus &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<int> id;
  final Value<String> invoiceNo;
  final Value<double> subtotalAmount;
  final Value<double> discountAmount;
  final Value<double> totalAmount;
  final Value<PaymentMode> paymentMode;
  final Value<PaymentStatus> paymentStatus;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.invoiceNo = const Value.absent(),
    this.subtotalAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  InvoicesCompanion.insert({
    this.id = const Value.absent(),
    required String invoiceNo,
    this.subtotalAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    required PaymentMode paymentMode,
    required PaymentStatus paymentStatus,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : invoiceNo = Value(invoiceNo),
        paymentMode = Value(paymentMode),
        paymentStatus = Value(paymentStatus);
  static Insertable<Invoice> custom({
    Expression<int>? id,
    Expression<String>? invoiceNo,
    Expression<double>? subtotalAmount,
    Expression<double>? discountAmount,
    Expression<double>? totalAmount,
    Expression<int>? paymentMode,
    Expression<int>? paymentStatus,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNo != null) 'invoice_no': invoiceNo,
      if (subtotalAmount != null) 'subtotal_amount': subtotalAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  InvoicesCompanion copyWith(
      {Value<int>? id,
      Value<String>? invoiceNo,
      Value<double>? subtotalAmount,
      Value<double>? discountAmount,
      Value<double>? totalAmount,
      Value<PaymentMode>? paymentMode,
      Value<PaymentStatus>? paymentStatus,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return InvoicesCompanion(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceNo.present) {
      map['invoice_no'] = Variable<String>(invoiceNo.value);
    }
    if (subtotalAmount.present) {
      map['subtotal_amount'] = Variable<double>(subtotalAmount.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<int>(
          $InvoicesTable.$converterpaymentMode.toSql(paymentMode.value));
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<int>(
          $InvoicesTable.$converterpaymentStatus.toSql(paymentStatus.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('subtotalAmount: $subtotalAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<int> invoiceId = GeneratedColumn<int>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES invoices (id)'));
  static const VerificationMeta _itemNameMeta =
      const VerificationMeta('itemName');
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
      'item_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
      'rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _discountAmountMeta =
      const VerificationMeta('discountAmount');
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
      'discount_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _serialNoMeta =
      const VerificationMeta('serialNo');
  @override
  late final GeneratedColumn<int> serialNo = GeneratedColumn<int>(
      'serial_no', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceId,
        itemName,
        quantity,
        rate,
        total,
        discountAmount,
        serialNo,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta));
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
          _rateMeta, rate.isAcceptableOrUnknown(data['rate']!, _rateMeta));
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
          _discountAmountMeta,
          discountAmount.isAcceptableOrUnknown(
              data['discount_amount']!, _discountAmountMeta));
    }
    if (data.containsKey('serial_no')) {
      context.handle(_serialNoMeta,
          serialNo.isAcceptableOrUnknown(data['serial_no']!, _serialNoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}invoice_id'])!,
      itemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      rate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rate'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      discountAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}discount_amount'])!,
      serialNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}serial_no'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  /// Primary key - auto increment
  final int id;

  /// Foreign key to invoice
  final int invoiceId;

  /// Item name (default: "Item 1", "Item 2", etc.)
  final String itemName;

  /// Quantity (can be decimal, e.g., 1.5)
  final double quantity;

  /// Rate per unit (can be decimal, e.g., 12.50)
  final double rate;

  /// Total = quantity * rate
  final double total;

  /// Item-level discount (optional)
  final double discountAmount;

  /// Serial number for ordering within invoice
  final int serialNo;

  /// Created timestamp
  final DateTime createdAt;
  const InvoiceItem(
      {required this.id,
      required this.invoiceId,
      required this.itemName,
      required this.quantity,
      required this.rate,
      required this.total,
      required this.discountAmount,
      required this.serialNo,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_id'] = Variable<int>(invoiceId);
    map['item_name'] = Variable<String>(itemName);
    map['quantity'] = Variable<double>(quantity);
    map['rate'] = Variable<double>(rate);
    map['total'] = Variable<double>(total);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['serial_no'] = Variable<int>(serialNo);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      itemName: Value(itemName),
      quantity: Value(quantity),
      rate: Value(rate),
      total: Value(total),
      discountAmount: Value(discountAmount),
      serialNo: Value(serialNo),
      createdAt: Value(createdAt),
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<int>(json['id']),
      invoiceId: serializer.fromJson<int>(json['invoiceId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      rate: serializer.fromJson<double>(json['rate']),
      total: serializer.fromJson<double>(json['total']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      serialNo: serializer.fromJson<int>(json['serialNo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceId': serializer.toJson<int>(invoiceId),
      'itemName': serializer.toJson<String>(itemName),
      'quantity': serializer.toJson<double>(quantity),
      'rate': serializer.toJson<double>(rate),
      'total': serializer.toJson<double>(total),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'serialNo': serializer.toJson<int>(serialNo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InvoiceItem copyWith(
          {int? id,
          int? invoiceId,
          String? itemName,
          double? quantity,
          double? rate,
          double? total,
          double? discountAmount,
          int? serialNo,
          DateTime? createdAt}) =>
      InvoiceItem(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        itemName: itemName ?? this.itemName,
        quantity: quantity ?? this.quantity,
        rate: rate ?? this.rate,
        total: total ?? this.total,
        discountAmount: discountAmount ?? this.discountAmount,
        serialNo: serialNo ?? this.serialNo,
        createdAt: createdAt ?? this.createdAt,
      );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      rate: data.rate.present ? data.rate.value : this.rate,
      total: data.total.present ? data.total.value : this.total,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      serialNo: data.serialNo.present ? data.serialNo.value : this.serialNo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('rate: $rate, ')
          ..write('total: $total, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('serialNo: $serialNo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, invoiceId, itemName, quantity, rate,
      total, discountAmount, serialNo, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.itemName == this.itemName &&
          other.quantity == this.quantity &&
          other.rate == this.rate &&
          other.total == this.total &&
          other.discountAmount == this.discountAmount &&
          other.serialNo == this.serialNo &&
          other.createdAt == this.createdAt);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<int> id;
  final Value<int> invoiceId;
  final Value<String> itemName;
  final Value<double> quantity;
  final Value<double> rate;
  final Value<double> total;
  final Value<double> discountAmount;
  final Value<int> serialNo;
  final Value<DateTime> createdAt;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rate = const Value.absent(),
    this.total = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.serialNo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    this.id = const Value.absent(),
    required int invoiceId,
    required String itemName,
    required double quantity,
    required double rate,
    required double total,
    this.discountAmount = const Value.absent(),
    this.serialNo = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : invoiceId = Value(invoiceId),
        itemName = Value(itemName),
        quantity = Value(quantity),
        rate = Value(rate),
        total = Value(total);
  static Insertable<InvoiceItem> custom({
    Expression<int>? id,
    Expression<int>? invoiceId,
    Expression<String>? itemName,
    Expression<double>? quantity,
    Expression<double>? rate,
    Expression<double>? total,
    Expression<double>? discountAmount,
    Expression<int>? serialNo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (itemName != null) 'item_name': itemName,
      if (quantity != null) 'quantity': quantity,
      if (rate != null) 'rate': rate,
      if (total != null) 'total': total,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (serialNo != null) 'serial_no': serialNo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InvoiceItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? invoiceId,
      Value<String>? itemName,
      Value<double>? quantity,
      Value<double>? rate,
      Value<double>? total,
      Value<double>? discountAmount,
      Value<int>? serialNo,
      Value<DateTime>? createdAt}) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      total: total ?? this.total,
      discountAmount: discountAmount ?? this.discountAmount,
      serialNo: serialNo ?? this.serialNo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<int>(invoiceId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (serialNo.present) {
      map['serial_no'] = Variable<int>(serialNo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('rate: $rate, ')
          ..write('total: $total, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('serialNo: $serialNo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $InventoryItemsTable extends InventoryItems
    with TableInfo<$InventoryItemsTable, InventoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _uomMeta = const VerificationMeta('uom');
  @override
  late final GeneratedColumn<String> uom = GeneratedColumn<String>(
      'uom', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pcs'));
  static const VerificationMeta _unitValueMeta =
      const VerificationMeta('unitValue');
  @override
  late final GeneratedColumn<double> unitValue = GeneratedColumn<double>(
      'unit_value', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumnWithTypeConverter<InventoryItemStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: Constant(InventoryItemStatus.available.index))
          .withConverter<InventoryItemStatus>(
              $InventoryItemsTable.$converterstatus);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        code,
        barcode,
        name,
        category,
        brand,
        price,
        uom,
        unitValue,
        imagePath,
        status,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_items';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('uom')) {
      context.handle(
          _uomMeta, uom.isAcceptableOrUnknown(data['uom']!, _uomMeta));
    }
    if (data.containsKey('unit_value')) {
      context.handle(_unitValueMeta,
          unitValue.isAcceptableOrUnknown(data['unit_value']!, _unitValueMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    context.handle(_statusMeta, const VerificationResult.success());
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      uom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uom'])!,
      unitValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_value'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      status: $InventoryItemsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InventoryItemsTable createAlias(String alias) {
    return $InventoryItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<InventoryItemStatus, int, int> $converterstatus =
      const EnumIndexConverter<InventoryItemStatus>(InventoryItemStatus.values);
}

class InventoryItem extends DataClass implements Insertable<InventoryItem> {
  /// Primary key - auto increment
  final int id;

  /// Unique internal item code (SKU)
  final String code;

  /// Optional scannable barcode value
  final String? barcode;

  /// Display name
  final String name;

  /// Category label
  final String category;

  /// Brand label
  final String brand;

  /// Unit price
  final double price;

  /// Unit of measurement (pcs, kg, l, etc.)
  final String uom;

  /// Quantity represented by one price unit (e.g. 1 kg, 500 g)
  final double unitValue;

  /// Optional local image path
  final String? imagePath;

  /// Availability status
  final InventoryItemStatus status;

  /// Created timestamp
  final DateTime createdAt;
  const InventoryItem(
      {required this.id,
      required this.code,
      this.barcode,
      required this.name,
      required this.category,
      required this.brand,
      required this.price,
      required this.uom,
      required this.unitValue,
      this.imagePath,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['brand'] = Variable<String>(brand);
    map['price'] = Variable<double>(price);
    map['uom'] = Variable<String>(uom);
    map['unit_value'] = Variable<double>(unitValue);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    {
      map['status'] =
          Variable<int>($InventoryItemsTable.$converterstatus.toSql(status));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryItemsCompanion toCompanion(bool nullToAbsent) {
    return InventoryItemsCompanion(
      id: Value(id),
      code: Value(code),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      name: Value(name),
      category: Value(category),
      brand: Value(brand),
      price: Value(price),
      uom: Value(uom),
      unitValue: Value(unitValue),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryItem(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      brand: serializer.fromJson<String>(json['brand']),
      price: serializer.fromJson<double>(json['price']),
      uom: serializer.fromJson<String>(json['uom']),
      unitValue: serializer.fromJson<double>(json['unitValue']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      status: $InventoryItemsTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'barcode': serializer.toJson<String?>(barcode),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'brand': serializer.toJson<String>(brand),
      'price': serializer.toJson<double>(price),
      'uom': serializer.toJson<String>(uom),
      'unitValue': serializer.toJson<double>(unitValue),
      'imagePath': serializer.toJson<String?>(imagePath),
      'status': serializer
          .toJson<int>($InventoryItemsTable.$converterstatus.toJson(status)),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryItem copyWith(
          {int? id,
          String? code,
          Value<String?> barcode = const Value.absent(),
          String? name,
          String? category,
          String? brand,
          double? price,
          String? uom,
          double? unitValue,
          Value<String?> imagePath = const Value.absent(),
          InventoryItemStatus? status,
          DateTime? createdAt}) =>
      InventoryItem(
        id: id ?? this.id,
        code: code ?? this.code,
        barcode: barcode.present ? barcode.value : this.barcode,
        name: name ?? this.name,
        category: category ?? this.category,
        brand: brand ?? this.brand,
        price: price ?? this.price,
        uom: uom ?? this.uom,
        unitValue: unitValue ?? this.unitValue,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  InventoryItem copyWithCompanion(InventoryItemsCompanion data) {
    return InventoryItem(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      brand: data.brand.present ? data.brand.value : this.brand,
      price: data.price.present ? data.price.value : this.price,
      uom: data.uom.present ? data.uom.value : this.uom,
      unitValue: data.unitValue.present ? data.unitValue.value : this.unitValue,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItem(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('brand: $brand, ')
          ..write('price: $price, ')
          ..write('uom: $uom, ')
          ..write('unitValue: $unitValue, ')
          ..write('imagePath: $imagePath, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, barcode, name, category, brand,
      price, uom, unitValue, imagePath, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryItem &&
          other.id == this.id &&
          other.code == this.code &&
          other.barcode == this.barcode &&
          other.name == this.name &&
          other.category == this.category &&
          other.brand == this.brand &&
          other.price == this.price &&
          other.uom == this.uom &&
          other.unitValue == this.unitValue &&
          other.imagePath == this.imagePath &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class InventoryItemsCompanion extends UpdateCompanion<InventoryItem> {
  final Value<int> id;
  final Value<String> code;
  final Value<String?> barcode;
  final Value<String> name;
  final Value<String> category;
  final Value<String> brand;
  final Value<double> price;
  final Value<String> uom;
  final Value<double> unitValue;
  final Value<String?> imagePath;
  final Value<InventoryItemStatus> status;
  final Value<DateTime> createdAt;
  const InventoryItemsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.barcode = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.brand = const Value.absent(),
    this.price = const Value.absent(),
    this.uom = const Value.absent(),
    this.unitValue = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InventoryItemsCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    this.barcode = const Value.absent(),
    required String name,
    required String category,
    required String brand,
    required double price,
    this.uom = const Value.absent(),
    this.unitValue = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : code = Value(code),
        name = Value(name),
        category = Value(category),
        brand = Value(brand),
        price = Value(price);
  static Insertable<InventoryItem> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? barcode,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? brand,
    Expression<double>? price,
    Expression<String>? uom,
    Expression<double>? unitValue,
    Expression<String>? imagePath,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (barcode != null) 'barcode': barcode,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (price != null) 'price': price,
      if (uom != null) 'uom': uom,
      if (unitValue != null) 'unit_value': unitValue,
      if (imagePath != null) 'image_path': imagePath,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InventoryItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? code,
      Value<String?>? barcode,
      Value<String>? name,
      Value<String>? category,
      Value<String>? brand,
      Value<double>? price,
      Value<String>? uom,
      Value<double>? unitValue,
      Value<String?>? imagePath,
      Value<InventoryItemStatus>? status,
      Value<DateTime>? createdAt}) {
    return InventoryItemsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      uom: uom ?? this.uom,
      unitValue: unitValue ?? this.unitValue,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (uom.present) {
      map['uom'] = Variable<String>(uom.value);
    }
    if (unitValue.present) {
      map['unit_value'] = Variable<double>(unitValue.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
          $InventoryItemsTable.$converterstatus.toSql(status.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('brand: $brand, ')
          ..write('price: $price, ')
          ..write('uom: $uom, ')
          ..write('unitValue: $unitValue, ')
          ..write('imagePath: $imagePath, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DocumentSeriesNumbersTable extends DocumentSeriesNumbers
    with TableInfo<$DocumentSeriesNumbersTable, DocumentSeriesNumber> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentSeriesNumbersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _moduleMeta = const VerificationMeta('module');
  @override
  late final GeneratedColumn<String> module = GeneratedColumn<String>(
      'module', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _startingNumberMeta =
      const VerificationMeta('startingNumber');
  @override
  late final GeneratedColumn<int> startingNumber = GeneratedColumn<int>(
      'starting_number', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1001));
  static const VerificationMeta _currentNumberMeta =
      const VerificationMeta('currentNumber');
  @override
  late final GeneratedColumn<int> currentNumber = GeneratedColumn<int>(
      'current_number', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1001));
  static const VerificationMeta _prefixMeta = const VerificationMeta('prefix');
  @override
  late final GeneratedColumn<String> prefix = GeneratedColumn<String>(
      'prefix', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _suffixMeta = const VerificationMeta('suffix');
  @override
  late final GeneratedColumn<String> suffix = GeneratedColumn<String>(
      'suffix', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _patternMeta =
      const VerificationMeta('pattern');
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
      'pattern', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{prefix}-{current_number}'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        module,
        startingNumber,
        currentNumber,
        prefix,
        suffix,
        pattern,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_series_numbers';
  @override
  VerificationContext validateIntegrity(
      Insertable<DocumentSeriesNumber> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('module')) {
      context.handle(_moduleMeta,
          module.isAcceptableOrUnknown(data['module']!, _moduleMeta));
    } else if (isInserting) {
      context.missing(_moduleMeta);
    }
    if (data.containsKey('starting_number')) {
      context.handle(
          _startingNumberMeta,
          startingNumber.isAcceptableOrUnknown(
              data['starting_number']!, _startingNumberMeta));
    }
    if (data.containsKey('current_number')) {
      context.handle(
          _currentNumberMeta,
          currentNumber.isAcceptableOrUnknown(
              data['current_number']!, _currentNumberMeta));
    }
    if (data.containsKey('prefix')) {
      context.handle(_prefixMeta,
          prefix.isAcceptableOrUnknown(data['prefix']!, _prefixMeta));
    }
    if (data.containsKey('suffix')) {
      context.handle(_suffixMeta,
          suffix.isAcceptableOrUnknown(data['suffix']!, _suffixMeta));
    }
    if (data.containsKey('pattern')) {
      context.handle(_patternMeta,
          pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentSeriesNumber map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentSeriesNumber(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      module: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}module'])!,
      startingNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}starting_number'])!,
      currentNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_number'])!,
      prefix: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prefix']),
      suffix: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}suffix']),
      pattern: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pattern'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DocumentSeriesNumbersTable createAlias(String alias) {
    return $DocumentSeriesNumbersTable(attachedDatabase, alias);
  }
}

class DocumentSeriesNumber extends DataClass
    implements Insertable<DocumentSeriesNumber> {
  final int id;

  /// Module key, e.g. 'item', 'invoice'
  final String module;

  /// First number of the series
  final int startingNumber;

  /// Current number to be used for formatting
  final int currentNumber;

  /// Optional prefix in the formatted code
  final String? prefix;

  /// Optional suffix in the formatted code
  final String? suffix;

  /// Supported tokens: {prefix}, {current_number}, {suffix}
  final String pattern;

  /// 1: Active, 0: Inactive
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DocumentSeriesNumber(
      {required this.id,
      required this.module,
      required this.startingNumber,
      required this.currentNumber,
      this.prefix,
      this.suffix,
      required this.pattern,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['module'] = Variable<String>(module);
    map['starting_number'] = Variable<int>(startingNumber);
    map['current_number'] = Variable<int>(currentNumber);
    if (!nullToAbsent || prefix != null) {
      map['prefix'] = Variable<String>(prefix);
    }
    if (!nullToAbsent || suffix != null) {
      map['suffix'] = Variable<String>(suffix);
    }
    map['pattern'] = Variable<String>(pattern);
    map['status'] = Variable<int>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DocumentSeriesNumbersCompanion toCompanion(bool nullToAbsent) {
    return DocumentSeriesNumbersCompanion(
      id: Value(id),
      module: Value(module),
      startingNumber: Value(startingNumber),
      currentNumber: Value(currentNumber),
      prefix:
          prefix == null && nullToAbsent ? const Value.absent() : Value(prefix),
      suffix:
          suffix == null && nullToAbsent ? const Value.absent() : Value(suffix),
      pattern: Value(pattern),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DocumentSeriesNumber.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentSeriesNumber(
      id: serializer.fromJson<int>(json['id']),
      module: serializer.fromJson<String>(json['module']),
      startingNumber: serializer.fromJson<int>(json['startingNumber']),
      currentNumber: serializer.fromJson<int>(json['currentNumber']),
      prefix: serializer.fromJson<String?>(json['prefix']),
      suffix: serializer.fromJson<String?>(json['suffix']),
      pattern: serializer.fromJson<String>(json['pattern']),
      status: serializer.fromJson<int>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'module': serializer.toJson<String>(module),
      'startingNumber': serializer.toJson<int>(startingNumber),
      'currentNumber': serializer.toJson<int>(currentNumber),
      'prefix': serializer.toJson<String?>(prefix),
      'suffix': serializer.toJson<String?>(suffix),
      'pattern': serializer.toJson<String>(pattern),
      'status': serializer.toJson<int>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DocumentSeriesNumber copyWith(
          {int? id,
          String? module,
          int? startingNumber,
          int? currentNumber,
          Value<String?> prefix = const Value.absent(),
          Value<String?> suffix = const Value.absent(),
          String? pattern,
          int? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DocumentSeriesNumber(
        id: id ?? this.id,
        module: module ?? this.module,
        startingNumber: startingNumber ?? this.startingNumber,
        currentNumber: currentNumber ?? this.currentNumber,
        prefix: prefix.present ? prefix.value : this.prefix,
        suffix: suffix.present ? suffix.value : this.suffix,
        pattern: pattern ?? this.pattern,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DocumentSeriesNumber copyWithCompanion(DocumentSeriesNumbersCompanion data) {
    return DocumentSeriesNumber(
      id: data.id.present ? data.id.value : this.id,
      module: data.module.present ? data.module.value : this.module,
      startingNumber: data.startingNumber.present
          ? data.startingNumber.value
          : this.startingNumber,
      currentNumber: data.currentNumber.present
          ? data.currentNumber.value
          : this.currentNumber,
      prefix: data.prefix.present ? data.prefix.value : this.prefix,
      suffix: data.suffix.present ? data.suffix.value : this.suffix,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentSeriesNumber(')
          ..write('id: $id, ')
          ..write('module: $module, ')
          ..write('startingNumber: $startingNumber, ')
          ..write('currentNumber: $currentNumber, ')
          ..write('prefix: $prefix, ')
          ..write('suffix: $suffix, ')
          ..write('pattern: $pattern, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, module, startingNumber, currentNumber,
      prefix, suffix, pattern, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentSeriesNumber &&
          other.id == this.id &&
          other.module == this.module &&
          other.startingNumber == this.startingNumber &&
          other.currentNumber == this.currentNumber &&
          other.prefix == this.prefix &&
          other.suffix == this.suffix &&
          other.pattern == this.pattern &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DocumentSeriesNumbersCompanion
    extends UpdateCompanion<DocumentSeriesNumber> {
  final Value<int> id;
  final Value<String> module;
  final Value<int> startingNumber;
  final Value<int> currentNumber;
  final Value<String?> prefix;
  final Value<String?> suffix;
  final Value<String> pattern;
  final Value<int> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DocumentSeriesNumbersCompanion({
    this.id = const Value.absent(),
    this.module = const Value.absent(),
    this.startingNumber = const Value.absent(),
    this.currentNumber = const Value.absent(),
    this.prefix = const Value.absent(),
    this.suffix = const Value.absent(),
    this.pattern = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DocumentSeriesNumbersCompanion.insert({
    this.id = const Value.absent(),
    required String module,
    this.startingNumber = const Value.absent(),
    this.currentNumber = const Value.absent(),
    this.prefix = const Value.absent(),
    this.suffix = const Value.absent(),
    this.pattern = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : module = Value(module);
  static Insertable<DocumentSeriesNumber> custom({
    Expression<int>? id,
    Expression<String>? module,
    Expression<int>? startingNumber,
    Expression<int>? currentNumber,
    Expression<String>? prefix,
    Expression<String>? suffix,
    Expression<String>? pattern,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (module != null) 'module': module,
      if (startingNumber != null) 'starting_number': startingNumber,
      if (currentNumber != null) 'current_number': currentNumber,
      if (prefix != null) 'prefix': prefix,
      if (suffix != null) 'suffix': suffix,
      if (pattern != null) 'pattern': pattern,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DocumentSeriesNumbersCompanion copyWith(
      {Value<int>? id,
      Value<String>? module,
      Value<int>? startingNumber,
      Value<int>? currentNumber,
      Value<String?>? prefix,
      Value<String?>? suffix,
      Value<String>? pattern,
      Value<int>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return DocumentSeriesNumbersCompanion(
      id: id ?? this.id,
      module: module ?? this.module,
      startingNumber: startingNumber ?? this.startingNumber,
      currentNumber: currentNumber ?? this.currentNumber,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      pattern: pattern ?? this.pattern,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (module.present) {
      map['module'] = Variable<String>(module.value);
    }
    if (startingNumber.present) {
      map['starting_number'] = Variable<int>(startingNumber.value);
    }
    if (currentNumber.present) {
      map['current_number'] = Variable<int>(currentNumber.value);
    }
    if (prefix.present) {
      map['prefix'] = Variable<String>(prefix.value);
    }
    if (suffix.present) {
      map['suffix'] = Variable<String>(suffix.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentSeriesNumbersCompanion(')
          ..write('id: $id, ')
          ..write('module: $module, ')
          ..write('startingNumber: $startingNumber, ')
          ..write('currentNumber: $currentNumber, ')
          ..write('prefix: $prefix, ')
          ..write('suffix: $suffix, ')
          ..write('pattern: $pattern, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $InventoryItemsTable inventoryItems = $InventoryItemsTable(this);
  late final $DocumentSeriesNumbersTable documentSeriesNumbers =
      $DocumentSeriesNumbersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [invoices, invoiceItems, inventoryItems, documentSeriesNumbers];
}

typedef $$InvoicesTableCreateCompanionBuilder = InvoicesCompanion Function({
  Value<int> id,
  required String invoiceNo,
  Value<double> subtotalAmount,
  Value<double> discountAmount,
  Value<double> totalAmount,
  required PaymentMode paymentMode,
  required PaymentStatus paymentStatus,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$InvoicesTableUpdateCompanionBuilder = InvoicesCompanion Function({
  Value<int> id,
  Value<String> invoiceNo,
  Value<double> subtotalAmount,
  Value<double> discountAmount,
  Value<double> totalAmount,
  Value<PaymentMode> paymentMode,
  Value<PaymentStatus> paymentStatus,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$InvoicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder> {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$InvoicesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$InvoicesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> invoiceNo = const Value.absent(),
            Value<double> subtotalAmount = const Value.absent(),
            Value<double> discountAmount = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<PaymentMode> paymentMode = const Value.absent(),
            Value<PaymentStatus> paymentStatus = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              InvoicesCompanion(
            id: id,
            invoiceNo: invoiceNo,
            subtotalAmount: subtotalAmount,
            discountAmount: discountAmount,
            totalAmount: totalAmount,
            paymentMode: paymentMode,
            paymentStatus: paymentStatus,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String invoiceNo,
            Value<double> subtotalAmount = const Value.absent(),
            Value<double> discountAmount = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            required PaymentMode paymentMode,
            required PaymentStatus paymentStatus,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              InvoicesCompanion.insert(
            id: id,
            invoiceNo: invoiceNo,
            subtotalAmount: subtotalAmount,
            discountAmount: discountAmount,
            totalAmount: totalAmount,
            paymentMode: paymentMode,
            paymentStatus: paymentStatus,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        ));
}

class $$InvoicesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get invoiceNo => $state.composableBuilder(
      column: $state.table.invoiceNo,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get subtotalAmount => $state.composableBuilder(
      column: $state.table.subtotalAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get discountAmount => $state.composableBuilder(
      column: $state.table.discountAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalAmount => $state.composableBuilder(
      column: $state.table.totalAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<PaymentMode, PaymentMode, int>
      get paymentMode => $state.composableBuilder(
          column: $state.table.paymentMode,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<PaymentStatus, PaymentStatus, int>
      get paymentStatus => $state.composableBuilder(
          column: $state.table.paymentStatus,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter invoiceItemsRefs(
      ComposableFilter Function($$InvoiceItemsTableFilterComposer f) f) {
    final $$InvoiceItemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.invoiceItems,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder, parentComposers) =>
            $$InvoiceItemsTableFilterComposer(ComposerState($state.db,
                $state.db.invoiceItems, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$InvoicesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get invoiceNo => $state.composableBuilder(
      column: $state.table.invoiceNo,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get subtotalAmount => $state.composableBuilder(
      column: $state.table.subtotalAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get discountAmount => $state.composableBuilder(
      column: $state.table.discountAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalAmount => $state.composableBuilder(
      column: $state.table.totalAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get paymentMode => $state.composableBuilder(
      column: $state.table.paymentMode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get paymentStatus => $state.composableBuilder(
      column: $state.table.paymentStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$InvoiceItemsTableCreateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<int> id,
  required int invoiceId,
  required String itemName,
  required double quantity,
  required double rate,
  required double total,
  Value<double> discountAmount,
  Value<int> serialNo,
  Value<DateTime> createdAt,
});
typedef $$InvoiceItemsTableUpdateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<int> id,
  Value<int> invoiceId,
  Value<String> itemName,
  Value<double> quantity,
  Value<double> rate,
  Value<double> total,
  Value<double> discountAmount,
  Value<int> serialNo,
  Value<DateTime> createdAt,
});

class $$InvoiceItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder> {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$InvoiceItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$InvoiceItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> invoiceId = const Value.absent(),
            Value<String> itemName = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double> rate = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<double> discountAmount = const Value.absent(),
            Value<int> serialNo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InvoiceItemsCompanion(
            id: id,
            invoiceId: invoiceId,
            itemName: itemName,
            quantity: quantity,
            rate: rate,
            total: total,
            discountAmount: discountAmount,
            serialNo: serialNo,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int invoiceId,
            required String itemName,
            required double quantity,
            required double rate,
            required double total,
            Value<double> discountAmount = const Value.absent(),
            Value<int> serialNo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InvoiceItemsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            itemName: itemName,
            quantity: quantity,
            rate: rate,
            total: total,
            discountAmount: discountAmount,
            serialNo: serialNo,
            createdAt: createdAt,
          ),
        ));
}

class $$InvoiceItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get itemName => $state.composableBuilder(
      column: $state.table.itemName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get rate => $state.composableBuilder(
      column: $state.table.rate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get total => $state.composableBuilder(
      column: $state.table.total,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get discountAmount => $state.composableBuilder(
      column: $state.table.discountAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get serialNo => $state.composableBuilder(
      column: $state.table.serialNo,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $state.db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$InvoicesTableFilterComposer(ComposerState(
                $state.db, $state.db.invoices, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$InvoiceItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get itemName => $state.composableBuilder(
      column: $state.table.itemName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get rate => $state.composableBuilder(
      column: $state.table.rate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get total => $state.composableBuilder(
      column: $state.table.total,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get discountAmount => $state.composableBuilder(
      column: $state.table.discountAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get serialNo => $state.composableBuilder(
      column: $state.table.serialNo,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $state.db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$InvoicesTableOrderingComposer(ComposerState(
                $state.db, $state.db.invoices, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$InventoryItemsTableCreateCompanionBuilder = InventoryItemsCompanion
    Function({
  Value<int> id,
  required String code,
  Value<String?> barcode,
  required String name,
  required String category,
  required String brand,
  required double price,
  Value<String> uom,
  Value<double> unitValue,
  Value<String?> imagePath,
  Value<InventoryItemStatus> status,
  Value<DateTime> createdAt,
});
typedef $$InventoryItemsTableUpdateCompanionBuilder = InventoryItemsCompanion
    Function({
  Value<int> id,
  Value<String> code,
  Value<String?> barcode,
  Value<String> name,
  Value<String> category,
  Value<String> brand,
  Value<double> price,
  Value<String> uom,
  Value<double> unitValue,
  Value<String?> imagePath,
  Value<InventoryItemStatus> status,
  Value<DateTime> createdAt,
});

class $$InventoryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryItemsTable,
    InventoryItem,
    $$InventoryItemsTableFilterComposer,
    $$InventoryItemsTableOrderingComposer,
    $$InventoryItemsTableCreateCompanionBuilder,
    $$InventoryItemsTableUpdateCompanionBuilder> {
  $$InventoryItemsTableTableManager(
      _$AppDatabase db, $InventoryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$InventoryItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$InventoryItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> brand = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<String> uom = const Value.absent(),
            Value<double> unitValue = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<InventoryItemStatus> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InventoryItemsCompanion(
            id: id,
            code: code,
            barcode: barcode,
            name: name,
            category: category,
            brand: brand,
            price: price,
            uom: uom,
            unitValue: unitValue,
            imagePath: imagePath,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String code,
            Value<String?> barcode = const Value.absent(),
            required String name,
            required String category,
            required String brand,
            required double price,
            Value<String> uom = const Value.absent(),
            Value<double> unitValue = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<InventoryItemStatus> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InventoryItemsCompanion.insert(
            id: id,
            code: code,
            barcode: barcode,
            name: name,
            category: category,
            brand: brand,
            price: price,
            uom: uom,
            unitValue: unitValue,
            imagePath: imagePath,
            status: status,
            createdAt: createdAt,
          ),
        ));
}

class $$InventoryItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get code => $state.composableBuilder(
      column: $state.table.code,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get brand => $state.composableBuilder(
      column: $state.table.brand,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get price => $state.composableBuilder(
      column: $state.table.price,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get uom => $state.composableBuilder(
      column: $state.table.uom,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get unitValue => $state.composableBuilder(
      column: $state.table.unitValue,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<InventoryItemStatus, InventoryItemStatus, int>
      get status => $state.composableBuilder(
          column: $state.table.status,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$InventoryItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get code => $state.composableBuilder(
      column: $state.table.code,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get brand => $state.composableBuilder(
      column: $state.table.brand,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get price => $state.composableBuilder(
      column: $state.table.price,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get uom => $state.composableBuilder(
      column: $state.table.uom,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get unitValue => $state.composableBuilder(
      column: $state.table.unitValue,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DocumentSeriesNumbersTableCreateCompanionBuilder
    = DocumentSeriesNumbersCompanion Function({
  Value<int> id,
  required String module,
  Value<int> startingNumber,
  Value<int> currentNumber,
  Value<String?> prefix,
  Value<String?> suffix,
  Value<String> pattern,
  Value<int> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$DocumentSeriesNumbersTableUpdateCompanionBuilder
    = DocumentSeriesNumbersCompanion Function({
  Value<int> id,
  Value<String> module,
  Value<int> startingNumber,
  Value<int> currentNumber,
  Value<String?> prefix,
  Value<String?> suffix,
  Value<String> pattern,
  Value<int> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$DocumentSeriesNumbersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DocumentSeriesNumbersTable,
    DocumentSeriesNumber,
    $$DocumentSeriesNumbersTableFilterComposer,
    $$DocumentSeriesNumbersTableOrderingComposer,
    $$DocumentSeriesNumbersTableCreateCompanionBuilder,
    $$DocumentSeriesNumbersTableUpdateCompanionBuilder> {
  $$DocumentSeriesNumbersTableTableManager(
      _$AppDatabase db, $DocumentSeriesNumbersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$DocumentSeriesNumbersTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$DocumentSeriesNumbersTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> module = const Value.absent(),
            Value<int> startingNumber = const Value.absent(),
            Value<int> currentNumber = const Value.absent(),
            Value<String?> prefix = const Value.absent(),
            Value<String?> suffix = const Value.absent(),
            Value<String> pattern = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DocumentSeriesNumbersCompanion(
            id: id,
            module: module,
            startingNumber: startingNumber,
            currentNumber: currentNumber,
            prefix: prefix,
            suffix: suffix,
            pattern: pattern,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String module,
            Value<int> startingNumber = const Value.absent(),
            Value<int> currentNumber = const Value.absent(),
            Value<String?> prefix = const Value.absent(),
            Value<String?> suffix = const Value.absent(),
            Value<String> pattern = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DocumentSeriesNumbersCompanion.insert(
            id: id,
            module: module,
            startingNumber: startingNumber,
            currentNumber: currentNumber,
            prefix: prefix,
            suffix: suffix,
            pattern: pattern,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        ));
}

class $$DocumentSeriesNumbersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DocumentSeriesNumbersTable> {
  $$DocumentSeriesNumbersTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get module => $state.composableBuilder(
      column: $state.table.module,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get startingNumber => $state.composableBuilder(
      column: $state.table.startingNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get currentNumber => $state.composableBuilder(
      column: $state.table.currentNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get prefix => $state.composableBuilder(
      column: $state.table.prefix,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get suffix => $state.composableBuilder(
      column: $state.table.suffix,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get pattern => $state.composableBuilder(
      column: $state.table.pattern,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DocumentSeriesNumbersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DocumentSeriesNumbersTable> {
  $$DocumentSeriesNumbersTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get module => $state.composableBuilder(
      column: $state.table.module,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get startingNumber => $state.composableBuilder(
      column: $state.table.startingNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get currentNumber => $state.composableBuilder(
      column: $state.table.currentNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get prefix => $state.composableBuilder(
      column: $state.table.prefix,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get suffix => $state.composableBuilder(
      column: $state.table.suffix,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get pattern => $state.composableBuilder(
      column: $state.table.pattern,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$InventoryItemsTableTableManager get inventoryItems =>
      $$InventoryItemsTableTableManager(_db, _db.inventoryItems);
  $$DocumentSeriesNumbersTableTableManager get documentSeriesNumbers =>
      $$DocumentSeriesNumbersTableTableManager(_db, _db.documentSeriesNumbers);
}
