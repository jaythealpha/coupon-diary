import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import 'gallery_types.dart';

/// 갤러리 접근.
///
/// 사진을 **읽기만** 한다. 앱이 갤러리에 무언가를 쓰거나 지우는 일은 없다.
class GallerySource {
  GallerySource();

  final _picker = ImagePicker();

  Future<GalleryPermission> ensurePermission() async {
    final state = await PhotoManager.requestPermissionExtend();
    return switch (state) {
      PermissionState.authorized => GalleryPermission.granted,
      PermissionState.limited => GalleryPermission.limited,
      _ => GalleryPermission.denied,
    };
  }

  /// 최근 이미지를 최신순으로 가져온다.
  ///
  /// 기프티콘은 대부분 캡처(스크린샷)로 저장되므로 최근 사진 위주로 훑으면
  /// 대부분 걸린다. 전체 라이브러리를 스캔하면 수천 장에 OCR을 돌리게 되어
  /// 배터리와 시간을 지나치게 쓴다.
  Future<List<GalleryImage>> recentImages({int limit = 60}) async {
    final paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );
    if (paths.isEmpty) return const [];

    final assets = await paths.first.getAssetListPaged(page: 0, size: limit);
    final images = <GalleryImage>[];
    for (final asset in assets) {
      final file = await asset.file;
      if (file == null) continue;
      images.add(
        GalleryImage(
          id: asset.id,
          path: file.path,
          createdAt: asset.createDateTime,
        ),
      );
    }
    return images;
  }

  Future<String?> pickSingleImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    return file?.path;
  }
}
