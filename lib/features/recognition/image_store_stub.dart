import 'image_policy.dart';
import 'image_save_result.dart';

/// 웹 검증 빌드용. 파일 시스템이 없으므로 아무것도 저장하지 않는다.
class ImageStore {
  const ImageStore({this.policy = const CouponImagePolicy()});

  final CouponImagePolicy policy;

  Future<ImageSaveResult> persist(
    String sourcePath, {
    required String couponId,
  }) async => const ImageUnavailable();

  Future<void> remove(String? storedPath) async {}
}
