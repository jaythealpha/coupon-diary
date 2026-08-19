import '../../../domain/model/coupon.dart';

/// OCR이 읽어낸 한 줄. 위치를 함께 들고 다니는 이유는, 한국 기프티콘이
/// "라벨(유효기간) / 값(2026.08.15)"을 좌우 또는 상하로 나눠 배치하는 경우가
/// 많아서 텍스트만으로는 값을 라벨에 붙일 수 없기 때문이다.
class OcrLine {
  const OcrLine({
    required this.text,
    required this.top,
    required this.left,
    required this.height,
    required this.width,
  });

  final String text;
  final double top;
  final double left;
  final double height;
  final double width;

  double get bottom => top + height;
  double get centerY => top + height / 2;

  /// 같은 행으로 볼 수 있는가 (라벨-값 좌우 배치 판정용).
  bool isSameRowAs(OcrLine other) {
    final tolerance = (height + other.height) / 4;
    return (centerY - other.centerY).abs() <= tolerance;
  }
}

class OcrResult {
  const OcrResult({required this.fullText, required this.lines});

  const OcrResult.empty() : fullText = '', lines = const [];

  final String fullText;
  final List<OcrLine> lines;

  bool get isEmpty => fullText.trim().isEmpty;
}

class DetectedBarcode {
  const DetectedBarcode({required this.value, required this.format});

  final String value;
  final BarcodeFormat format;
}

/// 이미지 한 장을 훑은 결과.
class ScanResult {
  const ScanResult({required this.text, this.barcode});

  const ScanResult.empty() : text = const OcrResult.empty(), barcode = null;

  final OcrResult text;
  final DetectedBarcode? barcode;
}

/// 이미지에서 텍스트와 바코드를 읽는다. 구현은 전부 **온디바이스**여야 한다.
abstract interface class CouponScanner {
  Future<ScanResult> scan(String imagePath);
  Future<void> dispose();
}

/// 이 기기에서 실제 인식이 가능한지. 웹 검증 빌드에서는 false.
abstract interface class ScannerCapability {
  bool get isSupported;
}
