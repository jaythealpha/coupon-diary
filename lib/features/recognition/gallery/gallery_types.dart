/// 갤러리에서 가져온 이미지 한 장.
class GalleryImage {
  const GalleryImage({required this.id, required this.path, this.createdAt});

  final String id;
  final String path;
  final DateTime? createdAt;
}

/// 갤러리 접근 권한 상태.
enum GalleryPermission {
  granted,

  /// iOS의 "선택한 사진만 허용". 일부만 보이는 상태라 사용자에게 안내가 필요하다.
  limited,

  denied,

  /// 이 플랫폼에서 갤러리를 쓸 수 없음 (웹 검증 빌드).
  unsupported,
}
