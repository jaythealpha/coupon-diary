import 'package:intl/intl.dart';

import '../domain/model/coupon.dart';

/// 사용자에게 보이는 값의 포맷을 한 곳에 모은다.
/// 화면마다 `NumberFormat`을 새로 만들면 표기가 미묘하게 갈린다.
abstract final class Fmt {
  static final _won = NumberFormat('#,###', 'ko_KR');
  static final _date = DateFormat('yyyy.MM.dd', 'ko_KR');
  static final _dateShort = DateFormat('M월 d일', 'ko_KR');
  static final _dateTime = DateFormat('yyyy.MM.dd HH:mm', 'ko_KR');

  static String won(int? amount) =>
      amount == null ? '-' : '${_won.format(amount)}원';

  static String wonCompact(int? amount) =>
      amount == null ? '-' : _won.format(amount);

  static String date(DateTime? value) =>
      value == null ? '없음' : _date.format(value);

  static String dateShort(DateTime value) => _dateShort.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value);

  /// 만료까지 남은 기간을 사람이 읽는 말로.
  ///
  /// 숫자만 보여주면(D-3) 급한지 아닌지 순간적으로 판단하기 어렵다.
  static String expiryLabel(int? daysLeft) {
    if (daysLeft == null) return '유효기간 없음';
    if (daysLeft < 0) return '${-daysLeft}일 지남';
    if (daysLeft == 0) return '오늘 만료';
    if (daysLeft == 1) return '내일 만료';
    return '$daysLeft일 남음';
  }

  /// 스크린리더용 문장. 시각 배지만으로는 정보가 전달되지 않는다.
  static String couponSemanticLabel(Coupon coupon, DateTime now) {
    final parts = <String>[
      coupon.brand,
      coupon.productName,
      if (coupon.kind == CouponKind.amount)
        '잔액 ${won(coupon.balance)}'
      else
        coupon.kind.label,
      expiryLabel(coupon.daysLeftFrom(now)),
      coupon.status.label,
    ];
    return parts.join(', ');
  }

  /// 바코드 번호를 4자리씩 끊어 읽기 쉽게 만든다.
  static String barcodeGroups(String barcode) {
    final digits = barcode.replaceAll(RegExp(r'\s'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
