/// 발행사별 인식 규칙.
///
/// 발행사를 먼저 판정하면 그 다음 필드 추출이 훨씬 정확해진다. 발행사마다
/// 라벨 문구가 고정되어 있기 때문이다 — 카카오는 "유효기간", 기프티쇼는
/// "사용기한", SK는 "교환기한"을 쓰는 식.
///
/// 규칙 확충은 Codex 담당 (docs/TASKS.md T-012).
library;

class IssuerRule {
  const IssuerRule({
    required this.name,
    required this.fingerprints,
    this.expiryLabels = const [],
    this.productLabels = const [],
    this.noiseLines = const [],
  });

  /// 저장에 쓰는 발행사 이름.
  final String name;

  /// 이 문구들 중 하나라도 이미지에 있으면 해당 발행사로 본다.
  final List<String> fingerprints;

  /// 유효기간 값 앞에 붙는 라벨. 앞쪽일수록 우선순위가 높다.
  final List<String> expiryLabels;

  /// 상품명 값 앞에 붙는 라벨.
  final List<String> productLabels;

  /// 상품명 후보에서 걸러야 할 줄. 발행사 안내 문구가 상품명으로 잡히는 것을 막는다.
  final List<String> noiseLines;
}

const List<IssuerRule> kIssuerRules = [
  IssuerRule(
    name: '카카오톡 선물하기',
    fingerprints: ['카카오톡 선물하기', '카카오톡선물하기', 'kakaotalk', '선물하기', 'kakao'],
    expiryLabels: ['유효기간', '사용기한'],
    productLabels: ['상품명', '교환처'],
    noiseLines: ['선물하기', '주문번호', '고객센터', '카카오톡', '선물한 사람', '받는 사람'],
  ),
  IssuerRule(
    name: '기프티쇼',
    fingerprints: ['기프티쇼', 'GIFTISHOW', 'giftishow', '쿠프마케팅'],
    expiryLabels: ['유효기간', '사용기한', '교환기한'],
    productLabels: ['상품명', '교환처'],
    noiseLines: ['기프티쇼', '고객센터', '쿠폰번호', '주문번호'],
  ),
  IssuerRule(
    name: 'SK 기프티콘',
    fingerprints: ['기프티콘', 'SK플래닛', 'SK PLANET', '시럽', 'SYRUP'],
    expiryLabels: ['유효기간', '교환기한'],
    productLabels: ['상품명'],
    noiseLines: ['기프티콘', 'SK플래닛', '고객센터'],
  ),
  IssuerRule(
    name: '스마일콘',
    fingerprints: ['스마일콘', 'SMILECON', '지마켓', 'GMARKET', '옥션'],
    expiryLabels: ['유효기간', '사용기한'],
    productLabels: ['상품명'],
    noiseLines: ['스마일콘', '고객센터'],
  ),
  IssuerRule(
    name: '네이버',
    fingerprints: ['네이버', 'NAVER', '네이버페이', '스마트스토어'],
    expiryLabels: ['유효기간', '사용기한'],
    productLabels: ['상품명'],
    noiseLines: ['네이버', '고객센터', '주문번호'],
  ),
  IssuerRule(
    name: '쿠팡',
    fingerprints: ['쿠팡', 'COUPANG'],
    expiryLabels: ['유효기간', '사용기한'],
    productLabels: ['상품명'],
    noiseLines: ['쿠팡', '고객센터', '주문번호'],
  ),
  IssuerRule(
    name: '11번가',
    fingerprints: ['11번가', '11ST', '십일번가'],
    expiryLabels: ['유효기간', '사용기한'],
    productLabels: ['상품명'],
    noiseLines: ['11번가', '고객센터'],
  ),
  IssuerRule(
    name: '해피콘',
    fingerprints: ['해피콘', 'HAPPYCON', '해피머니'],
    expiryLabels: ['유효기간', '사용기한'],
    productLabels: ['상품명', '교환처'],
    noiseLines: ['해피콘', '해피머니', '고객센터'],
  ),
  // 거래 마켓에서 산 기프티콘. 마켓 워터마크가 함께 찍혀 들어온다.
  IssuerRule(
    name: '니콘내콘',
    fingerprints: ['니콘내콘', 'NCONNCON'],
    expiryLabels: ['유효기간', '사용기한'],
    productLabels: ['상품명'],
    noiseLines: ['니콘내콘', '고객센터', '구매일'],
  ),
  IssuerRule(
    name: '기프티스타',
    fingerprints: ['기프티스타', 'GIFTISTAR'],
    expiryLabels: ['유효기간', '사용기한'],
    productLabels: ['상품명'],
    noiseLines: ['기프티스타', '고객센터', '구매일'],
  ),
  IssuerRule(
    name: '팔라고',
    fingerprints: ['팔라고', 'PALAGO'],
    expiryLabels: ['유효기간', '사용기한'],
    productLabels: ['상품명'],
    noiseLines: ['팔라고', '고객센터'],
  ),
];

/// 어떤 발행사에서든 통하는 기본 라벨. 발행사를 판정하지 못했을 때 쓴다.
const List<String> kGenericExpiryLabels = [
  '유효기간',
  '사용기한',
  '교환기한',
  '유효 기간',
  '사용 기한',
  '기한',
];

const List<String> kGenericProductLabels = ['상품명', '교환처', '품명'];

/// 상품명·브랜드 후보에서 항상 제외할 줄.
const List<String> kGenericNoiseLines = [
  '바코드',
  '쿠폰번호',
  '교환번호',
  '주문번호',
  '고객센터',
  '유의사항',
  '사용안내',
  '결제금액',
  '주문일시',
  '보내는',
  '받는',
  '메시지',
];

/// 이미지 전체 텍스트에서 발행사를 판정한다.
IssuerRule? detectIssuer(String fullText) {
  final haystack = fullText.toUpperCase().replaceAll(RegExp(r'\s'), '');
  IssuerRule? best;
  var bestLength = 0;

  for (final rule in kIssuerRules) {
    for (final print in rule.fingerprints) {
      final needle = print.toUpperCase().replaceAll(RegExp(r'\s'), '');
      if (needle.isEmpty || !haystack.contains(needle)) continue;
      // "기프티콘"은 SK와 일반 명사 양쪽에 걸리므로, 더 특징적인(긴) 지문이
      // 잡힌 발행사를 우선한다.
      if (needle.length > bestLength) {
        best = rule;
        bestLength = needle.length;
      }
    }
  }
  return best;
}
