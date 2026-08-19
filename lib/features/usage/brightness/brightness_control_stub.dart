/// 웹 검증 빌드용. 브라우저는 화면 밝기를 제어할 수 없다.
class BrightnessControl {
  const BrightnessControl();

  bool get isSupported => false;

  Future<void> boost() async {}

  Future<void> restore() async {}
}
