import '../model/coupon.dart';

/// 보관함 정렬 기준.
enum CouponSort {
  expiryAsc('만료 임박순'),
  expiryDesc('만료 여유순'),
  addedDesc('최근 등록순'),
  brandAsc('브랜드순');

  const CouponSort(this.label);
  final String label;
}

/// 보관함 조회 조건.
class CouponQuery {
  const CouponQuery({
    this.statuses = const {CouponStatus.active},
    this.categories = const {},
    this.keyword = '',
    this.sort = CouponSort.expiryAsc,
  });

  final Set<CouponStatus> statuses;
  final Set<CouponCategory> categories;
  final String keyword;
  final CouponSort sort;

  CouponQuery copyWith({
    Set<CouponStatus>? statuses,
    Set<CouponCategory>? categories,
    String? keyword,
    CouponSort? sort,
  }) {
    return CouponQuery(
      statuses: statuses ?? this.statuses,
      categories: categories ?? this.categories,
      keyword: keyword ?? this.keyword,
      sort: sort ?? this.sort,
    );
  }
}

/// 쿠폰 저장소. 구현은 네이티브(Drift)와 웹(인메모리) 두 가지.
///
/// 화면은 이 인터페이스만 알고 Drift나 SQLite를 직접 알지 못한다.
abstract interface class CouponRepository {
  /// 조건에 맞는 쿠폰 목록을 실시간으로 흘려보낸다.
  Stream<List<Coupon>> watchCoupons(CouponQuery query);

  Stream<Coupon?> watchCoupon(String id);

  Future<Coupon?> findById(String id);

  /// 알림 스케줄링에 쓸 전체 활성 쿠폰.
  Future<List<Coupon>> activeCoupons();

  Future<void> save(Coupon coupon);

  Future<void> delete(String id);

  /// 사용 이력 추가. 금액권이면 잔액을 차감하고, 잔액이 0이 되면
  /// 상태를 `used`로 바꾼다.
  Future<void> addUsage(UsageEntry entry);

  Future<void> deleteUsage(String usageId);

  Stream<List<UsageEntry>> watchUsage(String couponId);

  /// 만료일이 지난 활성 쿠폰의 상태를 `expired`로 갱신한다.
  ///
  /// 만료되었다고 목록에서 지우지 않는 이유: 유효기간이 지나도 미사용이면
  /// 90~95% 환불을 받을 수 있어서, 사용자가 만료 목록을 볼 수 있어야 한다.
  Future<int> refreshExpiredStatuses(DateTime now);
}
