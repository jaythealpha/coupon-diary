import 'package:coupon_diary/data/coupon_json.dart';
import 'package:coupon_diary/domain/model/coupon.dart';
import 'package:flutter_test/flutter_test.dart';

/// 이 형식은 백업 파일과 웹 체험판 저장이 함께 쓴다. 왕복이 깨지면
/// 두 경로 모두에서 데이터가 사라진다.
void main() {
  test('쿠폰 왕복이 모든 필드를 보존한다', () {
    final original = Coupon(
      id: 'c1',
      brand: '스타벅스',
      productName: '금액권 3만원',
      kind: CouponKind.amount,
      status: CouponStatus.gifted,
      category: CouponCategory.cafe,
      createdAt: DateTime(2026, 7, 1, 10, 30),
      updatedAt: DateTime(2026, 8, 1, 9),
      barcode: '8801234567890',
      barcodeFormat: BarcodeFormat.code128,
      expiresAt: DateTime(2026, 12, 31),
      faceValue: 30000,
      balance: 17500,
      memo: '회사 선물',
      issuer: '카카오톡 선물하기',
      giftedTo: '김서연',
      giftedAt: DateTime(2026, 8, 2),
    );

    final restored = couponFromJson(couponToJson(original))!;

    expect(restored.id, original.id);
    expect(restored.brand, original.brand);
    expect(restored.productName, original.productName);
    expect(restored.kind, original.kind);
    expect(restored.status, original.status);
    expect(restored.category, original.category);
    expect(restored.createdAt, original.createdAt);
    expect(restored.barcode, original.barcode);
    expect(restored.barcodeFormat, original.barcodeFormat);
    expect(restored.expiresAt, original.expiresAt);
    expect(restored.faceValue, original.faceValue);
    expect(restored.balance, original.balance);
    expect(restored.memo, original.memo);
    expect(restored.issuer, original.issuer);
    expect(restored.giftedTo, original.giftedTo);
    expect(restored.giftedAt, original.giftedAt);
  });

  test('null 필드는 null로 남는다', () {
    final original = Coupon(
      id: 'c2',
      brand: 'CGV',
      productName: '영화관람권',
      kind: CouponKind.exchange,
      status: CouponStatus.active,
      category: CouponCategory.culture,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );

    final restored = couponFromJson(couponToJson(original))!;

    expect(restored.barcode, isNull);
    expect(restored.expiresAt, isNull);
    expect(restored.faceValue, isNull);
    expect(restored.memo, isNull);
  });

  test('사용 이력 왕복', () {
    final original = UsageEntry(
      id: 'u1',
      couponId: 'c1',
      amount: 6500,
      usedAt: DateTime(2026, 7, 20, 14, 5),
      place: '강남대로점',
    );

    final restored = usageFromJson(usageToJson(original))!;

    expect(restored.id, original.id);
    expect(restored.couponId, original.couponId);
    expect(restored.amount, original.amount);
    expect(restored.usedAt, original.usedAt);
    expect(restored.place, original.place);
  });

  test('필수 필드가 빠진 항목은 null을 돌려준다', () {
    expect(couponFromJson({'brand': '스타벅스'}), isNull);
    expect(couponFromJson('문자열'), isNull);
    expect(usageFromJson({'id': 'u1'}), isNull);
  });

  test('모르는 enum 값은 안전한 기본값으로 떨어진다', () {
    // 미래 버전이 새 카테고리를 추가한 백업을 옛 앱에서 열 때.
    final restored = couponFromJson({
      'id': 'c3',
      'brand': '미래브랜드',
      'productName': '미래상품',
      'kind': 'subscription',
      'status': 'archived-v2',
      'category': 'metaverse',
      'barcodeFormat': 'qr-v3',
      'createdAt': '2026-07-01T00:00:00.000',
      'updatedAt': '2026-07-01T00:00:00.000',
    })!;

    expect(restored.kind, CouponKind.exchange);
    expect(restored.status, CouponStatus.active);
    expect(restored.category, CouponCategory.etc);
    expect(restored.barcodeFormat, BarcodeFormat.unknown);
  });
}
