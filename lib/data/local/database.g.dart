// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CouponRowsTable extends CouponRows
    with TableInfo<$CouponRowsTable, CouponRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CouponRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CouponKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CouponKind>($CouponRowsTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<CouponStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CouponStatus>($CouponRowsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<CouponCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CouponCategory>($CouponRowsTable.$convertercategory);
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BarcodeFormat, String>
  barcodeFormat = GeneratedColumn<String>(
    'barcode_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<BarcodeFormat>($CouponRowsTable.$converterbarcodeFormat);
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _faceValueMeta = const VerificationMeta(
    'faceValue',
  );
  @override
  late final GeneratedColumn<int> faceValue = GeneratedColumn<int>(
    'face_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issuerMeta = const VerificationMeta('issuer');
  @override
  late final GeneratedColumn<String> issuer = GeneratedColumn<String>(
    'issuer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _giftedToMeta = const VerificationMeta(
    'giftedTo',
  );
  @override
  late final GeneratedColumn<String> giftedTo = GeneratedColumn<String>(
    'gifted_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _giftedAtMeta = const VerificationMeta(
    'giftedAt',
  );
  @override
  late final GeneratedColumn<DateTime> giftedAt = GeneratedColumn<DateTime>(
    'gifted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    brand,
    productName,
    kind,
    status,
    category,
    barcode,
    barcodeFormat,
    imagePath,
    expiresAt,
    faceValue,
    balance,
    memo,
    issuer,
    giftedTo,
    giftedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coupon_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CouponRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('face_value')) {
      context.handle(
        _faceValueMeta,
        faceValue.isAcceptableOrUnknown(data['face_value']!, _faceValueMeta),
      );
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('issuer')) {
      context.handle(
        _issuerMeta,
        issuer.isAcceptableOrUnknown(data['issuer']!, _issuerMeta),
      );
    }
    if (data.containsKey('gifted_to')) {
      context.handle(
        _giftedToMeta,
        giftedTo.isAcceptableOrUnknown(data['gifted_to']!, _giftedToMeta),
      );
    }
    if (data.containsKey('gifted_at')) {
      context.handle(
        _giftedAtMeta,
        giftedAt.isAcceptableOrUnknown(data['gifted_at']!, _giftedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CouponRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CouponRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      kind: $CouponRowsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      status: $CouponRowsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      category: $CouponRowsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      barcodeFormat: $CouponRowsTable.$converterbarcodeFormat.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}barcode_format'],
        )!,
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      faceValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}face_value'],
      ),
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      issuer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issuer'],
      ),
      giftedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gifted_to'],
      ),
      giftedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}gifted_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CouponRowsTable createAlias(String alias) {
    return $CouponRowsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CouponKind, String, String> $converterkind =
      const EnumNameConverter<CouponKind>(CouponKind.values);
  static JsonTypeConverter2<CouponStatus, String, String> $converterstatus =
      const EnumNameConverter<CouponStatus>(CouponStatus.values);
  static JsonTypeConverter2<CouponCategory, String, String> $convertercategory =
      const EnumNameConverter<CouponCategory>(CouponCategory.values);
  static JsonTypeConverter2<BarcodeFormat, String, String>
  $converterbarcodeFormat = const EnumNameConverter<BarcodeFormat>(
    BarcodeFormat.values,
  );
}

class CouponRow extends DataClass implements Insertable<CouponRow> {
  final String id;
  final String brand;
  final String productName;
  final CouponKind kind;
  final CouponStatus status;
  final CouponCategory category;
  final String? barcode;
  final BarcodeFormat barcodeFormat;
  final String? imagePath;
  final DateTime? expiresAt;
  final int? faceValue;
  final int? balance;
  final String? memo;
  final String? issuer;
  final String? giftedTo;
  final DateTime? giftedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CouponRow({
    required this.id,
    required this.brand,
    required this.productName,
    required this.kind,
    required this.status,
    required this.category,
    this.barcode,
    required this.barcodeFormat,
    this.imagePath,
    this.expiresAt,
    this.faceValue,
    this.balance,
    this.memo,
    this.issuer,
    this.giftedTo,
    this.giftedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['brand'] = Variable<String>(brand);
    map['product_name'] = Variable<String>(productName);
    {
      map['kind'] = Variable<String>(
        $CouponRowsTable.$converterkind.toSql(kind),
      );
    }
    {
      map['status'] = Variable<String>(
        $CouponRowsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['category'] = Variable<String>(
        $CouponRowsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    {
      map['barcode_format'] = Variable<String>(
        $CouponRowsTable.$converterbarcodeFormat.toSql(barcodeFormat),
      );
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    if (!nullToAbsent || faceValue != null) {
      map['face_value'] = Variable<int>(faceValue);
    }
    if (!nullToAbsent || balance != null) {
      map['balance'] = Variable<int>(balance);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || issuer != null) {
      map['issuer'] = Variable<String>(issuer);
    }
    if (!nullToAbsent || giftedTo != null) {
      map['gifted_to'] = Variable<String>(giftedTo);
    }
    if (!nullToAbsent || giftedAt != null) {
      map['gifted_at'] = Variable<DateTime>(giftedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CouponRowsCompanion toCompanion(bool nullToAbsent) {
    return CouponRowsCompanion(
      id: Value(id),
      brand: Value(brand),
      productName: Value(productName),
      kind: Value(kind),
      status: Value(status),
      category: Value(category),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      barcodeFormat: Value(barcodeFormat),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      faceValue: faceValue == null && nullToAbsent
          ? const Value.absent()
          : Value(faceValue),
      balance: balance == null && nullToAbsent
          ? const Value.absent()
          : Value(balance),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      issuer: issuer == null && nullToAbsent
          ? const Value.absent()
          : Value(issuer),
      giftedTo: giftedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(giftedTo),
      giftedAt: giftedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(giftedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CouponRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CouponRow(
      id: serializer.fromJson<String>(json['id']),
      brand: serializer.fromJson<String>(json['brand']),
      productName: serializer.fromJson<String>(json['productName']),
      kind: $CouponRowsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      status: $CouponRowsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      category: $CouponRowsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      barcode: serializer.fromJson<String?>(json['barcode']),
      barcodeFormat: $CouponRowsTable.$converterbarcodeFormat.fromJson(
        serializer.fromJson<String>(json['barcodeFormat']),
      ),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      faceValue: serializer.fromJson<int?>(json['faceValue']),
      balance: serializer.fromJson<int?>(json['balance']),
      memo: serializer.fromJson<String?>(json['memo']),
      issuer: serializer.fromJson<String?>(json['issuer']),
      giftedTo: serializer.fromJson<String?>(json['giftedTo']),
      giftedAt: serializer.fromJson<DateTime?>(json['giftedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'brand': serializer.toJson<String>(brand),
      'productName': serializer.toJson<String>(productName),
      'kind': serializer.toJson<String>(
        $CouponRowsTable.$converterkind.toJson(kind),
      ),
      'status': serializer.toJson<String>(
        $CouponRowsTable.$converterstatus.toJson(status),
      ),
      'category': serializer.toJson<String>(
        $CouponRowsTable.$convertercategory.toJson(category),
      ),
      'barcode': serializer.toJson<String?>(barcode),
      'barcodeFormat': serializer.toJson<String>(
        $CouponRowsTable.$converterbarcodeFormat.toJson(barcodeFormat),
      ),
      'imagePath': serializer.toJson<String?>(imagePath),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'faceValue': serializer.toJson<int?>(faceValue),
      'balance': serializer.toJson<int?>(balance),
      'memo': serializer.toJson<String?>(memo),
      'issuer': serializer.toJson<String?>(issuer),
      'giftedTo': serializer.toJson<String?>(giftedTo),
      'giftedAt': serializer.toJson<DateTime?>(giftedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CouponRow copyWith({
    String? id,
    String? brand,
    String? productName,
    CouponKind? kind,
    CouponStatus? status,
    CouponCategory? category,
    Value<String?> barcode = const Value.absent(),
    BarcodeFormat? barcodeFormat,
    Value<String?> imagePath = const Value.absent(),
    Value<DateTime?> expiresAt = const Value.absent(),
    Value<int?> faceValue = const Value.absent(),
    Value<int?> balance = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    Value<String?> issuer = const Value.absent(),
    Value<String?> giftedTo = const Value.absent(),
    Value<DateTime?> giftedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CouponRow(
    id: id ?? this.id,
    brand: brand ?? this.brand,
    productName: productName ?? this.productName,
    kind: kind ?? this.kind,
    status: status ?? this.status,
    category: category ?? this.category,
    barcode: barcode.present ? barcode.value : this.barcode,
    barcodeFormat: barcodeFormat ?? this.barcodeFormat,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    faceValue: faceValue.present ? faceValue.value : this.faceValue,
    balance: balance.present ? balance.value : this.balance,
    memo: memo.present ? memo.value : this.memo,
    issuer: issuer.present ? issuer.value : this.issuer,
    giftedTo: giftedTo.present ? giftedTo.value : this.giftedTo,
    giftedAt: giftedAt.present ? giftedAt.value : this.giftedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CouponRow copyWithCompanion(CouponRowsCompanion data) {
    return CouponRow(
      id: data.id.present ? data.id.value : this.id,
      brand: data.brand.present ? data.brand.value : this.brand,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      category: data.category.present ? data.category.value : this.category,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      barcodeFormat: data.barcodeFormat.present
          ? data.barcodeFormat.value
          : this.barcodeFormat,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      faceValue: data.faceValue.present ? data.faceValue.value : this.faceValue,
      balance: data.balance.present ? data.balance.value : this.balance,
      memo: data.memo.present ? data.memo.value : this.memo,
      issuer: data.issuer.present ? data.issuer.value : this.issuer,
      giftedTo: data.giftedTo.present ? data.giftedTo.value : this.giftedTo,
      giftedAt: data.giftedAt.present ? data.giftedAt.value : this.giftedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CouponRow(')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('productName: $productName, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('barcode: $barcode, ')
          ..write('barcodeFormat: $barcodeFormat, ')
          ..write('imagePath: $imagePath, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('faceValue: $faceValue, ')
          ..write('balance: $balance, ')
          ..write('memo: $memo, ')
          ..write('issuer: $issuer, ')
          ..write('giftedTo: $giftedTo, ')
          ..write('giftedAt: $giftedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    brand,
    productName,
    kind,
    status,
    category,
    barcode,
    barcodeFormat,
    imagePath,
    expiresAt,
    faceValue,
    balance,
    memo,
    issuer,
    giftedTo,
    giftedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CouponRow &&
          other.id == this.id &&
          other.brand == this.brand &&
          other.productName == this.productName &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.category == this.category &&
          other.barcode == this.barcode &&
          other.barcodeFormat == this.barcodeFormat &&
          other.imagePath == this.imagePath &&
          other.expiresAt == this.expiresAt &&
          other.faceValue == this.faceValue &&
          other.balance == this.balance &&
          other.memo == this.memo &&
          other.issuer == this.issuer &&
          other.giftedTo == this.giftedTo &&
          other.giftedAt == this.giftedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CouponRowsCompanion extends UpdateCompanion<CouponRow> {
  final Value<String> id;
  final Value<String> brand;
  final Value<String> productName;
  final Value<CouponKind> kind;
  final Value<CouponStatus> status;
  final Value<CouponCategory> category;
  final Value<String?> barcode;
  final Value<BarcodeFormat> barcodeFormat;
  final Value<String?> imagePath;
  final Value<DateTime?> expiresAt;
  final Value<int?> faceValue;
  final Value<int?> balance;
  final Value<String?> memo;
  final Value<String?> issuer;
  final Value<String?> giftedTo;
  final Value<DateTime?> giftedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CouponRowsCompanion({
    this.id = const Value.absent(),
    this.brand = const Value.absent(),
    this.productName = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.category = const Value.absent(),
    this.barcode = const Value.absent(),
    this.barcodeFormat = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.faceValue = const Value.absent(),
    this.balance = const Value.absent(),
    this.memo = const Value.absent(),
    this.issuer = const Value.absent(),
    this.giftedTo = const Value.absent(),
    this.giftedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CouponRowsCompanion.insert({
    required String id,
    required String brand,
    required String productName,
    required CouponKind kind,
    required CouponStatus status,
    required CouponCategory category,
    this.barcode = const Value.absent(),
    required BarcodeFormat barcodeFormat,
    this.imagePath = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.faceValue = const Value.absent(),
    this.balance = const Value.absent(),
    this.memo = const Value.absent(),
    this.issuer = const Value.absent(),
    this.giftedTo = const Value.absent(),
    this.giftedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       brand = Value(brand),
       productName = Value(productName),
       kind = Value(kind),
       status = Value(status),
       category = Value(category),
       barcodeFormat = Value(barcodeFormat),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CouponRow> custom({
    Expression<String>? id,
    Expression<String>? brand,
    Expression<String>? productName,
    Expression<String>? kind,
    Expression<String>? status,
    Expression<String>? category,
    Expression<String>? barcode,
    Expression<String>? barcodeFormat,
    Expression<String>? imagePath,
    Expression<DateTime>? expiresAt,
    Expression<int>? faceValue,
    Expression<int>? balance,
    Expression<String>? memo,
    Expression<String>? issuer,
    Expression<String>? giftedTo,
    Expression<DateTime>? giftedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (brand != null) 'brand': brand,
      if (productName != null) 'product_name': productName,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (category != null) 'category': category,
      if (barcode != null) 'barcode': barcode,
      if (barcodeFormat != null) 'barcode_format': barcodeFormat,
      if (imagePath != null) 'image_path': imagePath,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (faceValue != null) 'face_value': faceValue,
      if (balance != null) 'balance': balance,
      if (memo != null) 'memo': memo,
      if (issuer != null) 'issuer': issuer,
      if (giftedTo != null) 'gifted_to': giftedTo,
      if (giftedAt != null) 'gifted_at': giftedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CouponRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? brand,
    Value<String>? productName,
    Value<CouponKind>? kind,
    Value<CouponStatus>? status,
    Value<CouponCategory>? category,
    Value<String?>? barcode,
    Value<BarcodeFormat>? barcodeFormat,
    Value<String?>? imagePath,
    Value<DateTime?>? expiresAt,
    Value<int?>? faceValue,
    Value<int?>? balance,
    Value<String?>? memo,
    Value<String?>? issuer,
    Value<String?>? giftedTo,
    Value<DateTime?>? giftedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CouponRowsCompanion(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      productName: productName ?? this.productName,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      barcodeFormat: barcodeFormat ?? this.barcodeFormat,
      imagePath: imagePath ?? this.imagePath,
      expiresAt: expiresAt ?? this.expiresAt,
      faceValue: faceValue ?? this.faceValue,
      balance: balance ?? this.balance,
      memo: memo ?? this.memo,
      issuer: issuer ?? this.issuer,
      giftedTo: giftedTo ?? this.giftedTo,
      giftedAt: giftedAt ?? this.giftedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CouponRowsTable.$converterkind.toSql(kind.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $CouponRowsTable.$converterstatus.toSql(status.value),
      );
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $CouponRowsTable.$convertercategory.toSql(category.value),
      );
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (barcodeFormat.present) {
      map['barcode_format'] = Variable<String>(
        $CouponRowsTable.$converterbarcodeFormat.toSql(barcodeFormat.value),
      );
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (faceValue.present) {
      map['face_value'] = Variable<int>(faceValue.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (issuer.present) {
      map['issuer'] = Variable<String>(issuer.value);
    }
    if (giftedTo.present) {
      map['gifted_to'] = Variable<String>(giftedTo.value);
    }
    if (giftedAt.present) {
      map['gifted_at'] = Variable<DateTime>(giftedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CouponRowsCompanion(')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('productName: $productName, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('barcode: $barcode, ')
          ..write('barcodeFormat: $barcodeFormat, ')
          ..write('imagePath: $imagePath, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('faceValue: $faceValue, ')
          ..write('balance: $balance, ')
          ..write('memo: $memo, ')
          ..write('issuer: $issuer, ')
          ..write('giftedTo: $giftedTo, ')
          ..write('giftedAt: $giftedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsageRowsTable extends UsageRows
    with TableInfo<$UsageRowsTable, UsageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsageRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _couponIdMeta = const VerificationMeta(
    'couponId',
  );
  @override
  late final GeneratedColumn<String> couponId = GeneratedColumn<String>(
    'coupon_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES coupon_rows (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usedAtMeta = const VerificationMeta('usedAt');
  @override
  late final GeneratedColumn<DateTime> usedAt = GeneratedColumn<DateTime>(
    'used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
    'place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    couponId,
    amount,
    usedAt,
    place,
    memo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usage_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('coupon_id')) {
      context.handle(
        _couponIdMeta,
        couponId.isAcceptableOrUnknown(data['coupon_id']!, _couponIdMeta),
      );
    } else if (isInserting) {
      context.missing(_couponIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('used_at')) {
      context.handle(
        _usedAtMeta,
        usedAt.isAcceptableOrUnknown(data['used_at']!, _usedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_usedAtMeta);
    }
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      couponId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coupon_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      usedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}used_at'],
      )!,
      place: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
    );
  }

  @override
  $UsageRowsTable createAlias(String alias) {
    return $UsageRowsTable(attachedDatabase, alias);
  }
}

class UsageRow extends DataClass implements Insertable<UsageRow> {
  final String id;
  final String couponId;
  final int amount;
  final DateTime usedAt;
  final String? place;
  final String? memo;
  const UsageRow({
    required this.id,
    required this.couponId,
    required this.amount,
    required this.usedAt,
    this.place,
    this.memo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['coupon_id'] = Variable<String>(couponId);
    map['amount'] = Variable<int>(amount);
    map['used_at'] = Variable<DateTime>(usedAt);
    if (!nullToAbsent || place != null) {
      map['place'] = Variable<String>(place);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    return map;
  }

  UsageRowsCompanion toCompanion(bool nullToAbsent) {
    return UsageRowsCompanion(
      id: Value(id),
      couponId: Value(couponId),
      amount: Value(amount),
      usedAt: Value(usedAt),
      place: place == null && nullToAbsent
          ? const Value.absent()
          : Value(place),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
    );
  }

  factory UsageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsageRow(
      id: serializer.fromJson<String>(json['id']),
      couponId: serializer.fromJson<String>(json['couponId']),
      amount: serializer.fromJson<int>(json['amount']),
      usedAt: serializer.fromJson<DateTime>(json['usedAt']),
      place: serializer.fromJson<String?>(json['place']),
      memo: serializer.fromJson<String?>(json['memo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'couponId': serializer.toJson<String>(couponId),
      'amount': serializer.toJson<int>(amount),
      'usedAt': serializer.toJson<DateTime>(usedAt),
      'place': serializer.toJson<String?>(place),
      'memo': serializer.toJson<String?>(memo),
    };
  }

  UsageRow copyWith({
    String? id,
    String? couponId,
    int? amount,
    DateTime? usedAt,
    Value<String?> place = const Value.absent(),
    Value<String?> memo = const Value.absent(),
  }) => UsageRow(
    id: id ?? this.id,
    couponId: couponId ?? this.couponId,
    amount: amount ?? this.amount,
    usedAt: usedAt ?? this.usedAt,
    place: place.present ? place.value : this.place,
    memo: memo.present ? memo.value : this.memo,
  );
  UsageRow copyWithCompanion(UsageRowsCompanion data) {
    return UsageRow(
      id: data.id.present ? data.id.value : this.id,
      couponId: data.couponId.present ? data.couponId.value : this.couponId,
      amount: data.amount.present ? data.amount.value : this.amount,
      usedAt: data.usedAt.present ? data.usedAt.value : this.usedAt,
      place: data.place.present ? data.place.value : this.place,
      memo: data.memo.present ? data.memo.value : this.memo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsageRow(')
          ..write('id: $id, ')
          ..write('couponId: $couponId, ')
          ..write('amount: $amount, ')
          ..write('usedAt: $usedAt, ')
          ..write('place: $place, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, couponId, amount, usedAt, place, memo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageRow &&
          other.id == this.id &&
          other.couponId == this.couponId &&
          other.amount == this.amount &&
          other.usedAt == this.usedAt &&
          other.place == this.place &&
          other.memo == this.memo);
}

class UsageRowsCompanion extends UpdateCompanion<UsageRow> {
  final Value<String> id;
  final Value<String> couponId;
  final Value<int> amount;
  final Value<DateTime> usedAt;
  final Value<String?> place;
  final Value<String?> memo;
  final Value<int> rowid;
  const UsageRowsCompanion({
    this.id = const Value.absent(),
    this.couponId = const Value.absent(),
    this.amount = const Value.absent(),
    this.usedAt = const Value.absent(),
    this.place = const Value.absent(),
    this.memo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsageRowsCompanion.insert({
    required String id,
    required String couponId,
    required int amount,
    required DateTime usedAt,
    this.place = const Value.absent(),
    this.memo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       couponId = Value(couponId),
       amount = Value(amount),
       usedAt = Value(usedAt);
  static Insertable<UsageRow> custom({
    Expression<String>? id,
    Expression<String>? couponId,
    Expression<int>? amount,
    Expression<DateTime>? usedAt,
    Expression<String>? place,
    Expression<String>? memo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (couponId != null) 'coupon_id': couponId,
      if (amount != null) 'amount': amount,
      if (usedAt != null) 'used_at': usedAt,
      if (place != null) 'place': place,
      if (memo != null) 'memo': memo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsageRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? couponId,
    Value<int>? amount,
    Value<DateTime>? usedAt,
    Value<String?>? place,
    Value<String?>? memo,
    Value<int>? rowid,
  }) {
    return UsageRowsCompanion(
      id: id ?? this.id,
      couponId: couponId ?? this.couponId,
      amount: amount ?? this.amount,
      usedAt: usedAt ?? this.usedAt,
      place: place ?? this.place,
      memo: memo ?? this.memo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (couponId.present) {
      map['coupon_id'] = Variable<String>(couponId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (usedAt.present) {
      map['used_at'] = Variable<DateTime>(usedAt.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsageRowsCompanion(')
          ..write('id: $id, ')
          ..write('couponId: $couponId, ')
          ..write('amount: $amount, ')
          ..write('usedAt: $usedAt, ')
          ..write('place: $place, ')
          ..write('memo: $memo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CouponRowsTable couponRows = $CouponRowsTable(this);
  late final $UsageRowsTable usageRows = $UsageRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [couponRows, usageRows];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'coupon_rows',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('usage_rows', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CouponRowsTableCreateCompanionBuilder =
    CouponRowsCompanion Function({
      required String id,
      required String brand,
      required String productName,
      required CouponKind kind,
      required CouponStatus status,
      required CouponCategory category,
      Value<String?> barcode,
      required BarcodeFormat barcodeFormat,
      Value<String?> imagePath,
      Value<DateTime?> expiresAt,
      Value<int?> faceValue,
      Value<int?> balance,
      Value<String?> memo,
      Value<String?> issuer,
      Value<String?> giftedTo,
      Value<DateTime?> giftedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CouponRowsTableUpdateCompanionBuilder =
    CouponRowsCompanion Function({
      Value<String> id,
      Value<String> brand,
      Value<String> productName,
      Value<CouponKind> kind,
      Value<CouponStatus> status,
      Value<CouponCategory> category,
      Value<String?> barcode,
      Value<BarcodeFormat> barcodeFormat,
      Value<String?> imagePath,
      Value<DateTime?> expiresAt,
      Value<int?> faceValue,
      Value<int?> balance,
      Value<String?> memo,
      Value<String?> issuer,
      Value<String?> giftedTo,
      Value<DateTime?> giftedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CouponRowsTableReferences
    extends BaseReferences<_$AppDatabase, $CouponRowsTable, CouponRow> {
  $$CouponRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UsageRowsTable, List<UsageRow>>
  _usageRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.usageRows,
    aliasName: 'coupon_rows__id__usage_rows__coupon_id',
  );

  $$UsageRowsTableProcessedTableManager get usageRowsRefs {
    final manager = $$UsageRowsTableTableManager(
      $_db,
      $_db.usageRows,
    ).filter((f) => f.couponId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_usageRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CouponRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CouponRowsTable> {
  $$CouponRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CouponKind, CouponKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<CouponStatus, CouponStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CouponCategory, CouponCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BarcodeFormat, BarcodeFormat, String>
  get barcodeFormat => $composableBuilder(
    column: $table.barcodeFormat,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get faceValue => $composableBuilder(
    column: $table.faceValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get giftedTo => $composableBuilder(
    column: $table.giftedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get giftedAt => $composableBuilder(
    column: $table.giftedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> usageRowsRefs(
    Expression<bool> Function($$UsageRowsTableFilterComposer f) f,
  ) {
    final $$UsageRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.usageRows,
      getReferencedColumn: (t) => t.couponId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsageRowsTableFilterComposer(
            $db: $db,
            $table: $db.usageRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CouponRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CouponRowsTable> {
  $$CouponRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcodeFormat => $composableBuilder(
    column: $table.barcodeFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get faceValue => $composableBuilder(
    column: $table.faceValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get giftedTo => $composableBuilder(
    column: $table.giftedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get giftedAt => $composableBuilder(
    column: $table.giftedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CouponRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CouponRowsTable> {
  $$CouponRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CouponKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CouponStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CouponCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BarcodeFormat, String> get barcodeFormat =>
      $composableBuilder(
        column: $table.barcodeFormat,
        builder: (column) => column,
      );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<int> get faceValue =>
      $composableBuilder(column: $table.faceValue, builder: (column) => column);

  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get issuer =>
      $composableBuilder(column: $table.issuer, builder: (column) => column);

  GeneratedColumn<String> get giftedTo =>
      $composableBuilder(column: $table.giftedTo, builder: (column) => column);

  GeneratedColumn<DateTime> get giftedAt =>
      $composableBuilder(column: $table.giftedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> usageRowsRefs<T extends Object>(
    Expression<T> Function($$UsageRowsTableAnnotationComposer a) f,
  ) {
    final $$UsageRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.usageRows,
      getReferencedColumn: (t) => t.couponId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsageRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.usageRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CouponRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CouponRowsTable,
          CouponRow,
          $$CouponRowsTableFilterComposer,
          $$CouponRowsTableOrderingComposer,
          $$CouponRowsTableAnnotationComposer,
          $$CouponRowsTableCreateCompanionBuilder,
          $$CouponRowsTableUpdateCompanionBuilder,
          (CouponRow, $$CouponRowsTableReferences),
          CouponRow,
          PrefetchHooks Function({bool usageRowsRefs})
        > {
  $$CouponRowsTableTableManager(_$AppDatabase db, $CouponRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CouponRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CouponRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CouponRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<CouponKind> kind = const Value.absent(),
                Value<CouponStatus> status = const Value.absent(),
                Value<CouponCategory> category = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<BarcodeFormat> barcodeFormat = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int?> faceValue = const Value.absent(),
                Value<int?> balance = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> issuer = const Value.absent(),
                Value<String?> giftedTo = const Value.absent(),
                Value<DateTime?> giftedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CouponRowsCompanion(
                id: id,
                brand: brand,
                productName: productName,
                kind: kind,
                status: status,
                category: category,
                barcode: barcode,
                barcodeFormat: barcodeFormat,
                imagePath: imagePath,
                expiresAt: expiresAt,
                faceValue: faceValue,
                balance: balance,
                memo: memo,
                issuer: issuer,
                giftedTo: giftedTo,
                giftedAt: giftedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String brand,
                required String productName,
                required CouponKind kind,
                required CouponStatus status,
                required CouponCategory category,
                Value<String?> barcode = const Value.absent(),
                required BarcodeFormat barcodeFormat,
                Value<String?> imagePath = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int?> faceValue = const Value.absent(),
                Value<int?> balance = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> issuer = const Value.absent(),
                Value<String?> giftedTo = const Value.absent(),
                Value<DateTime?> giftedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CouponRowsCompanion.insert(
                id: id,
                brand: brand,
                productName: productName,
                kind: kind,
                status: status,
                category: category,
                barcode: barcode,
                barcodeFormat: barcodeFormat,
                imagePath: imagePath,
                expiresAt: expiresAt,
                faceValue: faceValue,
                balance: balance,
                memo: memo,
                issuer: issuer,
                giftedTo: giftedTo,
                giftedAt: giftedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CouponRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({usageRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (usageRowsRefs) db.usageRows],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (usageRowsRefs)
                    await $_getPrefetchedData<
                      CouponRow,
                      $CouponRowsTable,
                      UsageRow
                    >(
                      currentTable: table,
                      referencedTable: $$CouponRowsTableReferences
                          ._usageRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CouponRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).usageRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.couponId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CouponRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CouponRowsTable,
      CouponRow,
      $$CouponRowsTableFilterComposer,
      $$CouponRowsTableOrderingComposer,
      $$CouponRowsTableAnnotationComposer,
      $$CouponRowsTableCreateCompanionBuilder,
      $$CouponRowsTableUpdateCompanionBuilder,
      (CouponRow, $$CouponRowsTableReferences),
      CouponRow,
      PrefetchHooks Function({bool usageRowsRefs})
    >;
typedef $$UsageRowsTableCreateCompanionBuilder =
    UsageRowsCompanion Function({
      required String id,
      required String couponId,
      required int amount,
      required DateTime usedAt,
      Value<String?> place,
      Value<String?> memo,
      Value<int> rowid,
    });
typedef $$UsageRowsTableUpdateCompanionBuilder =
    UsageRowsCompanion Function({
      Value<String> id,
      Value<String> couponId,
      Value<int> amount,
      Value<DateTime> usedAt,
      Value<String?> place,
      Value<String?> memo,
      Value<int> rowid,
    });

final class $$UsageRowsTableReferences
    extends BaseReferences<_$AppDatabase, $UsageRowsTable, UsageRow> {
  $$UsageRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CouponRowsTable _couponIdTable(_$AppDatabase db) =>
      db.couponRows.createAlias('usage_rows__coupon_id__coupon_rows__id');

  $$CouponRowsTableProcessedTableManager get couponId {
    final $_column = $_itemColumn<String>('coupon_id')!;

    final manager = $$CouponRowsTableTableManager(
      $_db,
      $_db.couponRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_couponIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UsageRowsTableFilterComposer
    extends Composer<_$AppDatabase, $UsageRowsTable> {
  $$UsageRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get usedAt => $composableBuilder(
    column: $table.usedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  $$CouponRowsTableFilterComposer get couponId {
    final $$CouponRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.couponId,
      referencedTable: $db.couponRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CouponRowsTableFilterComposer(
            $db: $db,
            $table: $db.couponRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsageRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsageRowsTable> {
  $$UsageRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get usedAt => $composableBuilder(
    column: $table.usedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  $$CouponRowsTableOrderingComposer get couponId {
    final $$CouponRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.couponId,
      referencedTable: $db.couponRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CouponRowsTableOrderingComposer(
            $db: $db,
            $table: $db.couponRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsageRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsageRowsTable> {
  $$UsageRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get usedAt =>
      $composableBuilder(column: $table.usedAt, builder: (column) => column);

  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  $$CouponRowsTableAnnotationComposer get couponId {
    final $$CouponRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.couponId,
      referencedTable: $db.couponRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CouponRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.couponRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsageRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsageRowsTable,
          UsageRow,
          $$UsageRowsTableFilterComposer,
          $$UsageRowsTableOrderingComposer,
          $$UsageRowsTableAnnotationComposer,
          $$UsageRowsTableCreateCompanionBuilder,
          $$UsageRowsTableUpdateCompanionBuilder,
          (UsageRow, $$UsageRowsTableReferences),
          UsageRow,
          PrefetchHooks Function({bool couponId})
        > {
  $$UsageRowsTableTableManager(_$AppDatabase db, $UsageRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsageRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsageRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsageRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> couponId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> usedAt = const Value.absent(),
                Value<String?> place = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsageRowsCompanion(
                id: id,
                couponId: couponId,
                amount: amount,
                usedAt: usedAt,
                place: place,
                memo: memo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String couponId,
                required int amount,
                required DateTime usedAt,
                Value<String?> place = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsageRowsCompanion.insert(
                id: id,
                couponId: couponId,
                amount: amount,
                usedAt: usedAt,
                place: place,
                memo: memo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UsageRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({couponId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (couponId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.couponId,
                                referencedTable: $$UsageRowsTableReferences
                                    ._couponIdTable(db),
                                referencedColumn: $$UsageRowsTableReferences
                                    ._couponIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UsageRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsageRowsTable,
      UsageRow,
      $$UsageRowsTableFilterComposer,
      $$UsageRowsTableOrderingComposer,
      $$UsageRowsTableAnnotationComposer,
      $$UsageRowsTableCreateCompanionBuilder,
      $$UsageRowsTableUpdateCompanionBuilder,
      (UsageRow, $$UsageRowsTableReferences),
      UsageRow,
      PrefetchHooks Function({bool couponId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CouponRowsTableTableManager get couponRows =>
      $$CouponRowsTableTableManager(_db, _db.couponRows);
  $$UsageRowsTableTableManager get usageRows =>
      $$UsageRowsTableTableManager(_db, _db.usageRows);
}
