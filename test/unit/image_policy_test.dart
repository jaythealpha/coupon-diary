import 'dart:typed_data';

import 'package:coupon_diary/features/recognition/image_policy.dart';
import 'package:coupon_diary/features/recognition/image_probe.dart';
import 'package:flutter_test/flutter_test.dart';

/// 합성 헤더로만 검증한다. 실제 쿠폰 이미지를 저장소에 두지 않기 위해서다 —
/// 테스트 fixture라도 바코드가 담긴 이미지는 저장소에 들어가면 안 된다.

Uint8List _pad(List<int> bytes, {int to = 64}) {
  final out = Uint8List(bytes.length < to ? to : bytes.length);
  out.setRange(0, bytes.length, bytes);
  return out;
}

List<int> _be32(int v) => [
  (v >> 24) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 8) & 0xFF,
  v & 0xFF,
];
List<int> _be16(int v) => [(v >> 8) & 0xFF, v & 0xFF];
List<int> _le16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
List<int> _le24(int v) => [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF];

Uint8List pngHeader(int width, int height) => _pad([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // 시그니처
  ..._be32(13), ...'IHDR'.codeUnits,
  ..._be32(width), ..._be32(height),
  8, 6, 0, 0, 0,
]);

Uint8List jpegHeader(int width, int height) => _pad([
  0xFF, 0xD8, // SOI
  0xFF, 0xC0, // SOF0
  ..._be16(17), // 세그먼트 길이
  8, // 정밀도
  ..._be16(height), ..._be16(width),
  3,
]);

/// APP0 세그먼트를 건너뛰어야 SOF에 닿는 실제 카메라 파일에 가까운 형태.
Uint8List jpegWithApp0(int width, int height) => _pad([
  0xFF,
  0xD8,
  0xFF,
  0xE0,
  ..._be16(16),
  ...'JFIF'.codeUnits,
  0,
  1,
  1,
  0,
  0,
  1,
  0,
  1,
  0,
  0,
  0xFF,
  0xC0,
  ..._be16(17),
  8,
  ..._be16(height),
  ..._be16(width),
  3,
]);

Uint8List webpLossy(int width, int height) => _pad([
  ...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits,
  ...'VP8 '.codeUnits, 0, 0, 0, 0,
  0, 0, 0, // 프레임 태그
  0x9D, 0x01, 0x2A, // 동기 코드
  ..._le16(width), ..._le16(height),
]);

Uint8List webpLossless(int width, int height) {
  final bits = (width - 1) | ((height - 1) << 14);
  return _pad([
    ...'RIFF'.codeUnits,
    0,
    0,
    0,
    0,
    ...'WEBP'.codeUnits,
    ...'VP8L'.codeUnits,
    0,
    0,
    0,
    0,
    0x2F,
    bits & 0xFF,
    (bits >> 8) & 0xFF,
    (bits >> 16) & 0xFF,
    (bits >> 24) & 0xFF,
  ]);
}

Uint8List webpExtended(int width, int height) => _pad([
  ...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits,
  ...'VP8X'.codeUnits, 0, 0, 0, 0,
  0, 0, 0, 0, // 플래그
  ..._le24(width - 1), ..._le24(height - 1),
]);

Uint8List heicHeader({int? width, int? height}) => _pad([
  ..._be32(24),
  ...'ftyp'.codeUnits,
  ...'heic'.codeUnits,
  ...'heic'.codeUnits,
  ...'mif1'.codeUnits,
  if (width != null && height != null) ...[
    ..._be32(20),
    ...'ispe'.codeUnits,
    0,
    0,
    0,
    0,
    ..._be32(width),
    ..._be32(height),
  ],
]);

void main() {
  const policy = CouponImagePolicy();

  ImageInspection inspect(Uint8List header, {int? bytes}) =>
      policy.inspect(byteLength: bytes ?? 300 * 1024, header: header);

  group('형식 판정', () {
    test('PNG 헤더에서 형식과 크기를 읽는다', () {
      final probed = ImageProbe.probe(pngHeader(1080, 1920))!;
      expect(probed.format, ImageFormat.png);
      expect(probed.width, 1080);
      expect(probed.height, 1920);
    });

    test('JPEG SOF0에서 크기를 읽는다', () {
      final probed = ImageProbe.probe(jpegHeader(828, 1792))!;
      expect(probed.format, ImageFormat.jpeg);
      expect(probed.width, 828);
      expect(probed.height, 1792);
    });

    test('JPEG는 APP0 세그먼트를 건너뛰고 SOF를 찾는다', () {
      final probed = ImageProbe.probe(jpegWithApp0(750, 1334))!;
      expect(probed.width, 750);
      expect(probed.height, 1334);
    });

    test('WebP 손실 압축 크기를 읽는다', () {
      final probed = ImageProbe.probe(webpLossy(640, 480))!;
      expect(probed.format, ImageFormat.webp);
      expect(probed.width, 640);
      expect(probed.height, 480);
    });

    test('WebP 무손실 압축 크기를 읽는다', () {
      final probed = ImageProbe.probe(webpLossless(500, 700))!;
      expect(probed.width, 500);
      expect(probed.height, 700);
    });

    test('WebP 확장 포맷 크기를 읽는다', () {
      final probed = ImageProbe.probe(webpExtended(1200, 900))!;
      expect(probed.width, 1200);
      expect(probed.height, 900);
    });

    test('HEIC는 ispe 박스에서 크기를 읽는다', () {
      final probed = ImageProbe.probe(heicHeader(width: 3024, height: 4032))!;
      expect(probed.format, ImageFormat.heic);
      expect(probed.width, 3024);
      expect(probed.height, 4032);
    });

    test('HEIC 크기를 못 찾아도 형식은 알아낸다', () {
      final probed = ImageProbe.probe(heicHeader())!;
      expect(probed.format, ImageFormat.heic);
      expect(probed.hasDimensions, isFalse);
    });

    test('알 수 없는 바이트는 null', () {
      expect(ImageProbe.probe(_pad([0x00, 0x01, 0x02, 0x03])), isNull);
    });
  });

  group('정책 통과', () {
    test('일반적인 기프티콘 캡처를 받아들인다', () {
      final result = inspect(pngHeader(1080, 1920));
      expect(result, isA<ImageAccepted>());
      expect((result as ImageAccepted).format, ImageFormat.png);
      expect(result.width, 1080);
    });

    test('크기를 모르는 HEIC도 형식이 확실하면 통과시킨다', () {
      // 아이폰 기본 촬영 사진을 놓치지 않기 위한 의도적인 완화.
      expect(inspect(heicHeader()), isA<ImageAccepted>());
    });

    test('경계값(최소 변, 최대 변)은 통과한다', () {
      expect(
        inspect(pngHeader(CouponImagePolicy.minSide, 1000)),
        isA<ImageAccepted>(),
      );
      expect(
        inspect(pngHeader(1000, CouponImagePolicy.maxSide)),
        isA<ImageAccepted>(),
      );
    });

    test('용량 상한 정확히 같으면 통과한다', () {
      expect(
        inspect(pngHeader(1080, 1920), bytes: CouponImagePolicy.maxBytes),
        isA<ImageAccepted>(),
      );
    });
  });

  group('정책 반려', () {
    test('지원하지 않는 형식', () {
      // GIF. 기프티콘 이미지로 쓰이지 않고 ML Kit 인식 대상도 아니다.
      final result = inspect(_pad('GIF89a'.codeUnits));
      expect(result, isA<ImageRejected>());
      expect(
        (result as ImageRejected).reason,
        ImageRejection.unsupportedFormat,
      );
    });

    test('손상된 PNG — IHDR가 없다', () {
      final broken = pngHeader(100, 100);
      broken[12] = 0x00; // 'IHDR' 훼손
      final result = inspect(broken);
      expect(
        (result as ImageRejected).reason,
        ImageRejection.unsupportedFormat,
      );
    });

    test('크기가 0인 PNG', () {
      final result = inspect(pngHeader(0, 0));
      expect(
        (result as ImageRejected).reason,
        ImageRejection.unsupportedFormat,
      );
    });

    test('빈 파일', () {
      final result = inspect(Uint8List(0), bytes: 0);
      expect((result as ImageRejected).reason, ImageRejection.empty);
    });

    test('용량 초과', () {
      final result = inspect(
        pngHeader(1080, 1920),
        bytes: CouponImagePolicy.maxBytes + 1,
      );
      expect((result as ImageRejected).reason, ImageRejection.tooLarge);
    });

    test('너무 작은 이미지', () {
      final result = inspect(pngHeader(64, 64));
      expect((result as ImageRejected).reason, ImageRejection.tooSmall);
      expect(result.message, contains('${CouponImagePolicy.minSide}px'));
    });

    test('한 변만 작아도 반려한다', () {
      final result = inspect(pngHeader(1920, 100));
      expect((result as ImageRejected).reason, ImageRejection.tooSmall);
    });

    test('해상도 초과 — 파노라마', () {
      final result = inspect(pngHeader(CouponImagePolicy.maxSide + 1, 2000));
      expect((result as ImageRejected).reason, ImageRejection.tooManyPixels);
    });
  });

  group('오류 문구', () {
    test('모든 반려 사유에 해결 방법이 담긴다', () {
      for (final reason in ImageRejection.values) {
        final message = policy.messageFor(reason);
        expect(message, isNotEmpty);
        // "오류가 발생했습니다"로 끝나지 않고 다음 행동을 알려줘야 한다.
        expect(
          message.length,
          greaterThan(20),
          reason: '$reason 문구가 원인만 말하고 해결 방법이 없다',
        );
      }
    });
  });
}
