import 'dart:async';

import '../../domain/model/coupon.dart';
import '../../domain/repository/coupon_repository.dart';

/// 메모리 구현.
///
/// 두 곳에서 쓴다.
/// 1. 웹 빌드 — Xcode/Android SDK 없이 UI를 검증하기 위한 경로 (docs/02-architecture.md)
/// 2. 단위·위젯 테스트 — SQLite 없이 리포지토리 계약을 검증
class InMemoryCouponRepository implements CouponRepository {
  InMemoryCouponRepository({
    List<Coupon> seed = const [],
    List<UsageEntry> usageSeed = const [],
  }) {
    for (final c in seed) {
      _coupons[c.id] = c;
    }
    for (final u in usageSeed) {
      _usage.add(u);
    }
  }

  final Map<String, Coupon> _coupons = {};
  final List<UsageEntry> _usage = [];
  final _changes = StreamController<void>.broadcast();

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<List<Coupon>> watchCoupons(CouponQuery query) =>
      _live(() => _apply(query));

  List<Coupon> _apply(CouponQuery query) {
    final keyword = query.keyword.trim().toLowerCase();
    final result = _coupons.values.where((c) {
      if (!query.statuses.contains(c.status)) return false;
      if (query.categories.isNotEmpty &&
          !query.categories.contains(c.category)) {
        return false;
      }
      if (keyword.isEmpty) return true;
      return c.brand.toLowerCase().contains(keyword) ||
          c.productName.toLowerCase().contains(keyword) ||
          (c.memo ?? '').toLowerCase().contains(keyword);
    }).toList();

    int byExpiry(Coupon a, Coupon b, {required bool ascending}) {
      // 만료일이 없는 쿠폰은 정렬 방향과 무관하게 항상 뒤로 보낸다.
      if (a.expiresAt == null && b.expiresAt == null) return 0;
      if (a.expiresAt == null) return 1;
      if (b.expiresAt == null) return -1;
      return ascending
          ? a.expiresAt!.compareTo(b.expiresAt!)
          : b.expiresAt!.compareTo(a.expiresAt!);
    }

    switch (query.sort) {
      case CouponSort.expiryAsc:
        result.sort((a, b) {
          final c = byExpiry(a, b, ascending: true);
          return c != 0 ? c : a.brand.compareTo(b.brand);
        });
      case CouponSort.expiryDesc:
        result.sort((a, b) => byExpiry(a, b, ascending: false));
      case CouponSort.addedDesc:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case CouponSort.brandAsc:
        result.sort((a, b) {
          final c = a.brand.compareTo(b.brand);
          return c != 0 ? c : byExpiry(a, b, ascending: true);
        });
    }
    return result;
  }

  @override
  Stream<Coupon?> watchCoupon(String id) => _live(() => _coupons[id]);

  @override
  Future<Coupon?> findById(String id) async => _coupons[id];

  @override
  Future<List<Coupon>> activeCoupons() async => _coupons.values
      .where((c) => c.status == CouponStatus.active)
      .toList(growable: false);

  @override
  Future<void> save(Coupon coupon) async {
    _coupons[coupon.id] = coupon;
    _notify();
  }

  @override
  Future<void> delete(String id) async {
    _coupons.remove(id);
    _usage.removeWhere((u) => u.couponId == id);
    _notify();
  }

  @override
  Future<void> addUsage(UsageEntry entry) async {
    _usage.add(entry);
    _recalculateBalance(entry.couponId);
    _notify();
  }

  @override
  Future<void> deleteUsage(String usageId) async {
    final index = _usage.indexWhere((u) => u.id == usageId);
    if (index == -1) return;
    final couponId = _usage[index].couponId;
    _usage.removeAt(index);
    _recalculateBalance(couponId);
    _notify();
  }

  @override
  Stream<List<UsageEntry>> watchUsage(String couponId) => _live(() {
    final list = _usage.where((u) => u.couponId == couponId).toList()
      ..sort((a, b) => b.usedAt.compareTo(a.usedAt));
    return list;
  });

  @override
  Future<int> refreshExpiredStatuses(DateTime now) async {
    var changed = 0;
    for (final coupon in _coupons.values.toList()) {
      if (coupon.status != CouponStatus.active) continue;
      if (!coupon.isExpiredAt(now)) continue;
      _coupons[coupon.id] = coupon.copyWith(
        status: CouponStatus.expired,
        updatedAt: now,
      );
      changed++;
    }
    if (changed > 0) _notify();
    return changed;
  }

  void _recalculateBalance(String couponId) {
    final coupon = _coupons[couponId];
    if (coupon == null || coupon.kind != CouponKind.amount) return;

    final faceValue = coupon.faceValue ?? 0;
    final spent = _usage
        .where((u) => u.couponId == couponId)
        .fold<int>(0, (sum, u) => sum + u.amount);
    final remaining = (faceValue - spent).clamp(0, faceValue);

    _coupons[couponId] = coupon.copyWith(
      balance: remaining,
      status: remaining == 0 && coupon.status == CouponStatus.active
          ? CouponStatus.used
          : coupon.status,
      updatedAt: DateTime.now(),
    );
  }

  /// 현재 상태의 사본. 웹 체험판이 localStorage에 저장할 때 쓴다.
  List<Coupon> snapshotCoupons() => _coupons.values.toList(growable: false);

  List<UsageEntry> snapshotUsage() => List.of(_usage, growable: false);

  void dispose() => _changes.close();
}
