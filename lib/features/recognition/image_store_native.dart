import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'image_policy.dart';
import 'image_probe.dart';
import 'image_save_result.dart';

class ImageStore {
  const ImageStore({this.policy = const CouponImagePolicy()});

  final CouponImagePolicy policy;

  /// 파일을 검증한 뒤 앱 전용 영역으로 **복사**한다.
  ///
  /// 원본은 건드리지 않는다. 갤러리의 사진을 옮기거나 지우지 않으며,
  /// 저장본은 파생물이 아니라 원본의 사본이다.
  Future<ImageSaveResult> persist(
    String sourcePath, {
    required String couponId,
  }) async {
    try {
      final source = File(sourcePath);
      if (!source.existsSync()) return const ImageUnavailable();

      final inspection = await inspect(source);
      if (inspection is ImageRejected) return ImageRefused(inspection.message);
      if (inspection is! ImageAccepted) return const ImageUnavailable();

      final documents = await getApplicationDocumentsDirectory();
      final directory = Directory(p.join(documents.path, 'coupons'));
      if (!directory.existsSync()) directory.createSync(recursive: true);

      // 확장자는 파일명이 아니라 실제 헤더에서 판정한 형식을 따른다.
      // 이름만 .jpg인 HEIC 파일이 갤러리에 흔하다.
      final target = p.join(
        directory.path,
        '$couponId${_extensionFor(inspection.format)}',
      );
      await source.copy(target);
      return ImageSaved(target);
    } on FileSystemException {
      // 이미지 없이도 쿠폰은 등록되어야 한다. 저장 실패가 등록을 막지 않는다.
      return const ImageUnavailable();
    }
  }

  /// 파일 앞부분만 읽어 형식과 크기를 판정한다. 전체를 메모리에 올리지 않는다.
  Future<ImageInspection> inspect(File file) async {
    final length = await file.length();
    final handle = await file.open();
    try {
      final header = await handle.read(
        length < CouponImagePolicy.headerBytes
            ? length
            : CouponImagePolicy.headerBytes,
      );
      return policy.inspect(
        byteLength: length,
        header: Uint8List.fromList(header),
      );
    } finally {
      await handle.close();
    }
  }

  String _extensionFor(ImageFormat format) => switch (format) {
    ImageFormat.jpeg => '.jpg',
    ImageFormat.png => '.png',
    ImageFormat.webp => '.webp',
    ImageFormat.heic => '.heic',
  };

  Future<void> remove(String? storedPath) async {
    if (storedPath == null || storedPath.isEmpty) return;
    try {
      final file = File(storedPath);
      if (file.existsSync()) await file.delete();
    } on FileSystemException {
      // 이미 지워졌거나 접근 불가. 조용히 넘어간다.
    }
  }
}
