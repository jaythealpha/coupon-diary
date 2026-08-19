/// 사용 화면에서만 화면 밝기를 최대로 올린다.
///
/// 매장 바코드 스캐너는 어두운 화면을 잘 못 읽는다. 사용자가 설정에서 밝기를
/// 직접 올렸다 내리는 수고를 없애는 것이 목적이고, 화면을 벗어나면 반드시
/// 원래 밝기로 되돌린다.
library;

export 'brightness_control_stub.dart'
    if (dart.library.io) 'brightness_control_native.dart';
