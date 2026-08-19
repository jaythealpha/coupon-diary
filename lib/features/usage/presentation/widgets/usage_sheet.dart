import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/format.dart';
import '../../../../design/theme.dart';
import '../../../../design/tokens.dart';
import '../../../../domain/model/coupon.dart';

sealed class UsageSheetResult {
  const UsageSheetResult();
}

class UsageSheetNotUsed extends UsageSheetResult {
  const UsageSheetNotUsed();
}

class UsageSheetFullyUsed extends UsageSheetResult {
  const UsageSheetFullyUsed();
}

class UsageSheetPartialAmount extends UsageSheetResult {
  const UsageSheetPartialAmount({required this.amount, this.place});
  final int amount;
  final String? place;
}

/// 사용 화면을 나갈 때 뜨는 확인 시트.
///
/// 교환권은 "썼다/안 썼다" 두 갈래로 끝내고, 금액권은 얼마 썼는지까지 받는다.
/// 금액 입력을 강제하지 않는다 — 급할 때 건너뛸 수 있어야 다음에도 이 앱을 쓴다.
class UsageSheet extends StatefulWidget {
  const UsageSheet({super.key, required this.coupon});

  final Coupon coupon;

  @override
  State<UsageSheet> createState() => _UsageSheetState();
}

class _UsageSheetState extends State<UsageSheet> {
  final _amountController = TextEditingController();
  final _placeController = TextEditingController();
  String? _amountError;

  int get _balance => widget.coupon.balance ?? widget.coupon.faceValue ?? 0;

  @override
  void dispose() {
    _amountController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  int? _parseAmount() {
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  void _submitAmount() {
    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      setState(() => _amountError = '사용한 금액을 숫자로 입력해주세요. 예: 4500');
      return;
    }
    if (amount > _balance) {
      setState(
        () => _amountError =
            '잔액(${Fmt.won(_balance)})보다 큰 금액은 기록할 수 없습니다. '
            '금액을 확인하거나 전액 사용을 선택해주세요.',
      );
      return;
    }
    setState(() => _amountError = null);
    Navigator.of(context).pop(
      UsageSheetPartialAmount(
        amount: amount,
        place: _placeController.text.trim().isEmpty
            ? null
            : _placeController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isAmount = widget.coupon.kind == CouponKind.amount;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        0,
        Space.xl,
        MediaQuery.viewInsetsOf(context).bottom + Space.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAmount ? '얼마 사용하셨어요?' : '쿠폰을 사용하셨나요?',
              style: AppTypography.title3,
            ),
            const SizedBox(height: Space.xs),
            Text(
              isAmount
                  ? '기록해두면 잔액이 자동으로 계산됩니다. 나중에 입력해도 괜찮아요.'
                  : '사용 여부를 기록해두면 다음에 헷갈리지 않습니다.',
              style: AppTypography.footnote.copyWith(
                color: colors.labelSecondary,
              ),
            ),
            const SizedBox(height: Space.xl),

            if (isAmount) ...[
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                onSubmitted: (_) => _submitAmount(),
                onChanged: (_) {
                  if (_amountError != null) {
                    setState(() => _amountError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: '사용 금액',
                  suffixText: '원',
                  helperText: '현재 잔액 ${Fmt.won(_balance)}',
                  errorText: _amountError,
                ),
              ),
              const SizedBox(height: Space.md),
              Wrap(
                spacing: Space.sm,
                children: [
                  for (final preset in _presetsFor(_balance))
                    ActionChip(
                      label: Text(Fmt.won(preset)),
                      onPressed: () {
                        _amountController.text = preset.toString();
                        setState(() => _amountError = null);
                      },
                    ),
                ],
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _placeController,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(
                  labelText: '사용처 (선택)',
                  hintText: '예: 스타벅스 강남대로점',
                ),
              ),
              const SizedBox(height: Space.xl),
              FilledButton(
                onPressed: _submitAmount,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text('사용 금액 기록'),
              ),
              const SizedBox(height: Space.sm),
              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pop(const UsageSheetFullyUsed()),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('전액 사용했어요'),
              ),
            ] else
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(const UsageSheetFullyUsed()),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text('네, 사용했어요'),
              ),

            const SizedBox(height: Space.sm),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(const UsageSheetNotUsed()),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('아직 안 썼어요'),
            ),
          ],
        ),
      ),
    );
  }

  /// 잔액보다 큰 값을 눌러 오류가 나는 일이 없도록 잔액 이하만 제안한다.
  List<int> _presetsFor(int balance) =>
      const [3000, 4500, 5000, 6000, 10000].where((v) => v <= balance).toList();
}
