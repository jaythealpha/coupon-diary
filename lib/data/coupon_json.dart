/// 쿠폰·사용 이력의 JSON 직렬화.
///
/// 백업 파일과 웹 체험판 저장이 같은 형식을 쓴다. 한 곳에 모아두지 않으면
/// 두 경로의 필드가 조금씩 어긋나 복원이 조용히 데이터를 잃는다.
///
/// JSON 키는 짧게 줄이지 않는다. 파일이 수십 KB 수준이라 크기가 문제되지
/// 않고, 필드명이 그대로 남아 있어야 마이그레이션할 때 안전하다.
library;

import '../domain/model/coupon.dart';

Map<String, dynamic> couponToJson(Coupon c) => {
  'id': c.id,
  'brand': c.brand,
  'productName': c.productName,
  'kind': c.kind.name,
  'status': c.status.name,
  'category': c.category.name,
  'createdAt': c.createdAt.toIso8601String(),
  'updatedAt': c.updatedAt.toIso8601String(),
  'barcode': c.barcode,
  'barcodeFormat': c.barcodeFormat.name,
  'expiresAt': c.expiresAt?.toIso8601String(),
  'faceValue': c.faceValue,
  'balance': c.balance,
  'memo': c.memo,
  'issuer': c.issuer,
  'giftedTo': c.giftedTo,
  'giftedAt': c.giftedAt?.toIso8601String(),
  // imagePath는 기기 로컬 경로라 다른 환경에서 의미가 없다. 넣지 않는다.
};

Map<String, dynamic> usageToJson(UsageEntry u) => {
  'id': u.id,
  'couponId': u.couponId,
  'amount': u.amount,
  'usedAt': u.usedAt.toIso8601String(),
  'place': u.place,
  'memo': u.memo,
};

T _enumFrom<T extends Enum>(List<T> values, String? name, T fallback) =>
    values.firstWhere((v) => v.name == name, orElse: () => fallback);

Coupon? couponFromJson(Object? raw) {
  if (raw is! Map<String, dynamic>) return null;
  final id = raw['id'];
  if (id is! String || id.isEmpty) return null;

  return Coupon(
    id: id,
    brand: raw['brand'] as String? ?? '알 수 없는 브랜드',
    productName: raw['productName'] as String? ?? '이름 미확인 쿠폰',
    kind: _enumFrom(
      CouponKind.values,
      raw['kind'] as String?,
      CouponKind.exchange,
    ),
    status: _enumFrom(
      CouponStatus.values,
      raw['status'] as String?,
      CouponStatus.active,
    ),
    category: _enumFrom(
      CouponCategory.values,
      raw['category'] as String?,
      CouponCategory.etc,
    ),
    createdAt:
        DateTime.tryParse(raw['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(raw['updatedAt'] as String? ?? '') ?? DateTime.now(),
    barcode: raw['barcode'] as String?,
    barcodeFormat: _enumFrom(
      BarcodeFormat.values,
      raw['barcodeFormat'] as String?,
      BarcodeFormat.unknown,
    ),
    expiresAt: DateTime.tryParse(raw['expiresAt'] as String? ?? ''),
    faceValue: (raw['faceValue'] as num?)?.toInt(),
    balance: (raw['balance'] as num?)?.toInt(),
    memo: raw['memo'] as String?,
    issuer: raw['issuer'] as String?,
    giftedTo: raw['giftedTo'] as String?,
    giftedAt: DateTime.tryParse(raw['giftedAt'] as String? ?? ''),
  );
}

UsageEntry? usageFromJson(Object? raw) {
  if (raw is! Map<String, dynamic>) return null;
  final id = raw['id'];
  final couponId = raw['couponId'];
  final amount = raw['amount'];
  if (id is! String || couponId is! String || amount is! num) return null;

  return UsageEntry(
    id: id,
    couponId: couponId,
    amount: amount.toInt(),
    usedAt: DateTime.tryParse(raw['usedAt'] as String? ?? '') ?? DateTime.now(),
    place: raw['place'] as String?,
    memo: raw['memo'] as String?,
  );
}
