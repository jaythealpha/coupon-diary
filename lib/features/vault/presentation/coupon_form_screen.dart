import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/format.dart';
import '../../../design/theme.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/state_views.dart';
import '../../../domain/model/coupon.dart';
import '../../recognition/parsing/coupon_parser.dart';

/// 쿠폰 등록·수정 폼.
///
/// 인식 결과를 그대로 저장해버리지 않고 반드시 이 화면을 거친다. OCR이 틀렸을 때
/// 사용자가 알아챌 마지막 지점이기 때문이다. 신뢰도가 낮은 필드는 시각적으로
/// 강조해서 확인을 유도한다.
class CouponFormScreen extends ConsumerStatefulWidget {
  const CouponFormScreen({
    super.key,
    this.couponId,
    this.parsed,
    this.imagePath,
  });

  /// null이면 신규 등록.
  final String? couponId;

  /// 인식 결과에서 넘어온 초기값.
  final ParsedCoupon? parsed;

  final String? imagePath;

  @override
  ConsumerState<CouponFormScreen> createState() => _CouponFormScreenState();
}

class _CouponFormScreenState extends ConsumerState<CouponFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _productController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _faceValueController = TextEditingController();
  final _issuerController = TextEditingController();
  final _memoController = TextEditingController();

  CouponKind _kind = CouponKind.exchange;
  CouponCategory _category = CouponCategory.etc;
  BarcodeFormat _barcodeFormat = BarcodeFormat.code128;
  DateTime? _expiresAt;
  Coupon? _existing;
  bool _loaded = false;
  bool _saving = false;

  bool get _isEdit => widget.couponId != null;

  @override
  void initState() {
    super.initState();
    final parsed = widget.parsed;
    if (parsed != null) _applyParsed(parsed);
    if (_isEdit) {
      _loadExisting();
    } else {
      _loaded = true;
    }
  }

  void _applyParsed(ParsedCoupon parsed) {
    _brandController.text = parsed.brand ?? '';
    _productController.text = parsed.productName ?? '';
    _barcodeController.text = parsed.barcode ?? '';
    _faceValueController.text = parsed.faceValue?.toString() ?? '';
    _issuerController.text = parsed.issuer ?? '';
    _kind = parsed.kind;
    _category = parsed.category;
    _expiresAt = parsed.expiresAt;
    if (parsed.barcodeFormat != BarcodeFormat.unknown) {
      _barcodeFormat = parsed.barcodeFormat;
    }
  }

  Future<void> _loadExisting() async {
    final coupon = await ref
        .read(couponRepositoryProvider)
        .findById(widget.couponId!);
    if (!mounted) return;
    setState(() {
      _existing = coupon;
      _loaded = true;
      if (coupon != null) {
        _brandController.text = coupon.brand;
        _productController.text = coupon.productName;
        _barcodeController.text = coupon.barcode ?? '';
        _faceValueController.text = coupon.faceValue?.toString() ?? '';
        _issuerController.text = coupon.issuer ?? '';
        _memoController.text = coupon.memo ?? '';
        _kind = coupon.kind;
        _category = coupon.category;
        _barcodeFormat = coupon.barcodeFormat == BarcodeFormat.unknown
            ? BarcodeFormat.code128
            : coupon.barcodeFormat;
        _expiresAt = coupon.expiresAt;
      }
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _productController.dispose();
    _barcodeController.dispose();
    _faceValueController.dispose();
    _issuerController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  bool _needsReview(ParsedField field) =>
      widget.parsed?.isLowConfidence(field) ?? false;

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 30)),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
      helpText: '유효기간 선택',
      cancelText: '취소',
      confirmText: '확인',
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      // 첫 오류 필드로 스크롤·포커스가 가도록 프레임워크에 맡긴다.
      return;
    }
    setState(() => _saving = true);

    final now = DateTime.now();
    final faceValue = _kind == CouponKind.amount
        ? int.tryParse(
            _faceValueController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          )
        : null;

    final existing = _existing;
    final coupon = Coupon(
      id: existing?.id ?? 'coupon-${now.microsecondsSinceEpoch}',
      brand: _brandController.text.trim(),
      productName: _productController.text.trim(),
      kind: _kind,
      status: existing?.status ?? CouponStatus.active,
      category: _category,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      barcodeFormat: _barcodeFormat,
      imagePath: widget.imagePath ?? existing?.imagePath,
      expiresAt: _expiresAt,
      faceValue: faceValue,
      // 금액권으로 새로 만들 때 잔액은 액면가에서 시작한다. 수정일 때는 이미
      // 쌓인 사용 이력이 있으므로 기존 잔액을 건드리지 않는다.
      balance: _kind == CouponKind.amount
          ? (existing?.balance ?? faceValue)
          : null,
      memo: _memoController.text.trim().isEmpty
          ? null
          : _memoController.text.trim(),
      issuer: _issuerController.text.trim().isEmpty
          ? null
          : _issuerController.text.trim(),
      giftedTo: existing?.giftedTo,
      giftedAt: existing?.giftedAt,
    );

    await ref.read(couponRepositoryProvider).save(coupon);
    if (!mounted) return;

    // 스낵바를 띄우지 않는다. 저장한 쿠폰의 상세 화면으로 바로 넘어가는 것이
    // 더 분명한 확인이고, 무엇보다 떠 있는 스낵바가 하단의 "사용하기" 버튼을
    // 덮어 등록 직후 바로 쓰려는 사람의 탭을 먹어버린다.
    context.goNamed('couponDetail', pathParameters: {'id': coupon.id});
  }

  @override
  Widget build(BuildContext context) {
    final notificationsSupported = ref.watch(notificationsSupportedProvider);
    final colors = context.colors;

    if (!_loaded) {
      return Scaffold(
        appBar: AppTopBar(title: _isEdit ? '쿠폰 수정' : '쿠폰 등록'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isEdit && _existing == null) {
      return Scaffold(
        appBar: const AppTopBar(title: '쿠폰 수정'),
        body: AppEmptyState(
          icon: Icons.search_off,
          title: '삭제된 쿠폰입니다',
          description: '수정하려는 쿠폰을 찾을 수 없습니다.',
          actionLabel: '보관함으로',
          onAction: () => context.goNamed('vault'),
        ),
      );
    }

    final reviewFields = widget.parsed?.fieldsNeedingReview ?? const [];

    return Scaffold(
      appBar: AppTopBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: '닫기',
          onPressed: () =>
              context.canPop() ? context.pop() : context.goNamed('vault'),
        ),
        title: _isEdit ? '쿠폰 수정' : '쿠폰 등록',
      ),
      body: SafeArea(
        child: ContentWidth(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(Space.lg),
                    children: [
                      if (reviewFields.isNotEmpty) ...[
                        _ReviewNotice(fields: reviewFields),
                        const SizedBox(height: Space.lg),
                      ],
                      _Field(
                        label: '브랜드',
                        required: true,
                        highlight: _needsReview(ParsedField.brand),
                        child: TextFormField(
                          key: const Key('field_brand'),
                          controller: _brandController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: '예: 스타벅스',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? '브랜드를 입력해주세요. 보관함에서 쿠폰을 찾을 때 쓰입니다.'
                              : null,
                        ),
                      ),
                      _Field(
                        label: '상품명',
                        required: true,
                        highlight: _needsReview(ParsedField.productName),
                        child: TextFormField(
                          key: const Key('field_product'),
                          controller: _productController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: '예: 아이스 카페 아메리카노 T',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? '상품명을 입력해주세요.'
                              : null,
                        ),
                      ),
                      _Field(
                        label: '쿠폰 종류',
                        // 폭을 채우지 않으면 세그먼트가 라벨보다 좁게 잡혀
                        // 글자가 줄바꿈되며 잘린다.
                        child: SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<CouponKind>(
                            segments: const [
                              ButtonSegment(
                                value: CouponKind.exchange,
                                label: Text('교환권'),
                              ),
                              ButtonSegment(
                                value: CouponKind.amount,
                                label: Text('금액권'),
                              ),
                            ],
                            selected: {_kind},
                            showSelectedIcon: false,
                            onSelectionChanged: (value) =>
                                setState(() => _kind = value.first),
                          ),
                        ),
                      ),
                      if (_kind == CouponKind.amount)
                        _Field(
                          label: '액면가',
                          required: true,
                          highlight: _needsReview(ParsedField.faceValue),
                          helper: '금액권은 액면가를 알아야 잔액을 계산할 수 있습니다.',
                          child: TextFormField(
                            key: const Key('field_face_value'),
                            controller: _faceValueController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              hintText: '30000',
                              suffixText: '원',
                            ),
                            validator: (value) {
                              if (_kind != CouponKind.amount) return null;
                              final amount = int.tryParse(value ?? '');
                              if (amount == null || amount <= 0) {
                                return '액면가를 숫자로 입력해주세요. 예: 30000';
                              }
                              return null;
                            },
                          ),
                        ),
                      _Field(
                        label: '유효기간',
                        highlight: _needsReview(ParsedField.expiresAt),
                        // 웹은 알림 부품이 없다. 그런데 웹에서는 자동 인식이
                        // 막혀 있어 이 폼이 **유일한 등록 경로**다 — 모든 웹
                        // 사용자가 이 문장을 본다. 환경을 보고 말을 바꾼다.
                        helper: notificationsSupported
                            ? '만료 30·7·3·1일 전에 알려드립니다. 비워두면 알림이 오지 않습니다.'
                            : '지난 쿠폰은 “사용·만료” 탭으로 내려갑니다. '
                                  '만료 알림은 앱(iOS·Android)에서만 옵니다.',
                        child: _ExpiryPicker(
                          value: _expiresAt,
                          onPick: _pickExpiry,
                          onClear: () => setState(() => _expiresAt = null),
                        ),
                      ),
                      _Field(
                        label: '카테고리',
                        child: DropdownButtonFormField<CouponCategory>(
                          initialValue: _category,
                          items: [
                            for (final category in CouponCategory.values)
                              DropdownMenuItem(
                                value: category,
                                child: Text(category.label),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _category = value ?? _category),
                        ),
                      ),
                      _Field(
                        label: '쿠폰번호',
                        helper: '기기 안에만 저장되며 어디로도 전송되지 않습니다.',
                        child: Column(
                          children: [
                            TextFormField(
                              key: const Key('field_barcode'),
                              controller: _barcodeController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                hintText: '바코드 아래 숫자',
                              ),
                            ),
                            const SizedBox(height: Space.sm),
                            DropdownButtonFormField<BarcodeFormat>(
                              initialValue: _barcodeFormat,
                              decoration: const InputDecoration(
                                labelText: '바코드 형식',
                              ),
                              items: [
                                for (final format in BarcodeFormat.values)
                                  DropdownMenuItem(
                                    value: format,
                                    child: Text(format.label),
                                  ),
                              ],
                              onChanged: (value) => setState(
                                () => _barcodeFormat = value ?? _barcodeFormat,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _Field(
                        label: '발행처',
                        child: TextFormField(
                          key: const Key('field_issuer'),
                          controller: _issuerController,
                          decoration: const InputDecoration(
                            hintText: '예: 카카오톡 선물하기',
                          ),
                        ),
                      ),
                      _Field(
                        label: '메모',
                        child: TextFormField(
                          key: const Key('field_memo'),
                          controller: _memoController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: '누구에게 받았는지, 언제 쓸지 등',
                          ),
                        ),
                      ),
                      const SizedBox(height: Space.x3l),
                    ],
                  ),
                ),
                Container(
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
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEdit ? '수정 완료' : '등록하기'),
                    ),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.child,
    this.required = false,
    this.helper,
    this.highlight = false,
  });

  final String label;
  final Widget child;
  final bool required;
  final String? helper;

  /// 인식 신뢰도가 낮아 사용자 확인이 필요한 필드.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTypography.sectionHeader),
              if (required)
                Text(
                  ' *',
                  style: AppTypography.sectionHeader.copyWith(
                    color: context.scheme.error,
                  ),
                ),
              if (highlight) ...[
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
          const SizedBox(height: Space.sm),
          child,
          if (helper != null) ...[
            const SizedBox(height: Space.xs),
            Text(
              helper!,
              style: AppTypography.caption.copyWith(
                color: colors.labelSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpiryPicker extends StatelessWidget {
  const _ExpiryPicker({
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value == null ? '날짜 선택' : Fmt.date(value),
                style: AppTypography.subhead.copyWith(
                  color: value == null ? colors.labelTertiary : null,
                ),
              ),
            ),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
            ),
          ),
        ),
        if (value != null) ...[
          const SizedBox(width: Space.sm),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close),
            tooltip: '유효기간 지우기',
          ),
        ],
      ],
    );
  }
}

class _ReviewNotice extends StatelessWidget {
  const _ReviewNotice({required this.fields});

  final List<ParsedField> fields;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labels = fields.map(_labelOf).join(', ');

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '자동 인식이 확실하지 않은 항목이 있어요',
                  style: AppTypography.sectionHeader.copyWith(
                    color: colors.caution,
                  ),
                ),
                const SizedBox(height: Space.xxs),
                Text(
                  '$labels 항목을 확인해주세요. 특히 유효기간이 틀리면 알림이 엉뚱한 날에 옵니다.',
                  style: AppTypography.footnote.copyWith(color: colors.caution),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _labelOf(ParsedField field) => switch (field) {
    ParsedField.brand => '브랜드',
    ParsedField.productName => '상품명',
    ParsedField.expiresAt => '유효기간',
    ParsedField.faceValue => '액면가',
    ParsedField.kind => '쿠폰 종류',
    ParsedField.barcode => '쿠폰번호',
  };
}
