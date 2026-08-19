import 'package:screen_brightness/screen_brightness.dart';

class BrightnessControl {
  BrightnessControl();

  bool _boosted = false;

  bool get isSupported => true;

  Future<void> boost() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1);
      _boosted = true;
    } on Exception {
      // 기기·OS에 따라 실패할 수 있다. 바코드는 여전히 보이므로 조용히 넘어간다.
      _boosted = false;
    }
  }

  Future<void> restore() async {
    if (!_boosted) return;
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } on Exception {
      // 복원 실패는 사용자에게 알릴 만한 일이 아니다. 앱을 벗어나면 OS가 되돌린다.
    } finally {
      _boosted = false;
    }
  }
}
