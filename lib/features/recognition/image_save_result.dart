/// 이미지 저장 시도의 결과.
///
/// `String?`로 돌려주면 "저장 안 됨"의 이유가 사라져서, 형식이 잘못된 건지
/// 그냥 이 환경에 파일 시스템이 없는 건지 호출자가 구분할 수 없다.
library;

sealed class ImageSaveResult {
  const ImageSaveResult();
}

/// 검증을 통과해 앱 저장 영역에 복사됐다.
final class ImageSaved extends ImageSaveResult {
  const ImageSaved(this.path);
  final String path;
}

/// 정책에 걸려 거부됐다. [message]를 그대로 사용자에게 보여준다.
final class ImageRefused extends ImageSaveResult {
  const ImageRefused(this.message);
  final String message;
}

/// 이 환경에서 저장할 수 없거나(웹) 파일을 읽지 못했다.
///
/// 사용자 잘못이 아니므로 등록 자체를 막지 않는다. 이미지 없이 진행한다.
final class ImageUnavailable extends ImageSaveResult {
  const ImageUnavailable();
}
