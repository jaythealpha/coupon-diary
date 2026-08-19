/// 로컬 알림. 서버 푸시를 쓰지 않는다 — 서버 푸시는 쿠폰 정보가 기기 밖으로
/// 나가야 성립하기 때문이다 (AGENTS.md 2절).
library;

export 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_native.dart';
