import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/model/coupon.dart';

part 'database.g.dart';

/// 쿠폰 테이블.
///
/// 이미지 원본은 DB가 아니라 앱 문서 디렉터리에 파일로 두고 경로만 저장한다.
/// BLOB로 넣으면 DB가 수백 MB로 불어나 백업·마이그레이션이 힘들어진다.
class CouponRows extends Table {
  TextColumn get id => text()();
  TextColumn get brand => text()();
  TextColumn get productName => text()();
  TextColumn get kind => textEnum<CouponKind>()();
  TextColumn get status => textEnum<CouponStatus>()();
  TextColumn get category => textEnum<CouponCategory>()();
  TextColumn get barcode => text().nullable()();
  TextColumn get barcodeFormat => textEnum<BarcodeFormat>()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  IntColumn get faceValue => integer().nullable()();
  IntColumn get balance => integer().nullable()();
  TextColumn get memo => text().nullable()();
  TextColumn get issuer => text().nullable()();
  TextColumn get giftedTo => text().nullable()();
  DateTimeColumn get giftedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 금액권 사용 이력.
class UsageRows extends Table {
  TextColumn get id => text()();
  TextColumn get couponId =>
      text().references(CouponRows, #id, onDelete: KeyAction.cascade)();
  IntColumn get amount => integer()();
  DateTimeColumn get usedAt => dateTime()();
  TextColumn get place => text().nullable()();
  TextColumn get memo => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CouponRows, UsageRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'coupon_diary'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // 사용 이력 삭제 시 잔액이 어긋나지 않도록 외래키 제약을 켠다.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
