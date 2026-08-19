/// 쿠폰 이미지를 앱 샌드박스 안으로 복사해 보관한다.
///
/// 갤러리 경로를 그대로 참조하지 않는 이유: 사용자가 갤러리에서 원본을 지우면
/// 쿠폰 이미지가 통째로 사라진다. 반대로 우리가 갤러리에 무언가를 쓰지도 않는다.
library;

export 'image_store_stub.dart' if (dart.library.io) 'image_store_native.dart';
