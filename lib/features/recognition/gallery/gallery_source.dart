/// 갤러리 접근. 네이티브에서만 동작한다.
library;

export 'gallery_source_stub.dart'
    if (dart.library.io) 'gallery_source_native.dart';
