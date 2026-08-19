import '../../../domain/model/coupon.dart';
import '../ocr/scan_types.dart';
import 'brand_dictionary.dart';
import 'issuer_rules.dart';

enum ParsedField { brand, productName, expiresAt, faceValue, kind, barcode }

/// 인식 결과를 사람이 확인·수정할 수 있는 형태로 담는다.
///
/// 신뢰도를 함께 들고 다니는 이유: 값이 있다고 조용히 저장해버리면 틀렸을 때
/// 사용자가 알아채지 못한다. 낮은 신뢰도 필드는 등록 폼에서 강조해 확인을 받는다.
class ParsedCoupon {
  const ParsedCoupon({
    this.brand,
    this.productName,
    this.expiresAt,
    this.faceValue,
    this.kind = CouponKind.exchange,
    this.category = CouponCategory.etc,
    this.barcode,
    this.barcodeFormat = BarcodeFormat.unknown,
    this.issuer,
    this.confidence = const {},
  });

  final String? brand;
  final String? productName;
  final DateTime? expiresAt;
  final int? faceValue;
  final CouponKind kind;
  final CouponCategory category;
  final String? barcode;
  final BarcodeFormat barcodeFormat;
  final String? issuer;

  /// 필드별 0.0~1.0 신뢰도. 없는 키는 "추출하지 못함".
  final Map<ParsedField, double> confidence;

  /// 사용자 확인 없이 넘어가도 되는 최소 신뢰도. 필드마다 다르다.
  ///
  /// **유효기간만 0.95로 유독 높다.** 이 값이 틀리면 알림이 엉뚱한 날에 오고,
  /// 사용자는 쿠폰을 그대로 소멸시킨다. 이 앱이 막으려는 바로 그 실패다.
  /// 실제로 이 기준을 넘는 경우는 "유효기간" 같은 라벨과 날짜가 한 줄에
  /// 함께 잡혔을 때뿐이고, 나머지는 전부 사용자 확인을 거친다.
  ///
  /// 브랜드·상품명은 틀려도 목록에서 눈으로 바로 알아채고 고칠 수 있어
  /// 상대적으로 낮게 둔다.
  static const Map<ParsedField, double> reviewThresholds = {
    ParsedField.brand: 0.8,
    ParsedField.productName: 0.7,
    ParsedField.expiresAt: 0.95,
    ParsedField.faceValue: 0.8,
    ParsedField.kind: 0.8,
    ParsedField.barcode: 0.9,
  };

  double confidenceOf(ParsedField field) => confidence[field] ?? 0;

  double thresholdFor(ParsedField field) => reviewThresholds[field] ?? 0.8;

  bool isLowConfidence(ParsedField field) =>
      confidenceOf(field) < thresholdFor(field);

  /// 사용자 확인 없이 넘어가도 될 만큼 잘 읽혔는가.
  bool get isReliable =>
      !isLowConfidence(ParsedField.brand) &&
      !isLowConfidence(ParsedField.expiresAt) &&
      (barcode?.isNotEmpty ?? false);

  /// 사용자가 확인해야 할 필드 목록.
  List<ParsedField> get fieldsNeedingReview => [
    for (final field in [
      ParsedField.brand,
      ParsedField.productName,
      ParsedField.expiresAt,
      if (kind == CouponKind.amount) ParsedField.faceValue,
    ])
      if (isLowConfidence(field)) field,
  ];

  ParsedCoupon copyWith({
    String? brand,
    String? productName,
    DateTime? expiresAt,
    int? faceValue,
    CouponKind? kind,
    CouponCategory? category,
    String? barcode,
    BarcodeFormat? barcodeFormat,
    String? issuer,
    Map<ParsedField, double>? confidence,
  }) => ParsedCoupon(
    brand: brand ?? this.brand,
    productName: productName ?? this.productName,
    expiresAt: expiresAt ?? this.expiresAt,
    faceValue: faceValue ?? this.faceValue,
    kind: kind ?? this.kind,
    category: category ?? this.category,
    barcode: barcode ?? this.barcode,
    barcodeFormat: barcodeFormat ?? this.barcodeFormat,
    issuer: issuer ?? this.issuer,
    confidence: confidence ?? this.confidence,
  );
}

/// 한국 기프티콘 이미지의 OCR 결과에서 필드를 뽑아낸다.
///
/// 순수 함수 집합이라 실기기 없이 테스트할 수 있다. 파싱 규칙을 늘릴 때는
/// 반드시 `test/unit/coupon_parser_test.dart`에 실제 문구 사례를 함께 넣는다.
class CouponParser {
  const CouponParser();

  ParsedCoupon parse(ScanResult scan, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final text = scan.text;
    if (text.isEmpty && scan.barcode == null) return const ParsedCoupon();

    final issuer = detectIssuer(text.fullText);
    final confidence = <ParsedField, double>{};

    // ── 브랜드 ──────────────────────────────────────────────────────────────
    final brandEntry = matchBrand(text.fullText);
    if (brandEntry != null) confidence[ParsedField.brand] = 0.9;

    // ── 유효기간 ────────────────────────────────────────────────────────────
    final expiry = _findExpiry(text, issuer, today);
    if (expiry != null) confidence[ParsedField.expiresAt] = expiry.confidence;

    // ── 금액·종류 ───────────────────────────────────────────────────────────
    final amount = _findFaceValue(text);
    final kind = _detectKind(text.fullText, amount?.value);
    confidence[ParsedField.kind] = 0.8;
    if (amount != null && kind == CouponKind.amount) {
      confidence[ParsedField.faceValue] = amount.confidence;
    }

    // ── 상품명 ──────────────────────────────────────────────────────────────
    final product = _findProductName(text, issuer, brandEntry);
    if (product != null) {
      confidence[ParsedField.productName] = product.confidence;
    }

    // ── 바코드 ──────────────────────────────────────────────────────────────
    final barcode = scan.barcode;
    if (barcode != null) confidence[ParsedField.barcode] = 1;

    return ParsedCoupon(
      brand: brandEntry?.canonical,
      productName: product?.value,
      expiresAt: expiry?.value,
      faceValue: kind == CouponKind.amount ? amount?.value : null,
      kind: kind,
      category: brandEntry?.category ?? CouponCategory.etc,
      barcode: barcode?.value,
      barcodeFormat: barcode?.format ?? BarcodeFormat.unknown,
      issuer: issuer?.name,
      confidence: confidence,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 유효기간
  // ───────────────────────────────────────────────────────────────────────────

  _Guess<DateTime>? _findExpiry(
    OcrResult text,
    IssuerRule? issuer,
    DateTime today,
  ) {
    final labels = <String>[...?issuer?.expiryLabels, ...kGenericExpiryLabels];

    // 1순위: 라벨과 같은 줄에 있는 날짜.
    for (final line in text.lines) {
      if (!_containsAnyLabel(line.text, labels)) continue;
      final date = _lastDateIn(line.text);
      if (date != null) return _Guess(date, 0.95);
    }

    // 2순위: 라벨 줄의 오른쪽 또는 바로 아래 줄. 표 형태 레이아웃 대응.
    for (var i = 0; i < text.lines.length; i++) {
      final line = text.lines[i];
      if (!_containsAnyLabel(line.text, labels)) continue;

      for (final other in text.lines) {
        if (identical(other, line)) continue;
        if (!other.isSameRowAs(line) || other.left <= line.left) continue;
        final date = _lastDateIn(other.text);
        if (date != null) return _Guess(date, 0.9);
      }
      if (i + 1 < text.lines.length) {
        final date = _lastDateIn(text.lines[i + 1].text);
        if (date != null) return _Guess(date, 0.8);
      }
    }

    // 3순위: 라벨을 못 찾았을 때. 이미지 안의 모든 날짜 중 가장 나중 것을 쓴다.
    // 기프티콘에는 발행일·주문일이 함께 찍히는데, 유효기간은 언제나 그보다 뒤다.
    final all = _allDates(text.fullText);
    if (all.isEmpty) return null;
    all.sort();
    final latest = all.last;

    // 이미 지난 날짜만 있으면 만료된 쿠폰일 수도, 발행일을 잘못 읽은 것일 수도
    // 있다. 신뢰도를 크게 낮춰 사용자 확인을 유도한다.
    final isPast = latest.isBefore(
      DateTime(today.year, today.month, today.day),
    );
    return _Guess(latest, isPast ? 0.3 : (all.length == 1 ? 0.6 : 0.45));
  }

  bool _containsAnyLabel(String text, List<String> labels) {
    final normalized = text.replaceAll(RegExp(r'\s'), '');
    return labels.any(
      (l) => normalized.contains(l.replaceAll(RegExp(r'\s'), '')),
    );
  }

  /// `2026.08.15` `2026-08-15` `2026/08/15` `2026년 8월 15일` `26.08.15`
  static final _datePattern = RegExp(
    r'(\d{2,4})\s*[.\-/년]\s*(\d{1,2})\s*[.\-/월]\s*(\d{1,2})\s*일?',
  );

  List<DateTime> _allDates(String text) {
    final result = <DateTime>[];
    for (final match in _datePattern.allMatches(text)) {
      final date = _toDate(match);
      if (date != null) result.add(date);
    }
    return result;
  }

  /// 한 줄에 `2026.05.01 ~ 2026.08.15`처럼 기간이 적힌 경우가 흔하다.
  /// 만료일은 언제나 뒤쪽 날짜다.
  DateTime? _lastDateIn(String text) {
    final dates = _allDates(text);
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.last;
  }

  DateTime? _toDate(RegExpMatch match) {
    var year = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final day = int.tryParse(match.group(3) ?? '');
    if (year == null || month == null || day == null) return null;

    // 두 자리 연도. 기프티콘 유효기간이 1900년대일 수는 없다.
    if (year < 100) year += 2000;
    if (year < 2000 || year > 2100) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;

    final date = DateTime(year, month, day);
    // DateTime은 2026-02-31을 3월로 넘겨버린다. 잘못 읽은 날짜를 걸러낸다.
    if (date.month != month || date.day != day) return null;
    return date;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 금액
  // ───────────────────────────────────────────────────────────────────────────

  /// `30,000원` `30000 원`
  static final _plainWon = RegExp(r'([0-9][0-9,]{2,})\s*원');

  /// `3만원` `1만 5천원` `5천원`
  static final _koreanWon = RegExp(
    r'(\d+)\s*만\s*(?:(\d+)\s*천)?\s*원?|(\d+)\s*천\s*원',
  );

  /// 할인 후 결제액이 액면가로 잡히는 것을 막는다.
  static final _amountNoise = RegExp(r'결제|할인|적립|배송|포인트|부가세');

  _Guess<int>? _findFaceValue(OcrResult text) {
    final candidates = <int>[];
    var sawLabeledAmount = false;

    for (final line
        in text.lines.isEmpty
            ? [
                OcrLine(
                  text: text.fullText,
                  top: 0,
                  left: 0,
                  height: 1,
                  width: 1,
                ),
              ]
            : text.lines) {
      if (_amountNoise.hasMatch(line.text)) continue;

      for (final match in _plainWon.allMatches(line.text)) {
        final value = int.tryParse(match.group(1)!.replaceAll(',', ''));
        if (value != null && value >= 100) {
          candidates.add(value);
          if (line.text.contains('금액권') || line.text.contains('상품권')) {
            sawLabeledAmount = true;
          }
        }
      }

      for (final match in _koreanWon.allMatches(line.text)) {
        final man = int.tryParse(match.group(1) ?? '');
        final cheon = int.tryParse(match.group(2) ?? '');
        final cheonOnly = int.tryParse(match.group(3) ?? '');
        var value = 0;
        if (man != null) value += man * 10000;
        if (cheon != null) value += cheon * 1000;
        if (cheonOnly != null) value += cheonOnly * 1000;
        if (value >= 100) {
          candidates.add(value);
          if (line.text.contains('금액권') || line.text.contains('상품권')) {
            sawLabeledAmount = true;
          }
        }
      }
    }

    if (candidates.isEmpty) return null;
    candidates.sort();
    // 액면가는 이미지에 찍힌 금액 중 가장 큰 값인 경우가 압도적이다.
    return _Guess(candidates.last, sawLabeledAmount ? 0.85 : 0.55);
  }

  CouponKind _detectKind(String fullText, int? amount) {
    final normalized = fullText.replaceAll(RegExp(r'\s'), '');
    if (normalized.contains('금액권') ||
        normalized.contains('상품권') ||
        normalized.contains('충전권')) {
      return CouponKind.amount;
    }
    if (normalized.contains('교환권')) return CouponKind.exchange;
    // 금액만 찍혀 있고 상품명이 없는 경우는 판단이 어렵다. 교환권이 훨씬 흔하므로
    // 교환권으로 두고, 사용자가 등록 폼에서 한 번의 탭으로 바꾸게 한다.
    return CouponKind.exchange;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 상품명
  // ───────────────────────────────────────────────────────────────────────────

  _Guess<String>? _findProductName(
    OcrResult text,
    IssuerRule? issuer,
    BrandEntry? brand,
  ) {
    final labels = [...?issuer?.productLabels, ...kGenericProductLabels];
    final noise = [...?issuer?.noiseLines, ...kGenericNoiseLines];

    // 1순위: "상품명" 라벨 뒤의 값.
    for (var i = 0; i < text.lines.length; i++) {
      final line = text.lines[i];
      if (!_containsAnyLabel(line.text, labels)) continue;

      final inline = _stripLabel(line.text, labels);
      if (_isUsableProductName(inline, noise)) return _Guess(inline, 0.9);

      if (i + 1 < text.lines.length) {
        final next = text.lines[i + 1].text.trim();
        if (_isUsableProductName(next, noise)) return _Guess(next, 0.8);
      }
    }

    // 2순위: 브랜드 줄 바로 아래. 기프티콘 이미지는 대개
    // [브랜드 로고] → [상품 이미지] → [상품명] → [유효기간] 순으로 쌓인다.
    if (brand != null) {
      final brandLineIndex = text.lines.indexWhere(
        (l) => brand.allForms.any(
          (f) => normalizeForMatch(l.text).contains(normalizeForMatch(f)),
        ),
      );
      if (brandLineIndex != -1) {
        for (var i = brandLineIndex + 1; i < text.lines.length; i++) {
          final candidate = text.lines[i].text.trim();
          if (_isUsableProductName(candidate, noise)) {
            return _Guess(candidate, 0.6);
          }
        }
      }
    }

    // 3순위: 가장 긴 "쓸 만한" 줄. 상품명은 보통 이미지에서 가장 긴 한글 문장이다.
    final fallback =
        text.lines
            .map((l) => l.text.trim())
            .where((t) => _isUsableProductName(t, noise))
            .toList()
          ..sort((a, b) => b.length.compareTo(a.length));
    if (fallback.isEmpty) return null;
    return _Guess(fallback.first, 0.4);
  }

  String _stripLabel(String line, List<String> labels) {
    var result = line;
    for (final label in labels) {
      final index = result.indexOf(label);
      if (index != -1) {
        result = result.substring(index + label.length);
        break;
      }
    }
    return result.replaceFirst(RegExp(r'^\s*[:：]\s*'), '').trim();
  }

  bool _isUsableProductName(String candidate, List<String> noise) {
    final trimmed = candidate.trim();
    if (trimmed.length < 2 || trimmed.length > 60) return false;
    if (noise.any(trimmed.contains)) return false;
    // 날짜·번호만 있는 줄은 상품명이 아니다.
    if (RegExp(r'^[\d\s.\-/:]+$').hasMatch(trimmed)) return false;
    if (_datePattern.hasMatch(trimmed)) return false;
    // 한글이나 영문이 최소한 두 글자는 있어야 한다.
    final letters = RegExp(r'[가-힣A-Za-z]').allMatches(trimmed).length;
    return letters >= 2;
  }
}

class _Guess<T> {
  const _Guess(this.value, this.confidence);
  final T value;
  final double confidence;
}
