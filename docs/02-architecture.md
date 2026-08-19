# 아키텍처

## 계층

```
presentation (화면)  ──▶  application (Provider/컨트롤러)  ──▶  domain (모델 + 리포지토리 인터페이스)
                                                                        ▲
                                                              data (Drift, ML Kit, 알림)
```

- `domain`은 아무것도 의존하지 않는 순수 Dart. 테스트가 쉬운 자리.
- `data`가 `domain`의 인터페이스를 구현한다. 의존성 방향은 항상 안쪽.
- 화면은 Riverpod Provider만 바라본다. 화면이 Drift나 ML Kit를 직접 부르지 않는다.

## 플랫폼 분기 전략

Xcode·Android SDK 없이도 UI를 검증할 수 있어야 하므로, 네이티브 의존 기능은 전부 **조건부 import**로 감싼다.

| 기능 | 네이티브 (`dart.library.io`) | 웹 (검증용) |
|---|---|---|
| DB | Drift + SQLite 파일 | 인메모리 리포지토리 (첫 실행 빈 보관함) |
| OCR | ML Kit 한글 인식 | 스텁 (`isSupported=false`, 빈 결과 — 흉내 내지 않는다) |
| 바코드 인식 | ML Kit 바코드 | 스텁 |
| 화면 밝기 | `screen_brightness` | no-op |
| 알림 | `flutter_local_notifications` | 메모리에 기록만 |

패턴:

```dart
// lib/features/recognition/ocr/coupon_scanner.dart
export 'coupon_scanner_stub.dart'
    if (dart.library.io) 'coupon_scanner_mlkit.dart';
```

이 덕분에 `flutter build web`이 항상 통과하고, 이게 가장 빠른 컴파일 게이트 역할을 한다.

## 데이터 모델

### Coupon

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | String (uuid) | |
| `brand` | String | 브랜드명 (스타벅스, GS25 …) |
| `productName` | String | 상품명 |
| `barcode` | String? | 바코드/교환권 번호 |
| `barcodeFormat` | enum | code128 / qr / ean13 |
| `imagePath` | String? | 앱 샌드박스 내 경로. **절대 외부 전송 안 함** |
| `expiresAt` | DateTime? | |
| `kind` | enum | `exchange`(교환권) / `amount`(금액권) |
| `faceValue` | int? | 금액권 액면가 (원) |
| `balance` | int? | 금액권 잔액 |
| `status` | enum | `active` / `used` / `expired` / `gifted` / `archived` |
| `category` | enum | 카페 / 편의점 / 치킨·피자 / 베이커리 / 외식 / 영화·문화 / 상품권 / 기타 |
| `memo` | String? | |
| `issuer` | String? | 발행사 (카카오톡 선물하기, 기프티쇼 …) |
| `createdAt` / `updatedAt` | DateTime | |

`status`는 파생값이 아니라 저장값이다. 만료는 배치로 갱신한다 — 사용자가 만료 후에도 목록에서 보고 환불(90~95%) 절차를 밟을 수 있어야 하기 때문.

### UsageEntry (금액권 사용 이력)

`id`, `couponId`, `amount`, `usedAt`, `place?`, `memo?`

잔액 = `faceValue - sum(usageEntries.amount)`. 저장된 `balance`는 캐시이고, 이력이 진실.

## 인식 파이프라인

```
이미지
  │
  ├─▶ ML Kit 바코드 스캔 ──▶ 바코드 값 + 포맷
  │
  └─▶ ML Kit 한글 OCR ──▶ 텍스트 블록(위치 포함)
                              │
                              ▼
                    발행사 감지 (issuer fingerprint)
                              │
                              ▼
                    필드 추출 (brand / product / expiry / amount)
                     ├ 발행사별 규칙 우선
                     └ 실패 시 범용 정규식
                              │
                              ▼
                    신뢰도 산출 → 낮으면 사용자 확인 폼 강조
                              │
                    (설정에서 켠 경우에만)
                              ▼
                    (LLM 보정은 1.0에서 제외 — 서버 없는 원칙을 지킨다)
```

발행사 규칙은 `lib/features/recognition/parsing/issuer_rules.dart`에 표로 모아둔다. Codex가 규칙을 늘리기 좋은 형태로 유지한다.

## 알림 전략

| 시점 | 내용 |
|---|---|
| D-30 / D-7 / D-3 / D-1 | 개별 쿠폰 만료 임박 |
| (1.1 예정) | 주간 다이제스트 — 미구현 |
| 위치 진입 (Pro) | 해당 브랜드 매장 반경 진입 시 |

알림 피로를 막기 위해 하루 최대 1건으로 합친다. 여러 건이면 다이제스트로 묶는다.

## 보안

- 앱 잠금: **1.0에서 제외.** 실행 시 인증 게이트를 배선하지 않아 스위치만 있고 효과가 없었다. 1.1로 미룬다.
- 이미지: 앱 샌드박스 내부에만 저장. 갤러리에 되쓰지 않는다.
- 백업: 기본 꺼짐. 켜면 AES-GCM으로 암호화한 단일 파일을 사용자가 고른 위치(iCloud/Drive/파일앱)에 내보낸다. 키는 사용자 암호에서 유도.
- 공유 화면 캡처 방지: Android `FLAG_SECURE` — **미구현(1.1 예정)**. 바코드 도용 대응책으로 검토만 했다.
