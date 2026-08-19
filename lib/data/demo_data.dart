import '../domain/model/coupon.dart';

/// 웹 검증 빌드와 위젯 테스트에서 쓰는 데모 데이터.
///
/// 빈 목록만 보고는 카드 레이아웃·정렬·만료 배지를 검증할 수 없어서,
/// 실제 서비스에 가까운 상태 조합(임박/여유/금액권/만료/선물함)을 만들어 둔다.
List<Coupon> demoCoupons(DateTime now) {
  DateTime inDays(int days) =>
      DateTime(now.year, now.month, now.day).add(Duration(days: days));

  Coupon build({
    required String id,
    required String brand,
    required String productName,
    required CouponCategory category,
    required int? expiresInDays,
    CouponKind kind = CouponKind.exchange,
    CouponStatus status = CouponStatus.active,
    int? faceValue,
    int? balance,
    String? issuer,
    String? memo,
    String? giftedTo,
  }) {
    return Coupon(
      id: id,
      brand: brand,
      productName: productName,
      kind: kind,
      status: status,
      category: category,
      createdAt: now.subtract(Duration(days: 30 - (id.hashCode % 20).abs())),
      updatedAt: now,
      barcode: '${8800000000000 + id.hashCode.abs() % 1000000}',
      barcodeFormat: BarcodeFormat.code128,
      expiresAt: expiresInDays == null ? null : inDays(expiresInDays),
      faceValue: faceValue,
      balance: balance,
      issuer: issuer,
      memo: memo,
      giftedTo: giftedTo,
      giftedAt: giftedTo == null ? null : now.subtract(const Duration(days: 2)),
    );
  }

  return [
    build(
      id: 'demo-1',
      brand: '스타벅스',
      productName: '아이스 카페 아메리카노 T',
      category: CouponCategory.cafe,
      expiresInDays: 2,
      issuer: '카카오톡 선물하기',
    ),
    build(
      id: 'demo-2',
      brand: '스타벅스',
      productName: '금액권 3만원',
      category: CouponCategory.cafe,
      kind: CouponKind.amount,
      faceValue: 30000,
      balance: 17500,
      expiresInDays: 41,
      issuer: '카카오톡 선물하기',
      memo: '회사 워크샵 상품',
    ),
    build(
      id: 'demo-3',
      brand: 'BBQ',
      productName: '황금올리브 치킨 + 콜라 1.25L',
      category: CouponCategory.chickenPizza,
      expiresInDays: 6,
      issuer: '기프티쇼',
    ),
    build(
      id: 'demo-4',
      brand: 'GS25',
      productName: '모바일 상품권 5천원',
      category: CouponCategory.convenience,
      kind: CouponKind.amount,
      faceValue: 5000,
      balance: 5000,
      expiresInDays: 13,
      issuer: '스마일콘',
    ),
    build(
      id: 'demo-5',
      brand: '파리바게뜨',
      productName: '딸기 생크림 케이크',
      category: CouponCategory.bakery,
      expiresInDays: 88,
      issuer: '카카오톡 선물하기',
    ),
    build(
      id: 'demo-6',
      brand: 'CGV',
      productName: '일반 2D 영화관람권 1매',
      category: CouponCategory.culture,
      expiresInDays: 25,
      issuer: '기프티쇼',
    ),
    build(
      id: 'demo-7',
      brand: '배스킨라빈스',
      productName: '싱글레귤러 아이스크림',
      category: CouponCategory.dining,
      expiresInDays: -4,
      status: CouponStatus.expired,
      issuer: '카카오톡 선물하기',
      memo: '미사용 — 환불 문의해볼 것',
    ),
    build(
      id: 'demo-8',
      brand: '투썸플레이스',
      productName: '아이스 아메리카노 R',
      category: CouponCategory.cafe,
      expiresInDays: 30,
      status: CouponStatus.gifted,
      giftedTo: '김서연',
      issuer: '카카오톡 선물하기',
    ),
    build(
      id: 'demo-9',
      brand: '올리브영',
      productName: '금액권 1만원',
      category: CouponCategory.beauty,
      kind: CouponKind.amount,
      faceValue: 10000,
      balance: 0,
      expiresInDays: 120,
      status: CouponStatus.used,
      issuer: '기프티쇼',
    ),
    build(
      id: 'demo-10',
      brand: '이디야커피',
      productName: '아메리카노 2잔',
      category: CouponCategory.cafe,
      expiresInDays: null,
      memo: '유효기간 표기 없음',
    ),
  ];
}

List<UsageEntry> demoUsage(DateTime now) => [
  UsageEntry(
    id: 'usage-1',
    couponId: 'demo-2',
    amount: 6500,
    usedAt: now.subtract(const Duration(days: 12)),
    place: '스타벅스 강남대로점',
  ),
  UsageEntry(
    id: 'usage-2',
    couponId: 'demo-2',
    amount: 6000,
    usedAt: now.subtract(const Duration(days: 5)),
    place: '스타벅스 역삼점',
  ),
  UsageEntry(
    id: 'usage-3',
    couponId: 'demo-9',
    amount: 10000,
    usedAt: now.subtract(const Duration(days: 20)),
    place: '올리브영 신논현점',
  ),
];
