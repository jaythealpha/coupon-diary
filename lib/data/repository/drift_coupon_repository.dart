import 'package:drift/drift.dart';

import '../../domain/model/coupon.dart';
import '../../domain/repository/coupon_repository.dart';
import '../local/database.dart';

/// SQLite(Drift) 기반 구현. 모바일·데스크톱에서 쓴다.
class DriftCouponRepository implements CouponRepository {
  DriftCouponRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Coupon>> watchCoupons(CouponQuery query) {
    final select = _db.select(_db.couponRows)
      ..where((t) => t.status.isInValues(query.statuses.toList()));

    if (query.categories.isNotEmpty) {
      select.where((t) => t.category.isInValues(query.categories.toList()));
    }

    final keyword = query.keyword.trim();
    if (keyword.isNotEmpty) {
      final pattern = '%$keyword%';
      select.where(
        (t) =>
            t.brand.like(pattern) |
            t.productName.like(pattern) |
            t.memo.like(pattern),
      );
    }

    switch (query.sort) {
      case CouponSort.expiryAsc:
        // 만료일 없는 쿠폰은 항상 뒤로. SQLite에서 NULL은 기본적으로 가장 앞에
        // 오므로 명시적으로 밀어낸다.
        select.orderBy([
          (t) => OrderingTerm(expression: t.expiresAt.isNull()),
          (t) => OrderingTerm.asc(t.expiresAt),
          (t) => OrderingTerm.asc(t.brand),
        ]);
      case CouponSort.expiryDesc:
        select.orderBy([
          (t) => OrderingTerm(expression: t.expiresAt.isNull()),
          (t) => OrderingTerm.desc(t.expiresAt),
        ]);
      case CouponSort.addedDesc:
        select.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
      case CouponSort.brandAsc:
        select.orderBy([
          (t) => OrderingTerm.asc(t.brand),
          (t) => OrderingTerm.asc(t.expiresAt),
        ]);
    }

    return select.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<Coupon?> watchCoupon(String id) {
    return (_db.select(_db.couponRows)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toDomain(row));
  }

  @override
  Future<Coupon?> findById(String id) async {
    final row = await (_db.select(
      _db.couponRows,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<Coupon>> activeCoupons() async {
    final rows = await (_db.select(
      _db.couponRows,
    )..where((t) => t.status.equalsValue(CouponStatus.active))).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> save(Coupon coupon) {
    return _db
        .into(_db.couponRows)
        .insertOnConflictUpdate(_toCompanion(coupon));
  }

  @override
  Future<void> delete(String id) {
    return (_db.delete(_db.couponRows)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> addUsage(UsageEntry entry) async {
    await _db.transaction(() async {
      await _db
          .into(_db.usageRows)
          .insert(
            UsageRowsCompanion.insert(
              id: entry.id,
              couponId: entry.couponId,
              amount: entry.amount,
              usedAt: entry.usedAt,
              place: Value(entry.place),
              memo: Value(entry.memo),
            ),
          );
      await _recalculateBalance(entry.couponId);
    });
  }

  @override
  Future<void> deleteUsage(String usageId) async {
    await _db.transaction(() async {
      final row = await (_db.select(
        _db.usageRows,
      )..where((t) => t.id.equals(usageId))).getSingleOrNull();
      if (row == null) return;
      await (_db.delete(
        _db.usageRows,
      )..where((t) => t.id.equals(usageId))).go();
      await _recalculateBalance(row.couponId);
    });
  }

  @override
  Stream<List<UsageEntry>> watchUsage(String couponId) {
    return (_db.select(_db.usageRows)
          ..where((t) => t.couponId.equals(couponId))
          ..orderBy([(t) => OrderingTerm.desc(t.usedAt)]))
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => UsageEntry(
                  id: r.id,
                  couponId: r.couponId,
                  amount: r.amount,
                  usedAt: r.usedAt,
                  place: r.place,
                  memo: r.memo,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<int> refreshExpiredStatuses(DateTime now) async {
    final today = DateTime(now.year, now.month, now.day);
    return (_db.update(_db.couponRows)..where(
          (t) =>
              t.status.equalsValue(CouponStatus.active) &
              t.expiresAt.isNotNull() &
              t.expiresAt.isSmallerThanValue(today),
        ))
        .write(
          CouponRowsCompanion(
            status: const Value(CouponStatus.expired),
            updatedAt: Value(now),
          ),
        );
  }

  /// 잔액은 사용 이력의 합에서 다시 계산한다. 이력이 진실이고 `balance`는 캐시.
  Future<void> _recalculateBalance(String couponId) async {
    final coupon = await (_db.select(
      _db.couponRows,
    )..where((t) => t.id.equals(couponId))).getSingleOrNull();
    if (coupon == null || coupon.kind != CouponKind.amount) return;

    final faceValue = coupon.faceValue ?? 0;
    final usages = await (_db.select(
      _db.usageRows,
    )..where((t) => t.couponId.equals(couponId))).get();
    final spent = usages.fold<int>(0, (sum, u) => sum + u.amount);
    final remaining = (faceValue - spent).clamp(0, faceValue);

    // 잔액이 0이 되면 자동으로 사용 완료 처리한다. 사용자가 "사용완료" 버튼을
    // 따로 누르지 않아도 되게 하려는 것 — 경쟁 앱의 대표적 불만 지점(P2).
    final nextStatus = remaining == 0 && coupon.status == CouponStatus.active
        ? CouponStatus.used
        : coupon.status;

    await (_db.update(
      _db.couponRows,
    )..where((t) => t.id.equals(couponId))).write(
      CouponRowsCompanion(
        balance: Value(remaining),
        status: Value(nextStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Coupon _toDomain(CouponRow row) => Coupon(
    id: row.id,
    brand: row.brand,
    productName: row.productName,
    kind: row.kind,
    status: row.status,
    category: row.category,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    barcode: row.barcode,
    barcodeFormat: row.barcodeFormat,
    imagePath: row.imagePath,
    expiresAt: row.expiresAt,
    faceValue: row.faceValue,
    balance: row.balance,
    memo: row.memo,
    issuer: row.issuer,
    giftedTo: row.giftedTo,
    giftedAt: row.giftedAt,
  );

  CouponRowsCompanion _toCompanion(Coupon c) => CouponRowsCompanion.insert(
    id: c.id,
    brand: c.brand,
    productName: c.productName,
    kind: c.kind,
    status: c.status,
    category: c.category,
    barcodeFormat: c.barcodeFormat,
    barcode: Value(c.barcode),
    imagePath: Value(c.imagePath),
    expiresAt: Value(c.expiresAt),
    faceValue: Value(c.faceValue),
    balance: Value(c.balance),
    memo: Value(c.memo),
    issuer: Value(c.issuer),
    giftedTo: Value(c.giftedTo),
    giftedAt: Value(c.giftedAt),
    createdAt: c.createdAt,
    updatedAt: c.updatedAt,
  );
}
