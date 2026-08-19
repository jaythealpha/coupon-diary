import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../domain/model/coupon.dart' as domain;
import 'scan_types.dart';

/// ML Kit 온디바이스 인식.
///
/// 한글 스크립트 모델을 쓴다. 이 모델은 라틴 문자도 함께 인식하므로
/// "Americano T"처럼 섞인 상품명도 한 번에 읽힌다.
///
/// **네트워크를 쓰지 않는다.** ML Kit의 이 두 API는 전부 기기 내 추론이다.
class PlatformCouponScanner implements CouponScanner, ScannerCapability {
  PlatformCouponScanner();

  TextRecognizer? _recognizer;
  mlkit.BarcodeScanner? _barcodeScanner;

  @override
  bool get isSupported => true;

  @override
  Future<ScanResult> scan(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);

    final recognizer = _recognizer ??= TextRecognizer(
      script: TextRecognitionScript.korean,
    );
    final barcodeScanner = _barcodeScanner ??= mlkit.BarcodeScanner(
      formats: const [
        mlkit.BarcodeFormat.code128,
        mlkit.BarcodeFormat.ean13,
        mlkit.BarcodeFormat.qrCode,
        mlkit.BarcodeFormat.code39,
        mlkit.BarcodeFormat.itf,
      ],
    );

    // 텍스트와 바코드는 서로 독립이므로 동시에 돌린다.
    final results = await Future.wait([
      recognizer.processImage(input),
      barcodeScanner.processImage(input),
    ]);

    final recognized = results[0] as RecognizedText;
    final barcodes = results[1] as List<mlkit.Barcode>;

    return ScanResult(
      text: _toOcrResult(recognized),
      barcode: _pickBarcode(barcodes),
    );
  }

  OcrResult _toOcrResult(RecognizedText recognized) {
    final lines = <OcrLine>[];
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        final box = line.boundingBox;
        lines.add(
          OcrLine(
            text: line.text,
            top: box.top,
            left: box.left,
            height: box.height,
            width: box.width,
          ),
        );
      }
    }
    // 위에서 아래, 같은 높이면 왼쪽에서 오른쪽. 파서가 읽기 순서를 가정한다.
    lines.sort((a, b) {
      if (a.isSameRowAs(b)) return a.left.compareTo(b.left);
      return a.top.compareTo(b.top);
    });
    return OcrResult(fullText: recognized.text, lines: lines);
  }

  /// 기프티콘 이미지에는 바코드가 하나만 있는 게 보통이지만, 발행사 로고 옆
  /// 홍보용 QR이 함께 찍히는 경우가 있다. 교환에 쓰이는 쪽은 거의 항상
  /// 1D 바코드(CODE128/EAN13)이므로 그쪽을 우선한다.
  DetectedBarcode? _pickBarcode(List<mlkit.Barcode> barcodes) {
    if (barcodes.isEmpty) return null;

    mlkit.Barcode? best;
    for (final barcode in barcodes) {
      if ((barcode.rawValue ?? '').trim().isEmpty) continue;
      if (best == null) {
        best = barcode;
        continue;
      }
      if (_priority(barcode.format) > _priority(best.format)) best = barcode;
    }
    if (best == null) return null;

    return DetectedBarcode(
      value: best.rawValue!.trim(),
      format: _toDomainFormat(best.format),
    );
  }

  int _priority(mlkit.BarcodeFormat format) => switch (format) {
    mlkit.BarcodeFormat.code128 => 3,
    mlkit.BarcodeFormat.ean13 => 2,
    mlkit.BarcodeFormat.code39 || mlkit.BarcodeFormat.itf => 1,
    _ => 0,
  };

  domain.BarcodeFormat _toDomainFormat(mlkit.BarcodeFormat format) =>
      switch (format) {
        mlkit.BarcodeFormat.code128 => domain.BarcodeFormat.code128,
        mlkit.BarcodeFormat.ean13 => domain.BarcodeFormat.ean13,
        mlkit.BarcodeFormat.qrCode => domain.BarcodeFormat.qr,
        _ => domain.BarcodeFormat.unknown,
      };

  @override
  Future<void> dispose() async {
    await _recognizer?.close();
    await _barcodeScanner?.close();
    _recognizer = null;
    _barcodeScanner = null;
  }
}
