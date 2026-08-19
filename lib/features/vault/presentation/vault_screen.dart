import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/format.dart';
import '../../../design/theme.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/app_scaffold.dart';
import '../../../design/widgets/grouped_list.dart';
import '../../../design/widgets/illustration.dart';
import '../../../design/widgets/state_views.dart';
import '../../../domain/model/coupon.dart';
import '../../../domain/repository/coupon_repository.dart';
import 'widgets/coupon_row.dart';

/// 보관함. 앱의 홈 화면.
class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

/// 상단 상태 탭. 사용자가 실제로 구분해서 보는 세 덩어리.
enum _StatusTab {
  active('사용 가능', {CouponStatus.active}),
  done('사용·만료', {CouponStatus.used, CouponStatus.expired}),
  gifted('선물함', {CouponStatus.gifted, CouponStatus.archived});

  const _StatusTab(this.label, this.statuses);
  final String label;
  final Set<CouponStatus> statuses;
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  final _searchController = TextEditingController();
  _StatusTab _tab = _StatusTab.active;

  @override
  void initState() {
    super.initState();
    // 앱을 켤 때마다 지난 쿠폰의 상태를 정리한다. 알림을 못 본 채 며칠이 지나도
    // 목록의 상태 표시는 항상 오늘 기준이어야 한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(couponRepositoryProvider).refreshExpiredStatuses(DateTime.now());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectTab(_StatusTab tab) {
    setState(() => _tab = tab);
    ref.read(vaultQueryProvider.notifier).setStatuses(tab.statuses);
  }

  Future<void> _openCategorySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _CategorySheet(),
    );
  }

  void _resetFilters() {
    _searchController.clear();
    ref.read(vaultQueryProvider.notifier).clearFilters();
    ref.read(vaultQueryProvider.notifier).setStatuses(_tab.statuses);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(vaultQueryProvider);
    final coupons = ref.watch(vaultCouponsProvider);
    final now = ref.watch(nowProvider);
    // 쿠폰이 한 장도 없으면 검색·탭을 숨긴다. 다른 탭도 어차피 비어 있다.
    final isFirstRun = ref.watch(vaultIsEmptyProvider).value ?? false;

    return LargeTitleScaffold(
      title: '보관함',
      actions: [
        if (!isFirstRun) ...[
          IconButton(
            onPressed: _openCategorySheet,
            icon: Badge(
              isLabelVisible: query.categories.isNotEmpty,
              label: Text('${query.categories.length}'),
              child: const Icon(Icons.tune_rounded),
            ),
            tooltip: '카테고리 필터',
          ),
          PopupMenuButton<CouponSort>(
            initialValue: query.sort,
            onSelected: (value) =>
                ref.read(vaultQueryProvider.notifier).setSort(value),
            tooltip: '정렬 기준',
            icon: const Icon(Icons.swap_vert_rounded),
            itemBuilder: (context) => [
              for (final option in CouponSort.values)
                PopupMenuItem(value: option, child: Text(option.label)),
            ],
          ),
        ],
        IconButton(
          onPressed: () => context.goNamed('add'),
          icon: const Icon(Icons.add_rounded, size: 26),
          tooltip: '쿠폰 등록',
        ),
        const SizedBox(width: Space.xs),
      ],
      slivers: [
        if (!isFirstRun) ...[
          SliverToBoxAdapter(
            child: _SearchField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(vaultQueryProvider.notifier).setKeyword(value),
            ),
          ),
          SliverToBoxAdapter(
            child: _StatusTabs(selected: _tab, onSelect: _selectTab),
          ),
        ],
        if (query.categories.isNotEmpty)
          SliverToBoxAdapter(
            child: _ActiveFilterLine(
              categories: query.categories,
              onClear: _resetFilters,
            ),
          ),
        if (_tab == _StatusTab.active) const _ExpiringBanner(),
        coupons.when(
          loading: () => const SliverToBoxAdapter(child: CouponListSkeleton()),
          error: (error, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorState(
              title: '쿠폰을 불러오지 못했습니다',
              description:
                  '저장소를 읽는 중 문제가 생겼습니다. 다시 시도해도 같은 화면이 나오면 '
                  '앱을 완전히 종료했다가 다시 열어주세요.',
              onRetry: () => ref.invalidate(vaultCouponsProvider),
            ),
          ),
          data: (list) => list.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyForContext(
                    tab: _tab,
                    hasFilters:
                        query.keyword.isNotEmpty || query.categories.isNotEmpty,
                    onClearFilters: _resetFilters,
                  ),
                )
              : SliverToBoxAdapter(
                  child: GroupedSection(
                    children: [
                      for (final coupon in list)
                        CouponRow(
                          coupon: coupon,
                          now: now,
                          onTap: () => context.goNamed(
                            'couponDetail',
                            pathParameters: {'id': coupon.id},
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

/// 검색 입력. iOS 검색 필드처럼 채워진 캡슐 형태.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.gutter,
        0,
        Space.gutter,
        Space.md,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: AppTypography.subhead.copyWith(color: colors.label),
        decoration: InputDecoration(
          hintText: '브랜드, 상품명 검색',
          filled: true,
          fillColor: colors.fill,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: colors.labelSecondary,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 38),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    size: 18,
                    color: colors.labelTertiary,
                  ),
                  tooltip: '검색어 지우기',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          border: _capsule,
          enabledBorder: _capsule,
          focusedBorder: _capsule,
        ),
      ),
    );
  }

  static const _capsule = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(Radii.md)),
    borderSide: BorderSide.none,
  );
}

/// iOS 세그먼트 컨트롤. 홈이 담긴 얕은 트랙 위에 흰 알약이 미끄러진다.
class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.selected, required this.onSelect});

  final _StatusTab selected;
  final ValueChanged<_StatusTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: ShapeDecoration(
          color: colors.fill,
          shape: const RoundedSuperellipseBorder(
            borderRadius: BorderRadius.all(Radius.circular(Radii.md)),
          ),
        ),
        child: Row(
          children: [
            for (final tab in _StatusTab.values)
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(tab),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: Motion.fast,
                    curve: Motion.enter,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: tab == selected
                          ? colors.surface
                          : Colors.transparent,
                      shape: const RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      shadows: tab == selected
                          ? const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      tab.label,
                      style: AppTypography.subhead.copyWith(
                        color: colors.label,
                        fontWeight: tab == selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActiveFilterLine extends StatelessWidget {
  const _ActiveFilterLine({required this.categories, required this.onClear});

  final Set<CouponCategory> categories;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.gutter + Space.xs,
        Space.md,
        Space.sm,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${categories.map((c) => c.label).join(', ')}만 보는 중',
              style: AppTypography.footnote.copyWith(
                color: colors.labelSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('해제')),
        ],
      ),
    );
  }
}

/// 7일 이내 만료 요약. 이 앱이 존재하는 이유를 홈 최상단에서 반복한다.
class _ExpiringBanner extends ConsumerWidget {
  const _ExpiringBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiring = ref.watch(expiringSoonProvider);
    final colors = context.colors;

    return expiring.maybeWhen(
      data: (list) {
        if (list.isEmpty) return const SliverToBoxAdapter();
        final soonest = list.first;
        final days = soonest.daysLeftFrom(ref.watch(nowProvider));

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.gutter,
              Space.lg,
              Space.gutter,
              0,
            ),
            child: GestureDetector(
              onTap: () => context.goNamed(
                'couponDetail',
                pathParameters: {'id': soonest.id},
              ),
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: colors.cautionFill,
                  shape: AppShapes.card,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.lg,
                    vertical: Space.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active_rounded,
                        size: 19,
                        color: colors.caution,
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        // 목록 첫 줄과 같은 쿠폰을 되풀이하지 않는다. 장수와
                        // 가장 급한 기한만 알려주고 상세는 목록에 맡긴다.
                        child: Text(
                          list.length == 1
                              ? '1장이 ${Fmt.expiryLabel(days)}'
                              : '${list.length}장이 이번 주에 만료돼요',
                          style: AppTypography.subhead.copyWith(
                            color: colors.caution,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: colors.caution,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      orElse: () => const SliverToBoxAdapter(),
    );
  }
}

class _CategorySheet extends ConsumerWidget {
  const _CategorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final selected = ref.watch(vaultQueryProvider).categories;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        0,
        Space.xl,
        MediaQuery.paddingOf(context).bottom + Space.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('카테고리', style: AppTypography.title2),
          const SizedBox(height: Space.xs),
          Text(
            '선택하지 않으면 전체를 보여줍니다.',
            style: AppTypography.footnote.copyWith(
              color: colors.labelSecondary,
            ),
          ),
          const SizedBox(height: Space.lg),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final category in CouponCategory.values)
                FilterChip(
                  selected: selected.contains(category),
                  onSelected: (_) => ref
                      .read(vaultQueryProvider.notifier)
                      .toggleCategory(category),
                  avatar: Icon(
                    iconForCategory(category),
                    size: 17,
                    color: selected.contains(category)
                        ? context.scheme.onPrimary
                        : colors.labelSecondary,
                  ),
                  label: Text(category.label),
                ),
            ],
          ),
          const SizedBox(height: Space.xl),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }
}

class _EmptyForContext extends StatelessWidget {
  const _EmptyForContext({
    required this.tab,
    required this.hasFilters,
    required this.onClearFilters,
  });

  final _StatusTab tab;
  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (hasFilters) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: '조건에 맞는 쿠폰이 없습니다',
        description: '검색어나 카테고리 필터를 바꿔보세요.',
        actionLabel: '필터 초기화',
        onAction: onClearFilters,
      );
    }

    return switch (tab) {
      // 보관함은 처음부터 비어 있다. 그래서 이 화면이 첫인상이자 사용 설명서다.
      // 일반적인 빈 화면(아이콘 + 한 줄)으로는 무엇을 할 수 있는 앱인지
      // 전달되지 않아, 세 걸음을 짧게 보여주고 바로 등록으로 보낸다.
      _StatusTab.active => const _FirstRunGuide(),
      _StatusTab.done => const AppEmptyState(
        icon: Icons.history_rounded,
        title: '사용하거나 만료된 쿠폰이 없습니다',
        description: '쿠폰을 사용하면 여기에 기록이 남습니다.',
      ),
      _StatusTab.gifted => const AppEmptyState(
        icon: Icons.card_giftcard_rounded,
        illustration: 'assets/illustrations/gift.png',
        title: '선물한 쿠폰이 없습니다',
        description: '쿠폰 상세 화면에서 다른 사람에게 선물할 수 있습니다.',
      ),
    };
  }
}

/// 첫 실행 안내. 빈 보관함 자리에 놓인다.
class _FirstRunGuide extends ConsumerWidget {
  const _FirstRunGuide();

  static const _scanStep = (
    Icons.photo_library_outlined,
    '갤러리에서 기프티콘을 찾아 등록',
    '브랜드·유효기간·바코드를 읽어 채워둡니다',
  );

  /// 자동 인식이 없는 환경(웹 체험판)에서 첫 줄을 대신한다.
  static const _manualStep = (
    Icons.edit_outlined,
    '쿠폰을 등록해 모아두기',
    '브랜드·유효기간·바코드를 입력하면 한곳에 정리됩니다',
  );

  static const _scanStepBarcode = (
    Icons.qr_code_2_rounded,
    '계산대에서 바코드를 크게',
    '밝기를 최대로 올려 바로 찍히게 합니다',
  );

  /// 밝기 제어가 없는 환경(웹)용. 되는 것만 말한다.
  static const _plainStepBarcode = (
    Icons.qr_code_2_rounded,
    '계산대에서 바코드를 크게',
    '화면 가득 띄워 바로 찍히게 합니다',
  );

  static const _notifyStep = (
    Icons.notifications_active_outlined,
    '만료 전에 미리 알림',
    '30·7·3·1일 전에 알려드립니다',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    // 웹 체험판에는 기기 내 인식 플러그인이 없다. 되지도 않는 기능을 첫 줄에
    // 내세우면 눌러보고 흐려진 항목을 만나게 된다 — 안내가 거짓말이 된다.
    final scannerSupported = ref.watch(scannerSupportedProvider);
    final brightnessSupported = ref.watch(brightnessSupportedProvider);
    final notificationsSupported = ref.watch(notificationsSupportedProvider);
    final allSupported =
        scannerSupported && brightnessSupported && notificationsSupported;
    final steps = [
      if (scannerSupported) _scanStep else _manualStep,
      if (brightnessSupported) _scanStepBarcode else _plainStepBarcode,
      // 알림이 없는 환경에서는 3번 걸음을 아예 빼고, 아래 고지로 설명한다.
      if (notificationsSupported) _notifyStep,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Space.gutter,
        Space.xl,
        Space.gutter,
        Space.x5l,
      ),
      child: Column(
        children: [
          const Illustration(
            asset: 'assets/illustrations/empty_vault.png',
            size: 132,
            fallbackIcon: Icons.confirmation_number_rounded,
          ),
          const SizedBox(height: Space.lg),
          Text(
            '기프티콘, 여기 모아두세요',
            style: AppTypography.title2.copyWith(color: colors.label),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Space.xs),
          Text(
            '쿠폰 사진과 바코드는 이 기기 밖으로 나가지 않습니다.',
            style: AppTypography.subhead.copyWith(color: colors.labelSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Space.xxl),
          DecoratedBox(
            decoration: ShapeDecoration(
              color: colors.surface,
              shape: AppShapes.card,
            ),
            child: Column(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  _GuideRow(
                    index: i + 1,
                    icon: steps[i].$1,
                    title: steps[i].$2,
                    body: steps[i].$3,
                  ),
                  if (i != steps.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: Space.rowInset),
                      child: Divider(height: 0.5, color: colors.separator),
                    ),
                ],
              ],
            ),
          ),
          if (!allSupported) ...[
            const SizedBox(height: Space.md),
            _TrialLimitNote(
              missing: [
                if (!scannerSupported) '갤러리 자동 인식',
                if (!brightnessSupported) '화면 밝기 자동 최대화',
                if (!notificationsSupported) '만료 알림',
              ],
            ),
          ],
          const SizedBox(height: Space.xxl),
          FilledButton(
            onPressed: () => context.goNamed('add'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('첫 쿠폰 등록하기'),
          ),
          const SizedBox(height: Space.xs),
          TextButton(
            onPressed: () => context.goNamed('help'),
            child: const Text('사용 방법 자세히 보기'),
          ),
        ],
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({
    required this.index,
    required this.icon,
    required this.title,
    required this.body,
  });

  final int index;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.rowInset,
        vertical: Space.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: const RoundedSuperellipseBorder(
                borderRadius: BorderRadius.all(Radius.circular(Radii.sm)),
              ),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.callout.copyWith(
                    color: colors.label,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  body,
                  style: AppTypography.footnote.copyWith(
                    color: colors.labelSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 웹 체험판 고지.
///
/// 기기 내 인식과 알림은 네이티브 플러그인이라 브라우저에서는 빠진다. 숨기지
/// 않고 먼저 말한다 — 눌러보고 흐려진 버튼을 만나는 것보다 낫다.
class _TrialLimitNote extends StatelessWidget {
  const _TrialLimitNote({required this.missing});

  /// 이 환경에서 빠지는 기능 이름들. 하드코딩하지 않고 실제 capability에서
  /// 만들어 넘긴다 — 예전에는 "갤러리 자동 인식과 만료 알림" 두 개를 손으로
  /// 적어놨고, 같은 화면이 약속하던 밝기 자동 최대화가 목록에서 빠졌다.
  final List<String> missing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: ShapeDecoration(color: colors.fill, shape: AppShapes.card),
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.public_off_rounded,
              size: 18,
              color: colors.labelSecondary,
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: Text(
                '웹 체험판에서 빠지는 기능: ${missing.join(', ')}. '
                '기기 안에서만 도는 부품을 써서 브라우저에 없습니다. '
                '직접 입력으로 나머지 흐름은 그대로 볼 수 있습니다.',
                style: AppTypography.footnote.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
