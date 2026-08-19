/// 플랫폼별 스캐너 구현 선택.
///
/// 네이티브에서는 ML Kit 온디바이스 인식을, 웹(UI 검증 빌드)에서는 스텁을 쓴다.
/// 이미지가 기기 밖으로 나가지 않는다는 원칙(AGENTS.md 2절)은 두 구현 모두에서
/// 지켜진다 — 어느 쪽도 네트워크를 쓰지 않는다.
library;

export 'coupon_scanner_stub.dart'
    if (dart.library.io) 'coupon_scanner_mlkit.dart';
