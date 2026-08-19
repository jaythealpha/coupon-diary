import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../design/theme.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/state_views.dart';
import '../../vault/presentation/coupon_form_screen.dart';
import '../gallery/gallery_source.dart';
import '../gallery/gallery_types.dart';
import '../image_save_result.dart';
import '../image_store.dart';

/// 쿠폰을 등록하는 세 가지 경로.
///
/// 첫 번째(갤러리 일괄 찾기)를 가장 크게 둔다. 스윗비콘이 사랑받은 이유가
/// "캡처하면 바로 등록"이었고, 사용자가 이미 찍어둔 캡처를 앱이 알아서 찾아주는
/// 것이 이 앱의 첫인상을 결정한다.
class AddCouponScreen extends ConsumerStatefulWidget {
  const AddCouponScreen({super.key});

  @override
  ConsumerState<AddCouponScreen> createState() => _AddCouponScreenState();
}

class _AddCouponScreenState extends ConsumerState<AddCouponScreen> {
  bool _picking = false;

  Future<void> _pickSingle() async {
    setState(() => _picking = true);
    try {
      final source = GallerySource();
      final permission = await source.ensurePermission();
      if (!mounted) return;

      if (permission == GalleryPermission.denied) {
        _showPermissionMessage();
        return;
      }

      final path = await source.pickSingleImage();
      if (!mounted || path == null) return;

      // 인식보다 검증을 먼저 한다. 지원하지 않는 형식이나 지나치게 큰 파일을
      // OCR에 넣으면 시간만 쓰고 실패한다.
      final couponId = 'coupon-${DateTime.now().microsecondsSinceEpoch}';
      final saved = await const ImageStore().persist(path, couponId: couponId);
      if (!mounted) return;

      if (saved is ImageRefused) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saved.message),
            duration: const Duration(seconds: 6),
          ),
        );
        return;
      }

      final scanner = ref.read(couponScannerProvider);
      final parser = ref.read(couponParserProvider);
      final scan = await scanner.scan(path);
      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CouponFormScreen(
            parsed: parser.parse(scan),
            imagePath: saved is ImageSaved ? saved.path : null,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _showPermissionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '사진 접근 권한이 없어 갤러리를 열 수 없습니다. '
          '설정 > 쿠폰다이어리 > 사진에서 권한을 허용해주세요.',
        ),
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scannerSupported = ref.watch(scannerSupportedProvider);

    return Scaffold(
      appBar: AppTopBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: '닫기',
          onPressed: () =>
              context.canPop() ? context.pop() : context.goNamed('vault'),
        ),
        title: '쿠폰 등록',
      ),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(Space.lg),
            children: [
              if (!scannerSupported) ...[
                const _ScannerUnavailableNotice(),
                const SizedBox(height: Space.lg),
              ],
              _PrimaryOption(
                icon: Icons.auto_awesome_mosaic_outlined,
                title: '갤러리에서 한 번에 찾기',
                description:
                    '최근 사진에서 기프티콘으로 보이는 이미지를 자동으로 찾아 목록으로 보여줍니다.\n'
                    '확인 후 원하는 것만 골라 등록하세요.',
                badge: '추천',
                enabled: scannerSupported && !_picking,
                onTap: () => context.goNamed('addFromGallery'),
              ),
              const SizedBox(height: Space.md),
              _SecondaryOption(
                icon: Icons.image_outlined,
                title: '사진 한 장 선택',
                description: '이미지를 직접 고르면 정보를 읽어 폼에 채워드립니다.',
                enabled: scannerSupported && !_picking,
                loading: _picking,
                onTap: _pickSingle,
              ),
              const SizedBox(height: Space.md),
              _SecondaryOption(
                icon: Icons.edit_outlined,
                title: '직접 입력',
                description: '문자로 받은 번호만 있을 때처럼 이미지가 없어도 등록할 수 있습니다.',
                enabled: !_picking,
                onTap: () => context.goNamed('addManual'),
              ),
              const SizedBox(height: Space.xxl),
              const _PrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryOption extends StatelessWidget {
  const _PrimaryOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool enabled;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(Radii.lg),
          child: Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 28, color: scheme.onPrimaryContainer),
                    const Spacer(),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.sm,
                          vertical: Space.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(Radii.sm),
                        ),
                        child: Text(
                          badge!,
                          style: AppTypography.caption.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Space.lg),
                Text(
                  title,
                  style: AppTypography.title3.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  description,
                  style: AppTypography.footnote.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryOption extends StatelessWidget {
  const _SecondaryOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool enabled;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: context.scheme.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(Radii.lg),
          child: Container(
            padding: const EdgeInsets.all(Space.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: colors.separator),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(icon, size: 24, color: colors.labelSecondary),
                ),
                const SizedBox(width: Space.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.callout.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Space.xxs),
                      Text(
                        description,
                        style: AppTypography.footnote.copyWith(
                          color: colors.labelSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.labelTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScannerUnavailableNotice extends StatelessWidget {
  const _ScannerUnavailableNotice();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: colors.cautionFill,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: colors.caution),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(
              '이 환경에서는 자동 인식을 사용할 수 없습니다. '
              '아래 “직접 입력”으로 등록해주세요. 실제 앱(iOS·Android)에서는 '
              '기기 안에서 바로 인식됩니다.',
              style: AppTypography.footnote.copyWith(color: colors.caution),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline, size: 16, color: colors.positive),
        const SizedBox(width: Space.sm),
        Expanded(
          child: Text(
            '쿠폰 이미지와 바코드 번호는 이 기기 안에서만 처리되고 저장됩니다. '
            '어떤 서버로도 전송되지 않습니다.',
            style: AppTypography.caption.copyWith(color: colors.labelSecondary),
          ),
        ),
      ],
    );
  }
}
