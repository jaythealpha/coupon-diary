import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repository/repository_factory.dart';
import '../domain/model/coupon.dart';
import '../domain/repository/coupon_repository.dart';
import '../features/usage/brightness/brightness_control.dart';
import '../features/notification/notification_service.dart';
import '../features/recognition/ocr/coupon_scanner.dart';
import '../features/recognition/ocr/scan_types.dart';
import '../features/recognition/parsing/coupon_parser.dart';

/// `main()`에서 실제 구현으로 덮어쓴다.
///
/// `FutureProvider`로 두지 않은 이유: 저장소는 앱이 뜨기 전에 준비되는 것이
/// 확실하고, 화면마다 `AsyncValue`를 한 겹 더 벗기게 만들면 로딩 상태 처리가
/// 의미 없이 복잡해진다.
final couponRepositoryProvider = Provider<CouponRepository>(
  (ref) => throw UnimplementedError('main()에서 override 해야 합니다'),
);

Future<CouponRepository> initCouponRepository() => createCouponRepository();

/// 스캐너. 웹에서는 `isSupported == false`인 스텁이 온다.
final couponScannerProvider = Provider<CouponScanner>((ref) {
  final scanner = PlatformCouponScanner();
  ref.onDispose(scanner.dispose);
  return scanner;
});

final scannerSupportedProvider = Provider<bool>((ref) {
  final scanner = ref.watch(couponScannerProvider);
  return scanner is ScannerCapability &&
      (scanner as ScannerCapability).isSupported;
});

/// 화면 밝기를 앱이 올릴 수 있는가. 웹은 불가.
///
/// 예전에는 `BrightnessControl.isSupported`가 정의만 되어 있고 **읽는 화면
/// 코드가 하나도 없었다.** 그래서 "밝기를 최대로 올려드립니다"라는 문구가
/// 웹에서도 무조건 나갔다. 분기할 수단이 없으면 문구는 반드시 거짓말이 된다.
final brightnessSupportedProvider = Provider<bool>(
  (ref) => BrightnessControl().isSupported,
);

/// 만료 알림을 이 환경에서 걸 수 있는가. 웹은 불가.
final notificationsSupportedProvider = Provider<bool>(
  (ref) => NotificationService().isSupported,
);

final couponParserProvider = Provider<CouponParser>(
  (ref) => const CouponParser(),
);

/// "오늘"의 기준 시각.
///
/// 테스트에서 고정하기 쉽게 provider로 뺐다. `autoDispose`가 핵심이다 —
/// 일반 Provider로 두면 앱 수명 내내 첫 값을 캐시해서, 자정을 넘겨 앱을 켜 둔
/// 채로 두면 "1일 남음"이 다음 날에도 그대로 남는다. 만료 임박이 이 앱의
/// 존재 이유라 하루치 오표시는 치명적이다.
final nowProvider = Provider.autoDispose<DateTime>((ref) => DateTime.now());

/// 보관함 조회 조건.
class VaultQueryNotifier extends Notifier<CouponQuery> {
  @override
  CouponQuery build() => const CouponQuery();

  void setKeyword(String value) => state = state.copyWith(keyword: value);

  void setSort(CouponSort sort) => state = state.copyWith(sort: sort);

  void setStatuses(Set<CouponStatus> statuses) =>
      state = state.copyWith(statuses: statuses);

  void toggleCategory(CouponCategory category) {
    final next = {...state.categories};
    if (!next.remove(category)) next.add(category);
    state = state.copyWith(categories: next);
  }

  void clearFilters() => state = CouponQuery(sort: state.sort);
}

final vaultQueryProvider = NotifierProvider<VaultQueryNotifier, CouponQuery>(
  VaultQueryNotifier.new,
);

final vaultCouponsProvider = StreamProvider.autoDispose<List<Coupon>>((ref) {
  final repository = ref.watch(couponRepositoryProvider);
  final query = ref.watch(vaultQueryProvider);
  return repository.watchCoupons(query);
});

/// 보관함이 통째로 비었는지. 상태 탭·검색·필터와 무관하게 전체를 본다.
///
/// 첫 실행에는 검색창과 상태 탭을 감춘다. 검색할 것도, 넘어갈 탭도 없는데
/// 컨트롤만 늘어놓으면 안내가 아래로 밀리고 앱이 복잡해 보인다.
final vaultIsEmptyProvider = StreamProvider.autoDispose<bool>((ref) {
  final repository = ref.watch(couponRepositoryProvider);
  return repository.watchCoupons(const CouponQuery()).map((c) => c.isEmpty);
});

/// 홈 상단 "곧 만료" 배너용. 보관함 필터와 무관하게 항상 활성 쿠폰 전체를 본다.
final expiringSoonProvider = StreamProvider.autoDispose<List<Coupon>>((ref) {
  final repository = ref.watch(couponRepositoryProvider);
  final now = ref.watch(nowProvider);
  return repository
      .watchCoupons(const CouponQuery(sort: CouponSort.expiryAsc))
      .map(
        (coupons) =>
            coupons.where((c) => c.isExpiringSoon(now, withinDays: 7)).toList(),
      );
});

final couponDetailProvider = StreamProvider.autoDispose.family<Coupon?, String>(
  (ref, id) {
    return ref.watch(couponRepositoryProvider).watchCoupon(id);
  },
);

final couponUsageProvider = StreamProvider.autoDispose
    .family<List<UsageEntry>, String>((ref, couponId) {
      return ref.watch(couponRepositoryProvider).watchUsage(couponId);
    });
