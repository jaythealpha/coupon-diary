import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/model/coupon.dart';
import '../../domain/repository/coupon_repository.dart';
import '../coupon_json.dart';
import 'in_memory_coupon_repository.dart';

/// 웹 체험판 저장소.
///
/// 개발 전 기능을 직접 써볼 수 있도록, 등록·수정한 쿠폰을 브라우저
/// localStorage(shared_preferences 웹 구현)에 남긴다. 새로고침해도 유지된다.
///
/// 한계를 분명히 한다:
/// - 데이터는 **그 브라우저 안에만** 있다. 다른 기기·브라우저와 공유되지 않는다.
/// - 첫 실행은 **빈 보관함**이다. 데모 쿠폰을 미리 채워두면 자기 쿠폰이
///   섞여 보이고, 처음 보는 화면이 "남의 데이터"라 무엇을 해야 할지 알기
///   어렵다. 대신 빈 화면이 사용 방법을 알려준다.
class _PersistedWebRepository extends InMemoryCouponRepository {
  _PersistedWebRepository(this._prefs, {super.seed, super.usageSeed});

  /// 저장 키에 버전을 붙인다.
  ///
  /// v1 시절에는 첫 실행에 데모 쿠폰 10장을 채워 저장했다. 시딩 코드를 지워도
  /// 이미 저장된 브라우저는 그 10장을 계속 불러온다 — 저장된 상태를 읽는 경로가
  /// 시딩 경로와 별개이기 때문이다. 키를 올려서 예전 체험 데이터를 버린다.
  static const _storageKey = 'web_trial_state_v2';
  static const _legacyKeys = ['web_trial_state_v1'];

  final SharedPreferences _prefs;

  static Future<_PersistedWebRepository> open() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _legacyKeys) {
      if (prefs.containsKey(key)) await prefs.remove(key);
    }
    final stored = prefs.getString(_storageKey);

    if (stored != null) {
      try {
        final json = jsonDecode(stored) as Map<String, dynamic>;
        return _PersistedWebRepository(
          prefs,
          seed: [
            for (final raw in (json['coupons'] as List? ?? const []))
              if (couponFromJson(raw) case final Coupon c) c,
          ],
          usageSeed: [
            for (final raw in (json['usage'] as List? ?? const []))
              if (usageFromJson(raw) case final UsageEntry u) u,
          ],
        );
      } on FormatException {
        // 저장된 상태가 깨졌으면 빈 보관함으로 시작한다. 체험판에서 복구 UI까지
        // 만들 이유는 없다.
      }
    }

    final repository = _PersistedWebRepository(prefs);
    await repository._persist();
    return repository;
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _storageKey,
      jsonEncode({
        'coupons': [for (final c in snapshotCoupons()) couponToJson(c)],
        'usage': [for (final u in snapshotUsage()) usageToJson(u)],
      }),
    );
  }

  @override
  Future<void> save(Coupon coupon) async {
    await super.save(coupon);
    await _persist();
  }

  @override
  Future<void> delete(String id) async {
    await super.delete(id);
    await _persist();
  }

  @override
  Future<void> addUsage(UsageEntry entry) async {
    await super.addUsage(entry);
    await _persist();
  }

  @override
  Future<void> deleteUsage(String usageId) async {
    await super.deleteUsage(usageId);
    await _persist();
  }

  @override
  Future<int> refreshExpiredStatuses(DateTime now) async {
    final changed = await super.refreshExpiredStatuses(now);
    if (changed > 0) await _persist();
    return changed;
  }
}

_PersistedWebRepository? _repository;

Future<CouponRepository> createCouponRepository() async {
  return _repository ??= await _PersistedWebRepository.open();
}

Future<void> closeCouponRepository() async {
  _repository?.dispose();
  _repository = null;
}
