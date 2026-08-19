import 'dart:io' show File;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/format.dart';
import '../../../design/theme.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/app_scaffold.dart';
import '../../../design/widgets/grouped_list.dart';
import '../../../design/widgets/state_views.dart';
import '../../../domain/model/coupon.dart';
import '../../recognition/image_store.dart';
import 'widgets/coupon_row.dart';

class CouponDetailScreen extends ConsumerWidget {
  const CouponDetailScreen({super.key, required this.couponId});

  final String couponId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupon = ref.watch(couponDetailProvider(couponId));
    final now = ref.watch(nowProvider);

    return coupon.when(
      loading: () => PlainScaffold(
        title: '',
        leading: BackChevron(onPressed: () => _back(context)),
        child: const SizedBox.shrink(),
      ),
      error: (error, _) => PlainScaffold(
        title: '쿠폰',
        leading: BackChevron(onPressed: () => _back(context)),
        child: AppErrorState(
          title: '쿠폰을 불러오지 못했습니다',
          description: '저장소를 읽는 중 문제가 생겼습니다. 잠시 후 다시 시도해주세요.',
          onRetry: () => ref.invalidate(couponDetailProvider(couponId)),
        ),
      ),
      data: (value) {
        if (value == null) {
          return PlainScaffold(
            title: '쿠폰',
            leading: BackChevron(onPressed: () => _back(context)),
            child: AppEmptyState(
              icon: Icons.search_off_rounded,
              title: '삭제된 쿠폰입니다',
              description: '이미 삭제되었거나 존재하지 않는 쿠폰입니다.',
              actionLabel: '보관함으로',
              onAction: () => context.goNamed('vault'),
            ),
          );
        }
        return _Detail(coupon: value, now: now);
      },
    );
  }

  static void _back(BuildContext context) =>
      context.canPop() ? context.pop() : context.goNamed('vault');
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.coupon, required this.now});

  final Coupon coupon;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUse = coupon.status == CouponStatus.active;

    return PlainScaffold(
      title: coupon.brand,
      leading: BackChevron(onPressed: () => CouponDetailScreen._back(context)),
      actions: [
        _OverflowMenu(coupon: coupon),
        const SizedBox(width: Space.xs),
      ],
      bottomBar: BottomActionBar(
        child: _Actions(coupon: coupon, canUse: canUse),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _PassHero(coupon: coupon, now: now),
          if (coupon.status != CouponStatus.active)
            _StatusNotice(coupon: coupon),
          if (coupon.kind == CouponKind.amount) _BalanceSection(coupon: coupon),
          _InfoSection(coupon: coupon),
          const SizedBox(height: Space.xxl),
        ],
      ),
    );
  }
}

/// 상단 패스 카드.
///
/// 이 화면의 아래 절반이 텅 비어 있었다. 정보 행 몇 줄뿐이라 "내가 무엇을 들고
/// 있는지"가 느껴지지 않았다. 사용 화면의 패스 카드와 같은 언어를 써서 한 장의
/// 쿠폰처럼 보이게 하고, 바코드 미리보기를 눌러 바로 사용 화면으로 넘어가게 한다.
class _PassHero extends StatelessWidget {
  const _PassHero({required this.coupon, required this.now});

  final Coupon coupon;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final days = coupon.daysLeftFrom(now);
    final urgent = days != null && days >= 0 && days <= 7;
    final expired = days != null && days < 0;
    final critical = expired || (urgent && days <= 3);

    final tint = critical
        ? colors.critical
        : urgent
        ? colors.caution
        : colors.labelSecondary;
    final tintFill = critical
        ? colors.criticalFill
        : urgent
        ? colors.cautionFill
        : colors.fill;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.gutter,
        Space.md,
        Space.gutter,
        0,
      ),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: colors.surface,
          shape: AppShapes.hero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(Space.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CouponThumb(coupon: coupon, tint: tint, fill: tintFill),
                      const SizedBox(width: Space.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coupon.brand,
                              style: AppTypography.footnote.copyWith(
                                color: colors.labelSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              coupon.productName,
                              style: AppTypography.title2.copyWith(
                                color: colors.label,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.lg),
                  Row(
                    children: [
                      _Pill(
                        label: Fmt.expiryLabel(days),
                        color: tint,
                        fill: tintFill,
                        emphasize: urgent || expired,
                      ),
                      const SizedBox(width: Space.sm),
                      _Pill(
                        label: coupon.kind.label,
                        color: colors.labelSecondary,
                        fill: colors.fill,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (coupon.barcode?.isNotEmpty == true) ...[
              const _PassPerforation(),
              _BarcodePreview(coupon: coupon),
            ],
          ],
        ),
      ),
    );
  }
}

/// 절취선. 사용 화면의 패스 카드와 같은 표현을 써서 두 화면을 잇는다.
class _PassPerforation extends StatelessWidget {
  const _PassPerforation();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          _Notch(colors: colors, isLeft: true),
          Expanded(
            child: CustomPaint(
              painter: _DashPainter(colors.separator),
              size: const Size(double.infinity, 20),
            ),
          ),
          _Notch(colors: colors, isLeft: false),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch({required this.colors, required this.isLeft});

  final AppSemanticColors colors;
  final bool isLeft;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 10,
    height: 20,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: colors.groupedBackground,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? Radius.zero : const Radius.circular(10),
          right: isLeft ? const Radius.circular(10) : Radius.zero,
        ),
      ),
    ),
  );
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dash = 4.0;
    const gap = 5.0;
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

/// 바코드 미리보기. 눌러서 바로 전체 화면 사용 모드로 넘어간다.
///
/// 매장 앞에서 상세를 열었다면 다음 행동은 하나뿐이다. 하단 버튼까지 시선을
/// 옮기지 않고 보이는 바코드를 그대로 누르면 되게 한다.
class _BarcodePreview extends StatelessWidget {
  const _BarcodePreview({required this.coupon});

  final Coupon coupon;

  /// 흰 패널 위 글자색. 테마색을 쓰면 다크 모드에서 흰 바탕에 밝은 회색이 얹혀
  /// 거의 보이지 않는다. 이 패널은 늘 흰색이므로 글자색도 고정한다.
  static const _onWhiteMuted = Color(0xFF8A8A8F);

  @override
  Widget build(BuildContext context) {
    final canUse = coupon.status == CouponStatus.active;
    final isQr = coupon.barcodeFormat == BarcodeFormat.qr;

    return GestureDetector(
      onTap: canUse
          ? () =>
                context.goNamed('useCoupon', pathParameters: {'id': coupon.id})
          : null,
      child: Semantics(
        button: canUse,
        label: canUse ? '바코드 크게 보기' : '바코드',
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: const ShapeDecoration(
            // 바코드는 항상 순백 위에 둔다. 다크 모드에서도 마찬가지다 —
            // 스캐너 인식률이 사용자 취향보다 우선한다.
            color: Colors.white,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(Radii.xl),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.xl,
              Space.md,
              Space.xl,
              Space.lg,
            ),
            child: Column(
              children: [
                BarcodeWidget(
                  barcode: isQr ? Barcode.qrCode() : Barcode.code128(),
                  data: coupon.barcode!,
                  height: isQr ? 96 : 56,
                  width: isQr ? 96 : double.infinity,
                  drawText: false,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  errorBuilder: (context, _) => const SizedBox(height: 56),
                ),
                if (canUse) ...[
                  const SizedBox(height: Space.md),
                  Text(
                    '눌러서 크게 보기',
                    style: AppTypography.caption.copyWith(color: _onWhiteMuted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.fill,
    this.emphasize = false,
  });

  final String label;
  final Color color;
  final Color fill;
  final bool emphasize;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(
      color: fill,
      shape: const RoundedSuperellipseBorder(
        borderRadius: BorderRadius.all(Radius.circular(Radii.pill)),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.xs + 2,
      ),
      child: Text(
        label,
        style: AppTypography.footnote.copyWith(
          color: color,
          fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ),
  );
}

class _CouponThumb extends StatelessWidget {
  const _CouponThumb({
    required this.coupon,
    required this.tint,
    required this.fill,
  });

  final Coupon coupon;
  final Color tint;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    final path = coupon.imagePath;
    final hasImage = !kIsWeb && path != null && path.isNotEmpty;

    return ClipRSuperellipse(
      borderRadius: const BorderRadius.all(Radius.circular(Radii.lg)),
      child: SizedBox(
        width: 56,
        height: 56,
        child: hasImage
            ? Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (context, _, _) =>
                    _ThumbFallback(coupon: coupon, tint: tint, fill: fill),
              )
            : _ThumbFallback(coupon: coupon, tint: tint, fill: fill),
      ),
    );
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback({
    required this.coupon,
    required this.tint,
    required this.fill,
  });

  final Coupon coupon;
  final Color tint;
  final Color fill;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: fill,
    child: Icon(iconForCategory(coupon.category), size: 26, color: tint),
  );
}

/// 만료·사용 완료 쿠폰에 무엇을 할 수 있는지 알려준다.
///
/// 만료됐다고 끝이 아니다 — 미사용 상품권은 유효기간이 지나도 90%를
/// 돌려받을 수 있는데 이걸 모르는 사용자가 많다.
class _StatusNotice extends StatelessWidget {
  const _StatusNotice({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (
      String title,
      String body,
      Color tint,
      Color fill,
    ) = switch (coupon.status) {
      CouponStatus.expired => (
        '유효기간이 지났습니다',
        '미사용 상태라면 발행사에 환불을 요청할 수 있습니다. 상품권 표준약관상 유효기간 경과 후에도 '
            '5년 안에는 잔액의 90%를 돌려받을 수 있습니다.',
        colors.critical,
        colors.criticalFill,
      ),
      CouponStatus.used => (
        '사용 완료된 쿠폰입니다',
        '잘못 표시된 경우 아래 “사용 취소”로 되돌릴 수 있습니다.',
        colors.labelSecondary,
        colors.fill,
      ),
      CouponStatus.gifted => (
        '${coupon.giftedTo ?? '다른 사람'}님에게 선물했습니다',
        '상대가 아직 쓰지 않았다면 아래 “선물 취소”로 되돌릴 수 있습니다.',
        colors.positive,
        colors.positiveFill,
      ),
      _ => ('보관 중', '', colors.labelSecondary, colors.fill),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.gutter,
        Space.lg,
        Space.gutter,
        0,
      ),
      child: DecoratedBox(
        decoration: ShapeDecoration(color: fill, shape: AppShapes.card),
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headline.copyWith(color: tint)),
              if (body.isNotEmpty) ...[
                const SizedBox(height: Space.xs),
                Text(body, style: AppTypography.footnote.copyWith(color: tint)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceSection extends ConsumerWidget {
  const _BalanceSection({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final usage = ref.watch(couponUsageProvider(coupon.id));
    final faceValue = coupon.faceValue ?? 0;
    final balance = coupon.balance ?? faceValue;
    final ratio = faceValue == 0 ? 0.0 : (balance / faceValue).clamp(0.0, 1.0);

    return Column(
      children: [
        // 잔액은 이 화면의 주인공이다. 큰 숫자로 단독 배치한다.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.gutter,
            Space.xl,
            Space.gutter,
            0,
          ),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: colors.surface,
              shape: AppShapes.card,
            ),
            child: Padding(
              padding: const EdgeInsets.all(Space.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '남은 금액',
                    style: AppTypography.footnote.copyWith(
                      color: colors.labelSecondary,
                    ),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    Fmt.won(balance),
                    style: AppTypography.numericDisplay.copyWith(
                      color: balance == 0 ? colors.labelTertiary : colors.label,
                    ),
                  ),
                  const SizedBox(height: Space.lg),
                  ClipRSuperellipse(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(Radii.pill),
                    ),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      backgroundColor: colors.fill,
                      valueColor: AlwaysStoppedAnimation(colors.positive),
                      // 단위가 붙은 문자열을 semanticsValue에 넣으면 프레임워크가
                      // 진행률을 파싱하지 못한다. 설명은 라벨에 담는다.
                      semanticsLabel:
                          '남은 금액 ${Fmt.won(balance)}, 액면가의 '
                          '${(ratio * 100).round()}퍼센트',
                    ),
                  ),
                  const SizedBox(height: Space.sm),
                  Text(
                    '액면가 ${Fmt.won(faceValue)}',
                    style: AppTypography.footnote.copyWith(
                      color: colors.labelTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        usage.when(
          loading: () => const SizedBox(height: Space.lg),
          error: (_, _) => const SizedBox(height: Space.lg),
          data: (entries) => entries.isEmpty
              ? GroupedSection(
                  header: '사용 내역',
                  children: [
                    GroupedRow(
                      child: Text(
                        '아직 사용 내역이 없습니다. 사용 화면에서 나올 때 쓴 금액을 기록하면 '
                        '잔액이 자동으로 계산됩니다.',
                        style: AppTypography.footnote.copyWith(
                          color: colors.labelSecondary,
                        ),
                      ),
                    ),
                  ],
                )
              : GroupedSection(
                  header: '사용 내역',
                  children: [
                    for (final entry in entries)
                      _UsageRow(entry: entry, couponId: coupon.id),
                  ],
                ),
        ),
      ],
    );
  }
}

class _UsageRow extends ConsumerWidget {
  const _UsageRow({required this.entry, required this.couponId});

  final UsageEntry entry;
  final String couponId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return GroupedRow(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.place?.isNotEmpty == true ? entry.place! : '사용',
                  style: AppTypography.body.copyWith(color: colors.label),
                ),
                const SizedBox(height: 2),
                Text(
                  Fmt.dateTime(entry.usedAt),
                  style: AppTypography.footnote.copyWith(
                    color: colors.labelTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '−${Fmt.won(entry.amount)}',
            style: AppTypography.numeric.copyWith(
              fontSize: 15,
              color: colors.label,
            ),
          ),
          IconButton(
            tooltip: '이 사용 내역 삭제',
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.remove_circle_outline_rounded,
              size: 20,
              color: colors.labelTertiary,
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(couponRepositoryProvider).deleteUsage(entry.id);
              messenger.showSnackBar(
                const SnackBar(content: Text('사용 내역을 삭제하고 잔액을 되돌렸습니다.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    return GroupedSection(
      header: '쿠폰 정보',
      children: [
        _InfoRow(label: '유효기간', value: Fmt.date(coupon.expiresAt)),
        _InfoRow(label: '카테고리', value: coupon.category.label),
        if (coupon.issuer != null)
          _InfoRow(label: '발행처', value: coupon.issuer!),
        if (coupon.barcode != null)
          _InfoRow(
            label: '쿠폰번호',
            value: Fmt.barcodeGroups(coupon.barcode!),
            numeric: true,
          ),
        if (coupon.memo?.isNotEmpty == true)
          _InfoRow(label: '메모', value: coupon.memo!),
        _InfoRow(label: '등록일', value: Fmt.date(coupon.createdAt)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.numeric = false,
  });

  final String label;
  final String value;
  final bool numeric;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GroupedRow(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(color: colors.labelSecondary),
          ),
          const SizedBox(width: Space.lg),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: numeric
                  ? AppTypography.numeric.copyWith(
                      fontSize: 15,
                      color: colors.label,
                    )
                  : AppTypography.body.copyWith(color: colors.label),
            ),
          ),
        ],
      ),
    );
  }
}

/// 하단 액션. 강조되는 버튼은 "사용하기" 하나뿐이다.
/// 매장 계산대에서 급하게 여는 화면이라 선택지를 늘리면 안 된다.
class _Actions extends ConsumerWidget {
  const _Actions({required this.coupon, required this.canUse});

  final Coupon coupon;
  final bool canUse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!canUse) {
      return OutlinedButton(
        onPressed: () => _restore(context, ref),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(coupon.status == CouponStatus.gifted ? '선물 취소' : '사용 취소'),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: FilledButton(
            onPressed: () =>
                context.goNamed('useCoupon', pathParameters: {'id': coupon.id}),
            child: const Text('사용하기'),
          ),
        ),
        const SizedBox(width: Space.sm),
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () => context.goNamed(
              'giftCoupon',
              pathParameters: {'id': coupon.id},
            ),
            child: const Text('선물'),
          ),
        ),
      ],
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(couponRepositoryProvider)
        .save(
          coupon.copyWith(
            status: CouponStatus.active,
            updatedAt: DateTime.now(),
            clearGift: true,
          ),
        );
    messenger.showSnackBar(
      const SnackBar(content: Text('쿠폰을 다시 사용 가능 상태로 되돌렸습니다.')),
    );
  }
}

class _OverflowMenu extends ConsumerWidget {
  const _OverflowMenu({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      tooltip: '더 보기',
      icon: const Icon(Icons.more_horiz_rounded),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            context.goNamed('editCoupon', pathParameters: {'id': coupon.id});
          case 'markUsed':
            await ref
                .read(couponRepositoryProvider)
                .save(
                  coupon.copyWith(
                    status: CouponStatus.used,
                    updatedAt: DateTime.now(),
                  ),
                );
          case 'delete':
            await _confirmDelete(context, ref);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('수정')),
        if (coupon.status == CouponStatus.active)
          const PopupMenuItem(value: 'markUsed', child: Text('사용 완료로 표시')),
        PopupMenuItem(
          value: 'delete',
          child: Text('삭제', style: TextStyle(color: context.colors.critical)),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('쿠폰을 삭제할까요?'),
        content: const Text(
          '삭제하면 등록한 이미지와 사용 내역이 함께 사라지며 되돌릴 수 없습니다.\n'
          '아직 쓸 수 있는 쿠폰이라면 삭제 대신 “사용 완료로 표시”를 권합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.critical,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    // 이미지 파일을 먼저 지운다. DB 행을 먼저 지우면 imagePath를 잃어버려
    // 어떤 화면으로도 다시 접근할 수 없는 고아 파일이 기기에 남는다.
    // (실제로 그랬다 — "이미지와 사용 내역이 함께 사라집니다"라고 써놓고
    // 파일은 그대로 남겨두고 있었다. 사용 내역은 FK cascade로 지워진다.)
    await const ImageStore().remove(coupon.imagePath);
    await ref.read(couponRepositoryProvider).delete(coupon.id);
    if (!context.mounted) return;
    context.goNamed('vault');
  }
}
