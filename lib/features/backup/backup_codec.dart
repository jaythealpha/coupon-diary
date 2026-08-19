/// 암호화 백업 파일의 인코딩·디코딩.
///
/// 설계 근거 (docs/01-market-research.md P7):
/// - 백업은 **사용자가 명시적으로 실행할 때만** 만들어진다. 자동 업로드 없음.
/// - 파일은 사용자 소유 저장소(iCloud/Drive/파일앱)로 나간다. 우리 서버는 없다.
/// - 바코드가 통째로 담기므로 **반드시 암호화**한다. 평문 내보내기는 제공하지 않는다.
///
/// 형식 (버전 1):
/// ```
/// magic(8) 'CPDBAK01' | salt(16) | nonce(12) | ciphertext | mac(16)
/// ```
/// 키: PBKDF2-HMAC-SHA256(암호, salt, 210k회) → AES-256-GCM.
/// 반복 횟수는 OWASP 2023 권장값. 기기에서 수백 ms 수준이라 백업 빈도(수동,
/// 가끔)에는 충분히 감당된다.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../data/coupon_json.dart';
import '../../domain/model/coupon.dart';

/// 백업에 담기는 내용 전체.
class BackupPayload {
  const BackupPayload({required this.coupons, required this.usage});

  final List<Coupon> coupons;
  final List<UsageEntry> usage;
}

/// 복호화 실패의 이유. 사용자 안내가 달라진다.
enum BackupDecodeError {
  /// 이 앱의 백업 파일이 아니다.
  notABackup('쿠폰다이어리 백업 파일이 아닙니다. 파일을 다시 확인해주세요.'),

  /// 암호가 틀렸거나 파일이 손상됐다. GCM 특성상 둘을 구분할 수 없다.
  wrongPasswordOrCorrupted('암호가 틀렸거나 파일이 손상되었습니다. 암호를 다시 확인해주세요.'),

  /// 지금 앱보다 새로운 형식. 앱 업데이트가 필요하다.
  newerVersion('이 백업은 더 새로운 버전의 앱에서 만들어졌습니다. 앱을 업데이트한 뒤 다시 시도해주세요.');

  const BackupDecodeError(this.message);
  final String message;
}

sealed class BackupDecodeResult {
  const BackupDecodeResult();
}

final class BackupDecoded extends BackupDecodeResult {
  const BackupDecoded(this.payload);
  final BackupPayload payload;
}

final class BackupDecodeFailed extends BackupDecodeResult {
  const BackupDecodeFailed(this.error);
  final BackupDecodeError error;
}

class BackupCodec {
  BackupCodec({Pbkdf2? kdf})
    : _kdf = kdf ?? Pbkdf2.hmacSha256(iterations: 210000, bits: 256);

  static const _magic = 'CPDBAK01';
  static const _saltLength = 16;
  static const _nonceLength = 12;

  final Pbkdf2 _kdf;
  final _cipher = AesGcm.with256bits();

  Future<Uint8List> encode(BackupPayload payload, String password) async {
    final random = Random.secure();
    final saltBytes = Uint8List.fromList(
      List.generate(_saltLength, (_) => random.nextInt(256)),
    );

    final secretKey = await _deriveKey(password, saltBytes);
    final nonce = _cipher.newNonce();

    final clearText = utf8.encode(jsonEncode(_toJson(payload)));
    final box = await _cipher.encrypt(
      clearText,
      secretKey: secretKey,
      nonce: nonce,
    );

    final builder = BytesBuilder()
      ..add(ascii.encode(_magic))
      ..add(saltBytes)
      ..add(box.nonce)
      ..add(box.cipherText)
      ..add(box.mac.bytes);
    return builder.toBytes();
  }

  Future<BackupDecodeResult> decode(Uint8List bytes, String password) async {
    const headerLength = 8 + _saltLength + _nonceLength;
    const macLength = 16;
    if (bytes.length < headerLength + macLength) {
      return const BackupDecodeFailed(BackupDecodeError.notABackup);
    }

    final magic = ascii.decode(bytes.sublist(0, 8), allowInvalid: true);
    if (!magic.startsWith('CPDBAK')) {
      return const BackupDecodeFailed(BackupDecodeError.notABackup);
    }
    if (magic != _magic) {
      // 매직은 맞는데 버전이 다르다. 형식을 모르니 앱 업데이트를 안내한다.
      return const BackupDecodeFailed(BackupDecodeError.newerVersion);
    }

    final salt = bytes.sublist(8, 8 + _saltLength);
    final nonce = bytes.sublist(8 + _saltLength, headerLength);
    final cipherText = bytes.sublist(headerLength, bytes.length - macLength);
    final mac = bytes.sublist(bytes.length - macLength);

    final secretKey = await _deriveKey(password, salt);
    try {
      final clearText = await _cipher.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: secretKey,
      );
      final json = jsonDecode(utf8.decode(clearText)) as Map<String, dynamic>;
      return BackupDecoded(_fromJson(json));
    } on SecretBoxAuthenticationError {
      return const BackupDecodeFailed(
        BackupDecodeError.wrongPasswordOrCorrupted,
      );
    } on FormatException {
      return const BackupDecodeFailed(
        BackupDecodeError.wrongPasswordOrCorrupted,
      );
    }
  }

  Future<SecretKey> _deriveKey(String password, List<int> salt) {
    return _kdf.deriveKeyFromPassword(password: password, nonce: salt);
  }

  // ── 직렬화 ────────────────────────────────────────────────────────────────
  // 필드 매핑은 lib/data/coupon_json.dart 한 곳에 있다. 웹 체험판 저장과
  // 형식을 공유하므로 여기서 따로 필드를 추가하면 안 된다.

  Map<String, dynamic> _toJson(BackupPayload payload) => {
    'version': 1,
    'coupons': [for (final c in payload.coupons) couponToJson(c)],
    'usage': [for (final u in payload.usage) usageToJson(u)],
  };

  BackupPayload _fromJson(Map<String, dynamic> json) => BackupPayload(
    coupons: [
      for (final raw in (json['coupons'] as List? ?? const []))
        if (couponFromJson(raw) case final Coupon c) c,
    ],
    usage: [
      for (final raw in (json['usage'] as List? ?? const []))
        if (usageFromJson(raw) case final UsageEntry u) u,
    ],
  );
}
