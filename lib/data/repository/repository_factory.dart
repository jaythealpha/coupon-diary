/// 플랫폼에 맞는 [CouponRepository] 구현을 고른다.
///
/// 웹에서는 Drift/SQLite를 쓰지 않는다. 웹 빌드는 UI 검증 전용 경로이고,
/// 이 조건부 export 덕분에 `flutter build web`이 네이티브 플러그인 없이도
/// 항상 통과한다 (docs/02-architecture.md 참고).
library;

export 'factory_web.dart' if (dart.library.io) 'factory_native.dart';
