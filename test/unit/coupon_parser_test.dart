import 'package:coupon_diary/domain/model/coupon.dart';
import 'package:coupon_diary/features/recognition/ocr/scan_types.dart';
import 'package:coupon_diary/features/recognition/parsing/brand_dictionary.dart';
import 'package:coupon_diary/features/recognition/parsing/coupon_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// OCR 결과를 흉내 낸다. 실제 ML Kit은 줄 단위 위치를 함께 주므로 여기서도
/// 위에서 아래로 쌓인 줄을 만들어 둔다.
ScanResult scanOf(List<String> lines, {DetectedBarcode? barcode}) {
  var top = 0.0;
  final ocrLines = <OcrLine>[];
  for (final line in lines) {
    ocrLines.add(
      OcrLine(text: line, top: top, left: 0, height: 20, width: 200),
    );
    top += 30;
  }
  return ScanResult(
    text: OcrResult(fullText: lines.join('\n'), lines: ocrLines),
    barcode: barcode,
  );
}

void main() {
  const parser = CouponParser();
  final now = DateTime(2026, 7, 1);

  group('유효기간 추출', () {
    test('라벨과 같은 줄에 있는 날짜를 읽는다', () {
      final result = parser.parse(
        scanOf(['스타벅스', '아이스 카페 아메리카노 T', '유효기간 2026.08.15']),
        now: now,
      );

      expect(result.expiresAt, DateTime(2026, 8, 15));
      expect(
        result.confidenceOf(ParsedField.expiresAt),
        greaterThanOrEqualTo(0.9),
      );
    });

    test('한글 연월일 표기를 읽는다', () {
      final result = parser.parse(
        scanOf(['교촌치킨', '레드콤보', '사용기한 2026년 9월 3일']),
        now: now,
      );

      expect(result.expiresAt, DateTime(2026, 9, 3));
    });

    test('라벨 다음 줄에 날짜가 있어도 읽는다', () {
      final result = parser.parse(
        scanOf(['GS25', '모바일 상품권', '유효기간', '2026-12-31']),
        now: now,
      );

      expect(result.expiresAt, DateTime(2026, 12, 31));
    });

    test('기간이 범위로 적혀 있으면 뒤쪽 날짜를 만료일로 본다', () {
      final result = parser.parse(
        scanOf(['CGV', '2D 영화관람권', '유효기간 2026.05.01 ~ 2026.10.20']),
        now: now,
      );

      expect(result.expiresAt, DateTime(2026, 10, 20));
    });

    test('두 자리 연도를 2000년대로 해석한다', () {
      final result = parser.parse(
        scanOf(['던킨', '먼치킨 20개', '유효기간 26.08.09']),
        now: now,
      );

      expect(result.expiresAt, DateTime(2026, 8, 9));
    });

    test('라벨이 없으면 가장 나중 날짜를 쓰되 신뢰도를 낮춘다', () {
      final result = parser.parse(
        scanOf(['배스킨라빈스', '파인트', '2026.03.01', '2026.09.30']),
        now: now,
      );

      expect(result.expiresAt, DateTime(2026, 9, 30));
      expect(result.isLowConfidence(ParsedField.expiresAt), isTrue);
    });

    test('존재하지 않는 날짜는 버린다', () {
      final result = parser.parse(
        scanOf(['이디야커피', '아메리카노', '유효기간 2026.02.31']),
        now: now,
      );

      expect(result.expiresAt, isNull);
    });
  });

  group('브랜드 인식', () {
    test('띄어쓰기가 섞여도 매칭된다', () {
      expect(matchBrand('파리 바게뜨 상품권')?.canonical, '파리바게뜨');
    });

    test('영문 표기를 매칭한다', () {
      expect(matchBrand('STARBUCKS COFFEE')?.canonical, '스타벅스');
    });

    test('더 긴 표기를 우선한다', () {
      // "이디야"만 보고 끊으면 안 된다.
      expect(matchBrand('이디야커피 아메리카노')?.canonical, '이디야커피');
    });

    test('브랜드에서 카테고리를 유추한다', () {
      final result = parser.parse(
        scanOf(['CGV', '일반 2D 영화관람권 1매', '유효기간 2026.09.01']),
        now: now,
      );

      expect(result.brand, 'CGV');
      expect(result.category, CouponCategory.culture);
    });
  });

  group('금액권', () {
    test('금액권 문구가 있으면 금액권으로 본다', () {
      final result = parser.parse(
        scanOf(['스타벅스', '금액권 30,000원', '유효기간 2026.12.01']),
        now: now,
      );

      expect(result.kind, CouponKind.amount);
      expect(result.faceValue, 30000);
    });

    test('한글 금액 표기를 숫자로 바꾼다', () {
      final result = parser.parse(
        scanOf(['GS25', '모바일 상품권 5천원', '유효기간 2026.10.01']),
        now: now,
      );

      expect(result.kind, CouponKind.amount);
      expect(result.faceValue, 5000);
    });

    test('결제금액은 액면가 후보에서 제외한다', () {
      final result = parser.parse(
        scanOf(['올리브영', '금액권 10,000원', '결제금액 8,500원', '유효기간 2026.11.11']),
        now: now,
      );

      expect(result.faceValue, 10000);
    });

    test('교환권에는 액면가를 채우지 않는다', () {
      final result = parser.parse(
        scanOf(['BBQ', '황금올리브 치킨', '정가 20,000원', '유효기간 2026.09.09']),
        now: now,
      );

      expect(result.kind, CouponKind.exchange);
      expect(result.faceValue, isNull);
    });
  });

  group('발행사와 상품명', () {
    test('발행사를 판정한다', () {
      final result = parser.parse(
        scanOf(['카카오톡 선물하기', '스타벅스', '아메리카노 T', '유효기간 2026.08.01']),
        now: now,
      );

      expect(result.issuer, '카카오톡 선물하기');
    });

    test('상품명 라벨 뒤의 값을 상품명으로 쓴다', () {
      final result = parser.parse(
        scanOf(['기프티쇼', '상품명 : 황금올리브 치킨 세트', '유효기간 2026.08.01']),
        now: now,
      );

      expect(result.productName, '황금올리브 치킨 세트');
    });

    test('안내 문구는 상품명 후보에서 걸러진다', () {
      final result = parser.parse(
        scanOf([
          '스타벅스',
          '아이스 카페 아메리카노 T',
          '유효기간 2026.08.15',
          '고객센터 1234-5678',
          '쿠폰번호 8801234567890',
        ]),
        now: now,
      );

      expect(result.productName, '아이스 카페 아메리카노 T');
    });
  });

  group('바코드', () {
    test('바코드가 있으면 신뢰도는 최대', () {
      final result = parser.parse(
        scanOf(
          ['스타벅스', '아메리카노', '유효기간 2026.08.15'],
          barcode: const DetectedBarcode(
            value: '8801234567890',
            format: BarcodeFormat.code128,
          ),
        ),
        now: now,
      );

      expect(result.barcode, '8801234567890');
      expect(result.barcodeFormat, BarcodeFormat.code128);
      expect(result.isReliable, isTrue);
    });

    test('아무것도 못 읽으면 빈 결과를 낸다', () {
      final result = parser.parse(const ScanResult.empty(), now: now);

      expect(result.brand, isNull);
      expect(result.expiresAt, isNull);
      expect(result.isReliable, isFalse);
    });
  });

  group('검토 필요 판정', () {
    // 유효기간이 틀리면 알림이 엉뚱한 날에 오고 사용자는 쿠폰을 소멸시킨다.
    // 이 앱이 막으려는 실패라서 다른 필드보다 기준을 훨씬 높게 잡는다.
    test('유효기간 기준은 0.95로 가장 엄격하다', () {
      expect(ParsedCoupon.reviewThresholds[ParsedField.expiresAt], 0.95);
      for (final entry in ParsedCoupon.reviewThresholds.entries) {
        if (entry.key == ParsedField.expiresAt) continue;
        expect(
          entry.value,
          lessThan(0.95),
          reason: '${entry.key}가 유효기간만큼 엄격할 이유가 없다',
        );
      }
    });

    test('라벨과 날짜가 한 줄에 있으면 확인 없이 통과한다', () {
      final result = parser.parse(
        scanOf(['스타벅스', '아메리카노 T', '유효기간 2026.08.15']),
        now: now,
      );

      expect(result.isLowConfidence(ParsedField.expiresAt), isFalse);
      expect(
        result.fieldsNeedingReview,
        isNot(contains(ParsedField.expiresAt)),
      );
    });

    test('라벨 다음 줄에서 읽은 날짜는 확인을 받는다', () {
      // 표 형태 레이아웃에서 값을 잘못 짚었을 수 있다. 0.8은 통과시키지 않는다.
      final result = parser.parse(
        scanOf(['GS25', '모바일 상품권', '유효기간', '2026-12-31']),
        now: now,
      );

      expect(result.expiresAt, DateTime(2026, 12, 31));
      expect(result.isLowConfidence(ParsedField.expiresAt), isTrue);
      expect(result.fieldsNeedingReview, contains(ParsedField.expiresAt));
      expect(result.isReliable, isFalse);
    });

    test('라벨 없이 추측한 날짜는 당연히 확인을 받는다', () {
      final result = parser.parse(
        scanOf(['배스킨라빈스', '파인트', '2026.03.01', '2026.09.30']),
        now: now,
      );

      expect(result.fieldsNeedingReview, contains(ParsedField.expiresAt));
    });

    test('교환권에는 액면가 확인을 요구하지 않는다', () {
      final result = parser.parse(
        scanOf(['CGV', '2D 영화관람권', '유효기간 2026.09.01']),
        now: now,
      );

      expect(result.kind, CouponKind.exchange);
      expect(
        result.fieldsNeedingReview,
        isNot(contains(ParsedField.faceValue)),
      );
    });

    test('금액권 액면가를 라벨 없이 주우면 확인을 받는다', () {
      // 0.55 — "금액권/상품권" 문구 없이 숫자만 보고 고른 경우.
      final result = parser.parse(
        scanOf(['스타벅스', '충전권', '12,000원', '유효기간 2026.12.01']),
        now: now,
      );

      expect(result.kind, CouponKind.amount);
      expect(result.fieldsNeedingReview, contains(ParsedField.faceValue));
    });
  });
}
