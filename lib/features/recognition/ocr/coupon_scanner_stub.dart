import 'scan_types.dart';

/// 웹 검증 빌드용 스텁.
///
/// 인식을 흉내 내지 않는다. `isSupported == false`를 정직하게 돌려주고, UI는
/// "이 환경에서는 자동 인식을 쓸 수 없으니 직접 입력하세요"라는 안내를 띄운다.
/// 가짜 결과를 반환하면 파싱 로직의 실제 정확도를 오판하게 된다.
class PlatformCouponScanner implements CouponScanner, ScannerCapability {
  PlatformCouponScanner();

  @override
  bool get isSupported => false;

  @override
  Future<ScanResult> scan(String imagePath) async => const ScanResult.empty();

  @override
  Future<void> dispose() async {}
}
