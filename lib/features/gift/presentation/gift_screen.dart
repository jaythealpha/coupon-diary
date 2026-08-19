import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../core/format.dart';
import '../../../design/theme.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/state_views.dart';
import '../../../domain/model/coupon.dart';

/// 쿠폰 재선물.
///
/// 서버 없이 동작해야 하므로 (AGENTS.md 2절 4항) "우리 서비스 안에서 전달"이
/// 아니라 **OS 공유 시트로 이미지와 정보를 넘기는** 방식을 쓴다. 카카오톡·문자
/// 어디로든 보낼 수 있고, 받는 사람이 이 앱을 설치할 필요도 없다.
class GiftScreen extends ConsumerStatefulWidget {
  const GiftScreen({super.key, required this.couponId});

  final String couponId;

  @override
  ConsumerState<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends ConsumerState<GiftScreen> {
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();
  bool _sharing = false;
  String? _recipientError;

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _composeText(Coupon coupon) {
    final message = _messageController.text.trim();
    return [
      if (message.isNotEmpty) message,
      '${coupon.brand} · ${coupon.productName}',
      if (coupon.kind == CouponKind.amount)
        '금액 ${Fmt.won(coupon.balance ?? coupon.faceValue)}',
      '유효기간 ${Fmt.date(coupon.expiresAt)}',
      if (coupon.barcode != null) '쿠폰번호 ${coupon.barcode}',
    ].join('\n');
  }

  Future<void> _share(Coupon coupon) async {
    final recipient = _recipientController.text.trim();
    if (recipient.isEmpty) {
      setState(() => _recipientError = '누구에게 선물하는지 적어주세요. 선물함에서 구분할 때 쓰입니다.');
      return;
    }
    setState(() {
      _recipientError = null;
      _sharing = true;
    });

    try {
      final imagePath = coupon.imagePath;
      final hasImage =
          !kIsWeb && imagePath != null && File(imagePath).existsSync();

      final result = await SharePlus.instance.share(
        ShareParams(
          text: _composeText(coupon),
          subject: '${coupon.brand} 쿠폰 선물',
          files: hasImage ? [XFile(imagePath)] : null,
        ),
      );

      if (!mounted) return;

      // 공유 결과는 세 갈래이고, 셋을 다르게 다뤄야 한다.
      //
      // dismissed  — 사용자가 시트를 닫았다. 확실한 취소다.
      // success    — 확실히 전달됐다.
      // unavailable— **결과를 알 수 없다.** 실패가 아니다. 웹에서는 공유가
      //              성공해도 늘 이 값이고(navigator.share 성공 직후, mailto
      //              폴백 후 모두), 안드로이드에서도 액티비티 없이 띄운 경우
      //              공유는 실제로 시작되지만 결과를 못 받아 이 값이 온다.
      //
      // 예전에는 `!= success`를 전부 취소로 처리해서, 바코드가 담긴 텍스트는
      // 상대에게 실제로 갔는데 쿠폰은 '사용 가능'으로 남았다 — 이미 준 쿠폰을
      // 계산대에서 또 꺼내는 상황이었다. 그렇다고 반대로 다 성공 처리하면
      // 보내지도 않은 쿠폰이 선물함으로 사라진다. 모를 때는 물어본다.
      switch (result.status) {
        case ShareResultStatus.dismissed:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('공유를 취소했습니다. 쿠폰은 그대로 남아 있습니다.')),
          );
        case ShareResultStatus.success:
          await _markAsGifted(coupon, recipient);
        case ShareResultStatus.unavailable:
          final confirmed = await _confirmSent(coupon);
          if (!mounted || confirmed != true) return;
          await _markAsGifted(coupon, recipient);
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  /// 공유 결과를 알 수 없을 때 사용자에게 직접 묻는다.
  ///
  /// 앱이 추측해서 틀리면 두 방향 다 나쁘다 — 안 보냈는데 선물함으로 사라지거나,
  /// 보냈는데 사용 가능으로 남아 이중 사용된다. 사용자는 방금 무엇을 했는지 안다.
  Future<bool?> _confirmSent(Coupon coupon) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('선물로 기록할까요?'),
      content: const Text(
        '공유 창을 띄웠지만 실제로 보냈는지 앱이 확인할 수 없었습니다.\n'
        '보내셨다면 선물함으로 옮겨 이중 사용을 막아드립니다.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('아직 안 보냈어요'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('보냈어요'),
        ),
      ],
    ),
  );

  Future<void> _markAsGifted(Coupon coupon, String recipient) async {
    await ref
        .read(couponRepositoryProvider)
        .save(
          coupon.copyWith(
            status: CouponStatus.gifted,
            giftedTo: recipient,
            giftedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$recipient님에게 선물한 것으로 기록했습니다.'),
        action: SnackBarAction(
          label: '실행 취소',
          onPressed: () {
            ref
                .read(couponRepositoryProvider)
                .save(
                  coupon.copyWith(
                    status: CouponStatus.active,
                    updatedAt: DateTime.now(),
                    clearGift: true,
                  ),
                );
          },
        ),
      ),
    );
    context.goNamed('couponDetail', pathParameters: {'id': coupon.id});
  }

  @override
  Widget build(BuildContext context) {
    final couponAsync = ref.watch(couponDetailProvider(widget.couponId));
    final colors = context.colors;

    return Scaffold(
      appBar: AppTopBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '뒤로',
          onPressed: () => context.canPop()
              ? context.pop()
              : context.goNamed(
                  'couponDetail',
                  pathParameters: {'id': widget.couponId},
                ),
        ),
        title: '선물하기',
      ),
      body: SafeArea(
        child: couponAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => AppErrorState(
            title: '쿠폰을 불러오지 못했습니다',
            description: '잠시 후 다시 시도해주세요.',
            onRetry: () =>
                ref.invalidate(couponDetailProvider(widget.couponId)),
          ),
          data: (coupon) {
            if (coupon == null) {
              return AppEmptyState(
                icon: Icons.search_off,
                title: '삭제된 쿠폰입니다',
                description: '선물하려는 쿠폰을 찾을 수 없습니다.',
                actionLabel: '보관함으로',
                onAction: () => context.goNamed('vault'),
              );
            }

            return ContentWidth(
              child: ListView(
                padding: const EdgeInsets.all(Space.lg),
                children: [
                  _CouponSummary(coupon: coupon),
                  const SizedBox(height: Space.xl),
                  Text('받는 사람', style: AppTypography.sectionHeader),
                  const SizedBox(height: Space.sm),
                  TextField(
                    controller: _recipientController,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_recipientError != null) {
                        setState(() => _recipientError = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: '예: 김서연',
                      errorText: _recipientError,
                      helperText: '선물함에서 누구에게 줬는지 확인할 때 쓰입니다.',
                    ),
                  ),
                  const SizedBox(height: Space.xl),
                  Text('메시지 (선택)', style: AppTypography.sectionHeader),
                  const SizedBox(height: Space.sm),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '생일 축하해! 커피 한 잔 해',
                    ),
                  ),
                  const SizedBox(height: Space.xl),
                  Container(
                    padding: const EdgeInsets.all(Space.lg),
                    decoration: BoxDecoration(
                      color: colors.cautionFill,
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 20,
                          color: colors.caution,
                        ),
                        const SizedBox(width: Space.md),
                        Expanded(
                          child: Text(
                            '보내기 전에 확인하세요. 바코드가 담긴 이미지는 받은 사람이 그대로 '
                            '사용할 수 있고, 중간에 유출되면 되돌릴 수 없습니다. '
                            '오픈 채팅방이나 공개된 곳에는 올리지 마세요.',
                            style: AppTypography.footnote.copyWith(
                              color: colors.caution,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Space.xl),
                  FilledButton.icon(
                    onPressed: _sharing ? null : () => _share(coupon),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    icon: _sharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.ios_share, size: 20),
                    label: Text(_sharing ? '공유 중' : '공유해서 선물하기'),
                  ),
                  const SizedBox(height: Space.sm),
                  OutlinedButton(
                    onPressed: _sharing
                        ? null
                        : () {
                            final recipient = _recipientController.text.trim();
                            if (recipient.isEmpty) {
                              setState(
                                () => _recipientError = '누구에게 선물하는지 적어주세요.',
                              );
                              return;
                            }
                            _markAsGifted(coupon, recipient);
                          },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('이미 다른 방법으로 전달했어요'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CouponSummary extends StatelessWidget {
  const _CouponSummary({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: context.scheme.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: colors.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            coupon.brand,
            style: AppTypography.sectionHeader.copyWith(
              color: colors.labelSecondary,
            ),
          ),
          const SizedBox(height: Space.xxs),
          Text(coupon.productName, style: AppTypography.title3),
          const SizedBox(height: Space.sm),
          Text(
            '유효기간 ${Fmt.date(coupon.expiresAt)}',
            style: AppTypography.footnote.copyWith(
              color: colors.labelSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
