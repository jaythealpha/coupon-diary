import 'package:coupon_diary/domain/model/coupon.dart';
import 'package:coupon_diary/features/recognition/ocr/scan_types.dart';
import 'package:coupon_diary/features/recognition/parsing/brand_dictionary.dart';
import 'package:coupon_diary/features/recognition/parsing/coupon_parser.dart';
import 'package:coupon_diary/features/recognition/parsing/issuer_rules.dart';
import 'package:flutter_test/flutter_test.dart';

ScanResult scanOf(List<String> lines) {
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
  );
}

void main() {
  group('사전 무결성', () {
    // 사전이 커질수록 실수로 같은 브랜드를 두 번 넣기 쉽다. 중복이 있으면
    // 어느 항목이 매칭될지가 리스트 순서에 좌우되어 버그를 찾기 어려워진다.
    test('정식 명칭에 중복이 없다', () {
      final names = kBrandDictionary.map((e) => e.canonical).toList();
      final duplicates = <String>{};
      final seen = <String>{};
      for (final name in names) {
        if (!seen.add(name)) duplicates.add(name);
      }
      expect(duplicates, isEmpty, reason: '중복 브랜드: $duplicates');
    });

    test('정규화 후에도 서로 다른 브랜드끼리 표기가 겹치지 않는다', () {
      // "메가커피"의 별칭이 "컴포즈커피"의 별칭과 겹치면 오매칭이 난다.
      final owners = <String, String>{};
      final collisions = <String>[];
      for (final entry in kBrandDictionary) {
        for (final form in entry.allForms) {
          final key = normalizeForMatch(form);
          final existing = owners[key];
          if (existing != null && existing != entry.canonical) {
            collisions.add('$key: $existing vs ${entry.canonical}');
          }
          owners[key] = entry.canonical;
        }
      }
      expect(collisions, isEmpty, reason: collisions.join(', '));
    });

    test('빈 표기가 없다', () {
      for (final entry in kBrandDictionary) {
        expect(entry.canonical.trim(), isNotEmpty);
        for (final alias in entry.aliases) {
          expect(
            alias.trim(),
            isNotEmpty,
            reason: '${entry.canonical}에 빈 별칭이 있다',
          );
        }
      }
    });

    test('브랜드가 150개 이상이다', () {
      // T-013의 목표선. 사전이 실수로 잘려나가면 여기서 걸린다.
      expect(kBrandDictionary.length, greaterThanOrEqualTo(150));
    });
  });

  group('새 브랜드 매칭', () {
    // (입력 표기, 기대 정식 명칭, 기대 카테고리)
    const cases = <(String, String, CouponCategory)>[
      ('요아정 꿀조합 세트', '요거트아이스크림의정석', CouponCategory.cafe),
      ('MAMMOTH COFFEE 아이스아메리카노', '매머드커피', CouponCategory.cafe),
      ('컴포즈 커피 아메리카노', '컴포즈커피', CouponCategory.cafe),
      ('푸라닭 치킨 고추마요', '푸라닭', CouponCategory.chickenPizza),
      ('처갓집 양념치킨 순살', '처갓집양념치킨', CouponCategory.chickenPizza),
      ('60계 치킨 후라이드', '60계치킨', CouponCategory.chickenPizza),
      ('PAPA JOHNS 라지 피자', '파파존스', CouponCategory.chickenPizza),
      ('KRISPY KREME 더즌', '크리스피크림도넛', CouponCategory.bakery),
      ('성심당 튀김소보로', '성심당', CouponCategory.bakery),
      ('노티드 도넛 세트', '노티드', CouponCategory.bakery),
      ('신전 떡볶이 세트', '신전떡볶이', CouponCategory.dining),
      ('동대문엽기떡볶이 착한맛', '엽기떡볶이', CouponCategory.dining),
      ('한솥 도시락 치킨마요', '한솥도시락', CouponCategory.dining),
      ('ISAAC TOAST 햄치즈', '이삭토스트', CouponCategory.dining),
      ('쉑쉑버거 버거 세트', '쉐이크쉑', CouponCategory.dining),
      ('노브랜드 버거 세트', '노브랜드버거', CouponCategory.dining),
      ('컬쳐랜드 문화상품권 1만원', '문화상품권', CouponCategory.culture),
      ('NETFLIX 이용권', '넷플릭스', CouponCategory.culture),
      ('밀리의 서재 구독권', '밀리의서재', CouponCategory.culture),
      ('에버랜드 자유이용권', '에버랜드', CouponCategory.culture),
      ('마켓 컬리 적립금', '마켓컬리', CouponCategory.voucher),
      ('GS 칼텍스 주유권 5만원', 'GS칼텍스', CouponCategory.etc),
      ('구글플레이 기프트코드', '구글플레이기프트', CouponCategory.etc),
      ('다이소 모바일 상품권', '다이소', CouponCategory.etc),
      ('쿠팡 이츠 할인쿠폰', '쿠팡이츠', CouponCategory.etc),
    ];

    for (final (input, canonical, category) in cases) {
      test('$input → $canonical', () {
        final entry = matchBrand(input);
        expect(entry?.canonical, canonical);
        expect(entry?.category, category);
      });
    }

    test('겹치는 이름은 긴 쪽이 이긴다 — 굽네 vs 굽네치킨', () {
      expect(matchBrand('굽네치킨 고추바사삭')?.canonical, '굽네치킨');
    });

    test('겹치는 이름은 긴 쪽이 이긴다 — 쿠팡 vs 쿠팡이츠', () {
      expect(matchBrand('쿠팡이츠 배달쿠폰')?.canonical, '쿠팡이츠');
    });
  });

  group('새 발행사 판정', () {
    test('니콘내콘에서 산 쿠폰', () {
      final rule = detectIssuer('니콘내콘\n스타벅스\n아메리카노\n유효기간 2026.08.15');
      expect(rule?.name, '니콘내콘');
    });

    test('기프티스타 워터마크', () {
      final rule = detectIssuer('기프티스타 GIFTISTAR\nBBQ 황금올리브');
      expect(rule?.name, '기프티스타');
    });

    test('해피콘', () {
      final rule = detectIssuer('해피콘\n뚜레쥬르 케이크 교환권');
      expect(rule?.name, '해피콘');
    });

    test('발행사와 브랜드가 함께 있어도 브랜드 매칭이 흔들리지 않는다', () {
      const parser = CouponParser();
      final result = parser.parse(
        scanOf(['니콘내콘', '스타벅스', '아이스 카페 아메리카노 T', '유효기간 2026.08.15']),
        now: DateTime(2026, 7, 1),
      );

      expect(result.issuer, '니콘내콘');
      expect(result.brand, '스타벅스');
    });
  });
}
