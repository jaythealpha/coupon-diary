/// 이미지 헤더만 읽어 형식과 크기를 알아낸다.
///
/// 디코딩 라이브러리를 쓰지 않는 이유:
/// 1. 파일 전체를 메모리에 올리지 않아도 된다. 앞부분 몇 KB면 충분하다.
/// 2. Flutter 엔진 없이 단위 테스트할 수 있다. 실제 쿠폰 이미지를 fixture로
///    두지 않고 합성 바이트로 검증할 수 있다.
library;

import 'dart:typed_data';

enum ImageFormat {
  jpeg('JPEG'),
  png('PNG'),
  webp('WebP'),
  heic('HEIC');

  const ImageFormat(this.label);
  final String label;
}

/// 헤더에서 읽어낸 정보. [width]/[height]는 알아내지 못했으면 null이다.
///
/// HEIC는 크기 정보가 파일 뒤쪽 박스에 있을 수 있어 헤더만으로는 못 읽는
/// 경우가 있다. 그때도 형식은 확실하므로 크기만 null로 둔다.
class ProbedImage {
  const ProbedImage({required this.format, this.width, this.height});

  final ImageFormat format;
  final int? width;
  final int? height;

  bool get hasDimensions => width != null && height != null;
}

abstract final class ImageProbe {
  /// 헤더 바이트에서 이미지 정보를 뽑는다. 알아볼 수 없으면 null.
  ///
  /// null은 "지원하지 않는 형식"과 "손상된 파일"을 구분하지 않는다.
  /// 사용자 입장에서는 둘 다 "이 이미지는 쓸 수 없다"이고, 구분해서
  /// 알려줘도 할 수 있는 일이 같기 때문이다.
  static ProbedImage? probe(Uint8List bytes) {
    if (_startsWith(bytes, const [
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
    ])) {
      return _png(bytes);
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return _jpeg(bytes);
    }
    if (_matches(bytes, 0, 'RIFF') && _matches(bytes, 8, 'WEBP')) {
      return _webp(bytes);
    }
    if (_matches(bytes, 4, 'ftyp') && _isHeicBrand(bytes)) {
      return ProbedImage(
        format: ImageFormat.heic,
        width: _heicDimension(bytes)?.$1,
        height: _heicDimension(bytes)?.$2,
      );
    }
    return null;
  }

  // ── PNG ───────────────────────────────────────────────────────────────────
  static ProbedImage? _png(Uint8List b) {
    // 시그니처(8) + 길이(4) + 'IHDR'(4) 다음이 width/height.
    if (b.length < 24 || !_matches(b, 12, 'IHDR')) return null;
    final width = _be32(b, 16);
    final height = _be32(b, 20);
    if (width <= 0 || height <= 0) return null;
    return ProbedImage(format: ImageFormat.png, width: width, height: height);
  }

  // ── JPEG ──────────────────────────────────────────────────────────────────
  static ProbedImage? _jpeg(Uint8List b) {
    var offset = 2;
    while (offset + 9 < b.length) {
      if (b[offset] != 0xFF) {
        offset++; // 세그먼트 사이 패딩. 다음 마커를 찾는다.
        continue;
      }
      final marker = b[offset + 1];

      // 페이로드가 없는 마커들.
      if (marker == 0xD8 ||
          marker == 0x01 ||
          (marker >= 0xD0 && marker <= 0xD7)) {
        offset += 2;
        continue;
      }
      if (marker == 0xD9 || marker == 0xDA) break; // 이미지 데이터 시작

      final segmentLength = _be16(b, offset + 2);
      if (segmentLength < 2) return null; // 손상

      if (_isStartOfFrame(marker)) {
        final height = _be16(b, offset + 5);
        final width = _be16(b, offset + 7);
        if (width <= 0 || height <= 0) return null;
        return ProbedImage(
          format: ImageFormat.jpeg,
          width: width,
          height: height,
        );
      }
      offset += 2 + segmentLength;
    }
    // 헤더는 JPEG인데 SOF를 못 찾았다. 크기를 모르는 채로 형식만 알린다.
    return const ProbedImage(format: ImageFormat.jpeg);
  }

  /// SOF0~SOF15 중 실제 프레임 크기를 담는 마커. DHT(0xC4)·JPG(0xC8)·DAC(0xCC)는 제외.
  static bool _isStartOfFrame(int marker) =>
      marker >= 0xC0 &&
      marker <= 0xCF &&
      marker != 0xC4 &&
      marker != 0xC8 &&
      marker != 0xCC;

  // ── WebP ──────────────────────────────────────────────────────────────────
  static ProbedImage? _webp(Uint8List b) {
    if (b.length < 30) return null;

    if (_matches(b, 12, 'VP8 ')) {
      // 손실 압축: 3바이트 프레임 태그 + 0x9D 0x01 0x2A 동기 코드 다음.
      if (b.length < 30 || b[23] != 0x9D || b[24] != 0x01 || b[25] != 0x2A) {
        return null;
      }
      return ProbedImage(
        format: ImageFormat.webp,
        width: _le16(b, 26) & 0x3FFF,
        height: _le16(b, 28) & 0x3FFF,
      );
    }
    if (_matches(b, 12, 'VP8L')) {
      final bits = _le32(b, 21);
      return ProbedImage(
        format: ImageFormat.webp,
        width: (bits & 0x3FFF) + 1,
        height: ((bits >> 14) & 0x3FFF) + 1,
      );
    }
    if (_matches(b, 12, 'VP8X')) {
      return ProbedImage(
        format: ImageFormat.webp,
        width: _le24(b, 24) + 1,
        height: _le24(b, 27) + 1,
      );
    }
    return null;
  }

  // ── HEIC ──────────────────────────────────────────────────────────────────
  static const _heicBrands = {
    'heic',
    'heix',
    'hevc',
    'hevx',
    'heim',
    'heis',
    'mif1',
    'msf1',
  };

  static bool _isHeicBrand(Uint8List b) {
    if (b.length < 12) return false;
    return _heicBrands.contains(String.fromCharCodes(b.sublist(8, 12)));
  }

  /// `ispe` 박스에서 크기를 찾는다. 박스 순서가 파일마다 달라 정식 파싱 대신
  /// 헤더 범위를 훑는다. 못 찾으면 null이고, 그때는 크기 검사를 건너뛴다.
  static (int, int)? _heicDimension(Uint8List b) {
    for (var i = 0; i + 20 <= b.length; i++) {
      if (b[i] != 0x69 ||
          b[i + 1] != 0x73 ||
          b[i + 2] != 0x70 ||
          b[i + 3] != 0x65) {
        continue; // 'ispe'
      }
      // 'ispe' + version/flags(4) + width(4) + height(4)
      final width = _be32(b, i + 8);
      final height = _be32(b, i + 12);
      if (width > 0 && height > 0) return (width, height);
    }
    return null;
  }

  // ── 바이트 읽기 헬퍼 ───────────────────────────────────────────────────────
  static bool _startsWith(Uint8List b, List<int> prefix) {
    if (b.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (b[i] != prefix[i]) return false;
    }
    return true;
  }

  static bool _matches(Uint8List b, int offset, String ascii) {
    if (b.length < offset + ascii.length) return false;
    for (var i = 0; i < ascii.length; i++) {
      if (b[offset + i] != ascii.codeUnitAt(i)) return false;
    }
    return true;
  }

  static int _be16(Uint8List b, int o) => (b[o] << 8) | b[o + 1];

  static int _be32(Uint8List b, int o) =>
      (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3];

  static int _le16(Uint8List b, int o) => b[o] | (b[o + 1] << 8);

  static int _le24(Uint8List b, int o) =>
      b[o] | (b[o + 1] << 8) | (b[o + 2] << 16);

  static int _le32(Uint8List b, int o) =>
      b[o] | (b[o + 1] << 8) | (b[o + 2] << 16) | (b[o + 3] << 24);
}
