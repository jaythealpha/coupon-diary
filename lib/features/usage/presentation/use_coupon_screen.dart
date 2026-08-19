import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/format.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/state_views.dart';
import '../../../domain/model/coupon.dart';
import '../brightness/brightness_control.dart';
import 'widgets/usage_sheet.dart';

/// 매장에서 바코드를 보여주는 화면.
///
/// 이 앱의 하이라이트다. 계산대 앞 몇 초 안에 끝나야 하므로 원칙이 셋이다.
/// 1. **아무것도 방해하지 않는다.** 흰 배경, 최대 밝기, 큰 바코드.
/// 2. **한 장의 패스처럼 보인다.** Apple Wallet처럼 카드 하나에 필요한 정보를
///    모두 담아, 화면에 흩어진 텍스트를 눈으로 훑지 않아도 되게 한다.
/// 3. **다크 모드에서도 흰 배경.** 스캐너 인식률이 사용자 취향보다 우선한다.
class UseCouponScreen extends ConsumerStatefulWidget {
  const UseCouponScreen({super.key, required this.couponId});

  final String couponId;

  @override
  ConsumerState<UseCouponScreen> createState() => _UseCouponScreenState();
}

class _UseCouponScreenState extends ConsumerState<UseCouponScreen> {
  final _brightness = BrightnessControl();
  bool _askedForUsage = false;

  @override
  void initState() {
    super.initState();
    _brightness.boost();
  }

  @override
  void dispose() {
    _brightness.restore();
    super.dispose();
  }

  /// 화면을 벗어날 때 "쓰셨어요?"를 묻는다.
  ///
  /// 경쟁 앱의 가장 흔한 불만이 "사용완료를 안 눌러서 뭘 썼는지 모르겠다"였다.
  /// 사용자가 버튼을 기억해서 누르게 하지 말고, 나가는 길목에서 물어본다.
  Future<void> _handleExit(Coupon coupon) async {
    if (_askedForUsage) {
      _leave();
      return;
    }
    _askedForUsage = true;

    final result = await showModalBottomSheet<UsageSheetResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => UsageSheet(coupon: coupon),
    );

    if (!mounted) return;

    if (result == null) {
      // 시트를 그냥 닫은 경우. 아무것도 바꾸지 않고 상세로 돌아간다.
      _leave();
      return;
    }

    final repository = ref.read(couponRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);

    switch (result) {
      case UsageSheetNotUsed():
        _leave();
      case UsageSheetFullyUsed():
        await repository.save(
          coupon.copyWith(status: CouponStatus.used, updatedAt: DateTime.now()),
        );
        messenger.showSnackBar(const SnackBar(content: Text('사용 완료로 기록했습니다.')));
        _leave();
      case UsageSheetPartialAmount(:final amount, :final place):
        await repository.addUsage(
          UsageEntry(
            id: 'usage-${DateTime.now().microsecondsSinceEpoch}',
            couponId: coupon.id,
            amount: amount,
            usedAt: DateTime.now(),
            place: place,
          ),
        );
        messenger.showSnackBar(
          SnackBar(content: Text('${Fmt.won(amount)} 사용을 기록했습니다.')),
        );
        _leave();
    }
  }

  void _leave() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('couponDetail', pathParameters: {'id': widget.couponId});
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponAsync = ref.watch(couponDetailProvider(widget.couponId));

    return couponAsync.when(
      loading: () => const Scaffold(backgroundColor: _UseView._page),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('사용하기')),
        body: AppErrorState(
          title: '쿠폰을 불러오지 못했습니다',
          description: '잠시 후 다시 시도해주세요.',
          onRetry: () => ref.invalidate(couponDetailProvider(widget.couponId)),
        ),
      ),
      data: (coupon) {
        if (coupon == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('사용하기')),
            body: AppEmptyState(
              icon: Icons.search_off_rounded,
              title: '삭제된 쿠폰입니다',
              description: '이미 삭제되었거나 존재하지 않는 쿠폰입니다.',
              actionLabel: '보관함으로',
              onAction: () => context.goNamed('vault'),
            ),
          );
        }
        return _UseView(coupon: coupon, onExit: () => _handleExit(coupon));
      },
    );
  }
}

class _UseView extends StatelessWidget {
  const _UseView({required this.coupon, required this.onExit});

  final Coupon coupon;
  final VoidCallback onExit;

  /// 이 화면 전용 색. 다크 모드와 무관하게 고정한다.
  ///
  /// 바탕은 순백이 아니라 아주 옅은 회색이다. 순백 위에 흰 카드를 올리면
  /// 절취선 아래 바코드 영역이 배경과 붙어 카드가 두 조각으로 보였다.
  /// 바코드가 놓이는 면 자체는 순백을 유지하므로 인식률은 그대로다.
  static const _ink = Color(0xFF0B0B0F);
  static const _inkMuted = Color(0xFF6B6B76);
  static const _page = Color(0xFFEDEDF2);
  static const _cardBase = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final barcode = coupon.barcode;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onExit();
      },
      child: Scaffold(
        backgroundColor: _page,
        appBar: AppBar(
          backgroundColor: _page,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: _ink),
            tooltip: '닫기',
            onPressed: onExit,
          ),
          title: Text(
            '사용하기',
            style: AppTypography.headline.copyWith(color: _ink),
          ),
        ),
        body: SafeArea(
          child: ContentWidth(
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        Space.xl,
                        Space.sm,
                        Space.xl,
                        Space.xl,
                      ),
                      child: ConstrainedBox(
                        // 짧으면 가운데, 길면 그냥 스크롤. 계산대에서 팔을 들어
                        // 보여주는 화면이라 카드가 위에 붙어 있으면 손목을 꺾게 된다.
                        constraints: BoxConstraints(
                          minHeight:
                              constraints.maxHeight - Space.sm - Space.xl,
                        ),
                        child: Center(
                          child: _PassCard(coupon: coupon, barcode: barcode),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.xl,
                    0,
                    Space.xl,
                    Space.xl,
                  ),
                  child: FilledButton(
                    onPressed: onExit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: _ink,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('사용 완료'),
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

/// Wallet 패스 한 장. 상단은 정보, 하단은 바코드로 나뉜다.
class _PassCard extends StatelessWidget {
  const _PassCard({required this.coupon, required this.barcode});

  final Coupon coupon;
  final String? barcode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: _UseView._cardBase,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.xxl)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.xl,
              Space.xl,
              Space.xl,
              Space.lg,
            ),
            child: Column(
              children: [
                Text(
                  coupon.brand,
                  style: AppTypography.footnote.copyWith(
                    color: _UseView._inkMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  coupon.productName,
                  style: AppTypography.title2.copyWith(color: _UseView._ink),
                  textAlign: TextAlign.center,
                ),
                if (coupon.kind == CouponKind.amount) ...[
                  const SizedBox(height: Space.md),
                  Text(
                    Fmt.won(coupon.balance ?? coupon.faceValue),
                    style: AppTypography.numericDisplay.copyWith(
                      color: _UseView._ink,
                    ),
                  ),
                  Text(
                    '남은 금액',
                    style: AppTypography.caption.copyWith(
                      color: _UseView._inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 티켓의 뜯는 선. 양옆이 파여 실제 쿠폰처럼 보인다.
          const _TicketNotch(),

          // 바코드는 반드시 순백 위에 올린다. 회색 바탕은 인식률을 떨어뜨린다.
          Container(
            width: double.infinity,
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(Radii.xxl),
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              Space.xl,
              Space.xl,
              Space.xl,
              Space.lg,
            ),
            child: barcode == null || barcode!.isEmpty
                ? const _NoBarcodeNotice()
                : _BarcodeArea(value: barcode!, format: coupon.barcodeFormat),
          ),
        ],
      ),
    );
  }
}

/// 티켓 절취선. 좌우에 반원을 파고 가운데를 점선으로 잇는다.
class _TicketNotch extends StatelessWidget {
  const _TicketNotch();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          const _Notch(isLeft: true),
          Expanded(
            child: CustomPaint(
              painter: _DashedLinePainter(),
              size: const Size(double.infinity, 24),
            ),
          ),
          const _Notch(isLeft: false),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch({required this.isLeft});

  final bool isLeft;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 12,
    height: 24,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: _UseView._page,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? Radius.zero : const Radius.circular(12),
          right: isLeft ? const Radius.circular(12) : Radius.zero,
        ),
      ),
    ),
  );
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCFCFD8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dash = 5.0;
    const gap = 5.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarcodeArea extends StatelessWidget {
  const _BarcodeArea({required this.value, required this.format});

  final String value;
  final BarcodeFormat format;

  @override
  Widget build(BuildContext context) {
    final isQr = format == BarcodeFormat.qr;

    return Column(
      children: [
        Semantics(
          label: '쿠폰 바코드. 번호 ${Fmt.barcodeGroups(value)}',
          child: isQr
              ? BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: value,
                  width: 208,
                  height: 208,
                  drawText: false,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                )
              : BarcodeWidget(
                  barcode: _toBarcode(format),
                  data: value,
                  height: 140,
                  drawText: false,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  errorBuilder: (context, error) => _BarcodeError(value: value),
                ),
        ),
        const SizedBox(height: Space.lg),
        SelectableText(
          Fmt.barcodeGroups(value),
          style: AppTypography.numeric.copyWith(
            color: _UseView._ink,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: Space.xs),
        TextButton.icon(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await Clipboard.setData(ClipboardData(text: value));
            messenger.showSnackBar(
              const SnackBar(content: Text('쿠폰번호를 복사했습니다.')),
            );
          },
          icon: const Icon(Icons.copy_rounded, size: 16),
          label: const Text('번호 복사'),
          style: TextButton.styleFrom(foregroundColor: _UseView._inkMuted),
        ),
      ],
    );
  }

  Barcode _toBarcode(BarcodeFormat format) => switch (format) {
    BarcodeFormat.ean13 => Barcode.ean13(),
    BarcodeFormat.qr => Barcode.qrCode(),
    // 포맷을 모를 때 CODE128이 가장 안전하다. 길이 제약이 없고 한국 기프티콘의
    // 대다수가 실제로 CODE128이다.
    _ => Barcode.code128(),
  };
}

/// 바코드 데이터가 선택한 포맷 규격에 맞지 않는 경우(예: EAN-13인데 13자리가
/// 아님). 화면을 비워두지 않고 번호라도 크게 보여준다.
class _BarcodeError extends StatelessWidget {
  const _BarcodeError({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Icon(
        Icons.error_outline_rounded,
        color: AppColors.lightCaution,
        size: 24,
      ),
      const SizedBox(height: Space.sm),
      Text(
        '바코드를 그릴 수 없는 형식입니다.\n아래 번호를 직원에게 보여주세요.',
        textAlign: TextAlign.center,
        style: AppTypography.footnote.copyWith(color: _UseView._inkMuted),
      ),
      const SizedBox(height: Space.md),
      SelectableText(
        Fmt.barcodeGroups(value),
        style: AppTypography.numericDisplay.copyWith(color: _UseView._ink),
      ),
    ],
  );
}

class _NoBarcodeNotice extends StatelessWidget {
  const _NoBarcodeNotice();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Space.xl),
    child: Column(
      children: [
        const Icon(
          Icons.qr_code_2_rounded,
          size: 36,
          color: AppColors.lightCaution,
        ),
        const SizedBox(height: Space.md),
        Text(
          '바코드가 등록되어 있지 않습니다',
          style: AppTypography.headline.copyWith(color: _UseView._ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Space.xs),
        Text(
          '쿠폰 수정 화면에서 번호를 입력하면 여기에 바로 보여드립니다.',
          style: AppTypography.footnote.copyWith(color: _UseView._inkMuted),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
