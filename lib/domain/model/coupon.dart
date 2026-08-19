/// 순수 Dart 도메인 모델. `package:flutter/*`를 import하지 않는다.
library;

/// 쿠폰의 성격.
enum CouponKind {
  /// 교환권 — "아메리카노 1잔"처럼 한 번에 소진.
  exchange('교환권'),

  /// 금액권 — "스타벅스 3만원권"처럼 잔액이 남는다. 한국 기프티콘의 큰 축인데
  /// 대부분의 경쟁 앱이 사용/미사용 이진 상태로만 다뤄서 잔액이 유실된다.
  amount('금액권');

  const CouponKind(this.label);
  final String label;
}

enum CouponStatus {
  active('사용 가능'),
  used('사용 완료'),
  expired('기간 만료'),
  gifted('선물함'),
  archived('보관됨');

  const CouponStatus(this.label);
  final String label;

  bool get isOpen => this == CouponStatus.active;
}

enum CouponCategory {
  cafe('카페'),
  convenience('편의점'),
  chickenPizza('치킨·피자'),
  bakery('베이커리'),
  dining('외식'),
  culture('영화·문화'),
  voucher('상품권'),
  beauty('뷰티'),
  etc('기타');

  const CouponCategory(this.label);
  final String label;
}

enum BarcodeFormat {
  code128('CODE128'),
  ean13('EAN-13'),
  qr('QR'),
  unknown('기타');

  const BarcodeFormat(this.label);
  final String label;
}

/// 모바일 쿠폰 한 장.
class Coupon {
  const Coupon({
    required this.id,
    required this.brand,
    required this.productName,
    required this.kind,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.barcode,
    this.barcodeFormat = BarcodeFormat.unknown,
    this.imagePath,
    this.expiresAt,
    this.faceValue,
    this.balance,
    this.memo,
    this.issuer,
    this.giftedTo,
    this.giftedAt,
  });

  final String id;
  final String brand;
  final String productName;
  final CouponKind kind;
  final CouponStatus status;
  final CouponCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 바코드·교환권 번호. **절대 네트워크로 전송하지 않는다** (AGENTS.md 2절).
  final String? barcode;
  final BarcodeFormat barcodeFormat;

  /// 앱 샌드박스 내부 경로. 갤러리로 되쓰지 않는다.
  final String? imagePath;

  final DateTime? expiresAt;

  /// 금액권 액면가 (원).
  final int? faceValue;

  /// 금액권 잔액 (원). 사용 이력의 합에서 파생되는 캐시값.
  final int? balance;

  final String? memo;

  /// 발행사 (카카오톡 선물하기, 기프티쇼, 스마일콘 …).
  final String? issuer;

  final String? giftedTo;
  final DateTime? giftedAt;

  /// 만료까지 남은 일수. 오늘 만료면 0, 이미 지났으면 음수. 만료일이 없으면 null.
  ///
  /// 시각이 아니라 **날짜** 기준으로 센다. 23:59에 앱을 열었을 때
  /// "0일 남음"이 "-1일"로 보이면 안 되기 때문.
  int? daysLeftFrom(DateTime now) {
    final expiry = expiresAt;
    if (expiry == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expiry.year, expiry.month, expiry.day);
    return target.difference(today).inDays;
  }

  /// 사용자에게 경고를 띄워야 할 만큼 임박했는가.
  bool isExpiringSoon(DateTime now, {int withinDays = 7}) {
    final days = daysLeftFrom(now);
    if (days == null) return false;
    return days >= 0 && days <= withinDays;
  }

  bool isExpiredAt(DateTime now) {
    final days = daysLeftFrom(now);
    return days != null && days < 0;
  }

  /// 금액권이면서 잔액이 남아 있는가.
  bool get hasRemainingBalance =>
      kind == CouponKind.amount && (balance ?? 0) > 0;

  Coupon copyWith({
    String? brand,
    String? productName,
    CouponKind? kind,
    CouponStatus? status,
    CouponCategory? category,
    DateTime? updatedAt,
    String? barcode,
    BarcodeFormat? barcodeFormat,
    String? imagePath,
    DateTime? expiresAt,
    int? faceValue,
    int? balance,
    String? memo,
    String? issuer,
    String? giftedTo,
    DateTime? giftedAt,
    bool clearExpiresAt = false,
    bool clearGift = false,
  }) {
    return Coupon(
      id: id,
      brand: brand ?? this.brand,
      productName: productName ?? this.productName,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      barcode: barcode ?? this.barcode,
      barcodeFormat: barcodeFormat ?? this.barcodeFormat,
      imagePath: imagePath ?? this.imagePath,
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      faceValue: faceValue ?? this.faceValue,
      balance: balance ?? this.balance,
      memo: memo ?? this.memo,
      issuer: issuer ?? this.issuer,
      giftedTo: clearGift ? null : (giftedTo ?? this.giftedTo),
      giftedAt: clearGift ? null : (giftedAt ?? this.giftedAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Coupon && other.id == id && other.updatedAt == updatedAt);

  @override
  int get hashCode => Object.hash(id, updatedAt);
}

/// 금액권 사용 이력 한 건.
///
/// 잔액의 진실은 이 이력의 합이다. `Coupon.balance`는 조회 속도를 위한 캐시.
class UsageEntry {
  const UsageEntry({
    required this.id,
    required this.couponId,
    required this.amount,
    required this.usedAt,
    this.place,
    this.memo,
  });

  final String id;
  final String couponId;

  /// 사용 금액 (원).
  final int amount;
  final DateTime usedAt;
  final String? place;
  final String? memo;
}
