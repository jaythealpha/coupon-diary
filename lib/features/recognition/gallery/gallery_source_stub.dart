import 'gallery_types.dart';

/// 웹 검증 빌드용.
class GallerySource {
  const GallerySource();

  Future<GalleryPermission> ensurePermission() async =>
      GalleryPermission.unsupported;

  Future<List<GalleryImage>> recentImages({int limit = 60}) async => const [];

  Future<String?> pickSingleImage() async => null;
}
