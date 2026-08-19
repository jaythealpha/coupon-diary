import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/format.dart';
import '../../../design/theme.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/state_views.dart';
import '../../../domain/model/coupon.dart';
import '../application/gallery_scan_controller.dart';
import '../image_save_result.dart';
import '../image_store.dart';

/// 최근 사진에서 기프티콘을 찾아 한 번에 등록하는 화면.
class GalleryScanScreen extends ConsumerStatefulWidget {
  const GalleryScanScreen({super.key});

  @override
  ConsumerState<GalleryScanScreen> createState() => _GalleryScanScreenState();
}

class _GalleryScanScreenState extends ConsumerState<GalleryScanScreen> {
  bool _registering = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(galleryScanControllerProvider.notifier).start();
    });
  }

  Future<void> _registerSelected(GalleryScanDone done) async {
    final selected = done.candidates.where((c) => c.selected).toList();
    if (selected.isEmpty) return;

    setState(() => _registering = true);
    final repository = ref.read(couponRepositoryProvider);
    const store = ImageStore();
    final now = DateTime.now();

    try {
      for (var i = 0; i < selected.length; i++) {
        final candidate = selected[i];
        final parsed = candidate.parsed;
        final id = 'coupon-${now.microsecondsSinceEpoch}-$i';
        final saved = await store.persist(candidate.image.path, couponId: id);
        // 이미지 저장이 거부돼도(형식·용량) 인식된 정보는 이미 있으므로
        // 쿠폰 자체는 등록한다. 이미지 없이 등록되는 편이 통째로 버리는 것보다 낫다.
        final imagePath = saved is ImageSaved ? saved.path : null;

        await repository.save(
          Coupon(
            id: id,
            brand: parsed.brand ?? '알 수 없는 브랜드',
            productName: parsed.productName ?? '이름 미확인 쿠폰',
            kind: parsed.kind,
            status: CouponStatus.active,
            category: parsed.category,
            createdAt: now,
            updatedAt: now,
            barcode: parsed.barcode,
            barcodeFormat: parsed.barcodeFormat,
            imagePath: imagePath,
            expiresAt: parsed.expiresAt,
            faceValue: parsed.faceValue,
            balance: parsed.kind == CouponKind.amount ? parsed.faceValue : null,
            issuer: parsed.issuer,
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${selected.length}장을 등록했습니다. 인식이 확실하지 않은 항목은 '
            '보관함에서 확인해주세요.',
          ),
        ),
      );
      context.goNamed('vault');
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryScanControllerProvider);

    return Scaffold(
      appBar: AppTopBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '뒤로',
          onPressed: () =>
              context.canPop() ? context.pop() : context.goNamed('add'),
        ),
        title: '갤러리에서 찾기',
      ),
      body: SafeArea(child: ContentWidth(child: _body(state))),
      bottomNavigationBar:
          state is GalleryScanDone && state.candidates.isNotEmpty
          ? _RegisterBar(
              count: state.selectedCount,
              busy: _registering,
              onRegister: () => _registerSelected(state),
            )
          : null,
    );
  }

  Widget _body(GalleryScanState state) {
    return switch (state) {
      GalleryScanIdle() => const Center(child: CircularProgressIndicator()),
      GalleryScanUnsupported() => AppEmptyState(
        icon: Icons.desktop_access_disabled_outlined,
        title: '이 환경에서는 사용할 수 없습니다',
        description:
            '갤러리 자동 검색은 iOS·Android 앱에서만 동작합니다.\n'
            '직접 입력으로 쿠폰을 등록할 수 있습니다.',
        actionLabel: '직접 입력하기',
        onAction: () => context.goNamed('addManual'),
      ),
      GalleryScanPermissionDenied() => AppEmptyState(
        icon: Icons.no_photography_outlined,
        title: '사진 접근 권한이 필요합니다',
        description:
            '갤러리에서 기프티콘을 찾으려면 사진 읽기 권한이 필요합니다.\n'
            '설정 > 쿠폰다이어리 > 사진에서 권한을 허용한 뒤 다시 시도해주세요.\n'
            '사진은 기기 안에서만 분석되고 어디로도 전송되지 않습니다.',
        actionLabel: '다시 시도',
        onAction: () =>
            ref.read(galleryScanControllerProvider.notifier).start(),
      ),
      GalleryScanFailed(:final message) => AppErrorState(
        title: '사진을 읽지 못했습니다',
        description: message,
        onRetry: () => ref.read(galleryScanControllerProvider.notifier).start(),
      ),
      GalleryScanRunning(:final scanned, :final total, :final found) =>
        _ScanningView(scanned: scanned, total: total, found: found),
      GalleryScanDone() => _ResultView(
        state: state,
        onToggle: (id) =>
            ref.read(galleryScanControllerProvider.notifier).toggle(id),
        onSelectAll: (value) => ref
            .read(galleryScanControllerProvider.notifier)
            .setAllSelected(value),
        onRescan: () =>
            ref.read(galleryScanControllerProvider.notifier).start(),
      ),
    };
  }
}

class _ScanningView extends StatelessWidget {
  const _ScanningView({
    required this.scanned,
    required this.total,
    required this.found,
  });

  final int scanned;
  final int total;
  final int found;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = total == 0 ? 0.0 : scanned / total;

    return Padding(
      padding: const EdgeInsets.all(Space.x3l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('최근 사진을 살펴보는 중', style: AppTypography.title3),
          const SizedBox(height: Space.sm),
          Text(
            '$total장 중 $scanned장 확인 · 기프티콘 $found장 발견',
            style: AppTypography.subhead.copyWith(color: colors.labelSecondary),
          ),
          const SizedBox(height: Space.xl),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: LinearProgressIndicator(
              value: total == 0 ? null : progress,
              minHeight: 8,
              backgroundColor: colors.fill,
              // 단위가 붙은 문자열을 semanticsValue에 넣으면 프레임워크가
              // 진행률을 파싱하지 못한다. 설명은 라벨에 담는다.
              semanticsLabel: '사진 분석 진행률 $total장 중 $scanned장',
            ),
          ),
          const SizedBox(height: Space.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 16, color: colors.positive),
              const SizedBox(width: Space.sm),
              Flexible(
                child: Text(
                  '분석은 기기 안에서만 이뤄집니다.',
                  style: AppTypography.caption.copyWith(
                    color: colors.labelSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.state,
    required this.onToggle,
    required this.onSelectAll,
    required this.onRescan,
  });

  final GalleryScanDone state;
  final ValueChanged<String> onToggle;
  final ValueChanged<bool> onSelectAll;
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (state.candidates.isEmpty) {
      return AppEmptyState(
        icon: Icons.image_search_outlined,
        illustration: 'assets/illustrations/gallery_scan.png',
        title: '기프티콘을 찾지 못했습니다',
        description:
            '최근 사진 ${state.scannedCount}장을 확인했지만 쿠폰으로 보이는 이미지가 없었습니다.\n'
            '${state.limitedPermission ? '“선택한 사진만 허용” 상태라 일부 사진만 확인했을 수 있습니다. ' : ''}'
            '사진을 직접 고르거나 정보를 입력해 등록할 수 있습니다.',
        actionLabel: '직접 입력하기',
        onAction: () => context.goNamed('addManual'),
      );
    }

    final allSelected = state.candidates.every((c) => c.selected);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.lg,
            Space.lg,
            Space.lg,
            Space.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${state.candidates.length}장을 찾았어요',
                      style: AppTypography.title3,
                    ),
                    Text(
                      '사진 ${state.scannedCount}장을 확인했습니다. 등록할 것만 선택하세요.',
                      style: AppTypography.footnote.copyWith(
                        color: colors.labelSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => onSelectAll(!allSelected),
                child: Text(allSelected ? '전체 해제' : '전체 선택'),
              ),
            ],
          ),
        ),
        if (state.limitedPermission)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.lg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Space.md),
              decoration: BoxDecoration(
                color: colors.cautionFill,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Text(
                '“선택한 사진만 허용” 상태입니다. 허용한 사진만 확인할 수 있으니 '
                '찾는 쿠폰이 없다면 설정에서 접근 범위를 넓혀주세요.',
                style: AppTypography.caption.copyWith(color: colors.caution),
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(Space.lg),
            itemCount: state.candidates.length,
            separatorBuilder: (_, _) => const SizedBox(height: Space.md),
            itemBuilder: (context, index) {
              final candidate = state.candidates[index];
              return _CandidateTile(
                candidate: candidate,
                onToggle: () => onToggle(candidate.image.id),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: Space.sm),
          child: TextButton.icon(
            onPressed: onRescan,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('다시 검색'),
          ),
        ),
      ],
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({required this.candidate, required this.onToggle});

  final ScanCandidate candidate;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final parsed = candidate.parsed;
    final needsReview = parsed.fieldsNeedingReview.isNotEmpty;

    return Material(
      color: context.scheme.surface,
      borderRadius: BorderRadius.circular(Radii.lg),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Container(
          padding: const EdgeInsets.all(Space.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(
              color: candidate.selected
                  ? context.scheme.primary
                  : colors.separator,
              width: candidate.selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: candidate.selected,
                onChanged: (_) => onToggle(),
                semanticLabel: '${parsed.brand ?? '알 수 없는 브랜드'} 쿠폰 등록 여부',
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.sm),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: kIsWeb
                      ? Container(color: colors.fill)
                      : Image.file(
                          File(candidate.image.path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, _) =>
                              Container(color: colors.fill),
                        ),
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parsed.brand ?? '브랜드 미확인',
                      style: AppTypography.sectionHeader.copyWith(
                        color: colors.labelSecondary,
                      ),
                    ),
                    Text(
                      parsed.productName ?? '상품명 미확인',
                      style: AppTypography.subhead.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Space.xs),
                    Row(
                      children: [
                        Text(
                          parsed.expiresAt == null
                              ? '유효기간 미확인'
                              : Fmt.date(parsed.expiresAt),
                          style: AppTypography.caption.copyWith(
                            color: colors.labelTertiary,
                          ),
                        ),
                        if (needsReview) ...[
                          const SizedBox(width: Space.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Space.sm,
                              vertical: Space.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: colors.cautionFill,
                              borderRadius: BorderRadius.circular(Radii.sm),
                            ),
                            child: Text(
                              '확인 필요',
                              style: AppTypography.caption.copyWith(
                                color: colors.caution,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterBar extends StatelessWidget {
  const _RegisterBar({
    required this.count,
    required this.busy,
    required this.onRegister,
  });

  final int count;
  final bool busy;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.md,
        Space.lg,
        Space.lg,
      ),
      decoration: BoxDecoration(
        color: context.scheme.surface,
        border: Border(top: BorderSide(color: colors.separator)),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: count == 0 || busy ? null : onRegister,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
          child: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(count == 0 ? '등록할 쿠폰을 선택하세요' : '$count장 등록하기'),
        ),
      ),
    );
  }
}
