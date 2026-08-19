# 출시 절차

목표: App Store와 Google Play에 **쿠폰다이어리 1.0.0** 출시.

이 문서는 순서대로 따라가는 체크리스트다. 각 항목에 **누가** 해야 하는지 표시했다.
`(사용자)`는 계정·결제·법적 동의가 필요해 대신 수행할 수 없는 단계다.

---

## 0. 현재 상태

| 항목 | 상태 |
|---|---|
| 앱 코드 (Flutter) | 완료 |
| `flutter analyze` | 무경고 |
| 단위·위젯 테스트 | 52개 통과 |
| 웹 릴리스 빌드 (UI 검증용) | 통과 |
| 앱 아이콘 | 생성 완료 (Android/iOS 전 사이즈) |
| iOS/Android 권한 설정 | 완료 |
| 릴리스 서명 설정 | 코드 준비 완료, 키 생성 필요 |
| **iOS 빌드** | **불가 — Xcode 미설치** |
| **Android 빌드** | **불가 — JDK·Android SDK 미설치** |

이 개발 환경에는 Xcode(Command Line Tools만 있음)와 Android SDK가 없다.
아래 1단계를 마쳐야 실제 스토어에 올릴 바이너리를 만들 수 있다.

---

## 1. 개발 도구 설치 `(사용자)`

두 설치 모두 관리자 암호가 필요하고 용량이 커서 직접 진행해야 한다.

### Xcode (iOS)

App Store에서 Xcode를 설치한 뒤:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

```bash
sudo xcodebuild -runFirstLaunch
```

CocoaPods 설치:

```bash
sudo gem install cocoapods
```

### Android Studio (Android)

[developer.android.com/studio](https://developer.android.com/studio)에서 설치하고 첫 실행 시
SDK 설치 마법사를 완료한다. 그 다음 라이선스에 동의한다.

```bash
flutter doctor --android-licenses
```

### 확인

```bash
flutter doctor
```

Android toolchain과 Xcode 항목이 모두 ✓ 가 되어야 다음 단계로 갈 수 있다.

---

## 2. 개발자 계정 등록 `(사용자)`

| 스토어 | 비용 | 소요 |
|---|---|---|
| [Apple Developer Program](https://developer.apple.com/programs/) | 연 $99 | 승인까지 1~2일 |
| [Google Play Console](https://play.google.com/console/signup) | 1회 $25 | 신원 확인까지 최대 며칠 |

Google Play는 2023년 이후 개인 개발자에게 **출시 전 20명 비공개 테스트 14일**을
요구한다. 일정에 반드시 반영한다.

---

## 3. Android 서명 키 `(사용자)`

키스토어를 만든다. 이 키를 잃어버리면 **같은 앱으로 업데이트를 영원히 올릴 수 없다.**
비밀번호는 암호 관리자에 보관한다.

```bash
keytool -genkey -v -keystore ~/coupon-diary-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`android/key.properties` 파일을 만든다 (이미 `.gitignore`에 포함되어 있다).

```properties
storePassword=<위에서 정한 비밀번호>
keyPassword=<위에서 정한 비밀번호>
keyAlias=upload
storeFile=/Users/jay/coupon-diary-upload.jks
```

이 파일이 없으면 릴리스 빌드는 디버그 키로 서명된다 (`android/app/build.gradle.kts` 참고).
스토어 업로드 전에 반드시 만들어야 한다.

---

## 4. iOS 서명 `(사용자)`

Xcode에서 `ios/Runner.xcworkspace`를 열고:

1. Runner 타깃 → Signing & Capabilities
2. Team을 본인 개발자 계정으로 지정
3. Bundle Identifier가 `com.coupondiary.couponDiary`인지 확인
   (Apple Developer 포털의 App ID와 일치해야 한다)
4. Automatically manage signing 체크

---

## 5. 빌드

도구 설치 후에는 아래 명령으로 스토어 제출용 바이너리가 나온다.

Android App Bundle:

```bash
flutter build appbundle --release
```

iOS:

```bash
flutter build ipa --release
```

산출물 위치:
- `build/app/outputs/bundle/release/app-release.aab`
- `build/ios/ipa/*.ipa`

---

## 6. 제출 전 확인

```bash
dart format --set-exit-if-changed . && flutter analyze && flutter test
```

실기기 확인 항목 (에뮬레이터로는 검증되지 않는 것들):

- [ ] 갤러리 권한 요청 문구가 의도대로 뜨는가
- [ ] 실제 기프티콘 스크린샷 10장 이상으로 인식 정확도 확인
- [ ] 매장 바코드 스캐너로 사용 화면이 실제로 읽히는가 (가장 중요)
- [ ] 만료 알림이 예약한 시각에 실제로 오는가 (기기 시간을 앞당겨 확인)
- [ ] 재부팅 후에도 알림 예약이 살아 있는가
- [ ] 선물하기 → 카카오톡 공유 시트 동작
- [ ] 저사양 기기에서 갤러리 60장 스캔 소요 시간

---

## 7. 스토어 등록 `(사용자)`

메타데이터·스크린샷 문구는 [`04-store-listing.md`](04-store-listing.md)에 준비되어 있다.
개인정보처리방침은 [`05-privacy-policy.md`](05-privacy-policy.md)를 웹에 올리고 그 URL을 등록한다.
(GitHub Pages, Notion 공개 페이지 등 무료 수단으로 충분하다.)

### App Store Connect

1. 앱 생성 → 번들 ID 선택
2. 스크린샷 업로드 (6.9" / 6.5" 필수)
3. 개인정보 처리 방침 URL 입력
4. **App Privacy** 설문: 이 앱은 어떤 데이터도 수집하지 않는다 →
   "Data Not Collected" 선택. 광고 식별자 없음.
5. 수출 규정: 암호화 사용 안 함 (`ITSAppUsesNonExemptEncryption=false` 이미 설정됨)
6. 심사 제출

### Google Play Console

1. 앱 생성 → AAB 업로드
2. **데이터 보안** 양식: 수집·공유하는 데이터 없음. 데이터 암호화 전송 해당 없음.
3. 콘텐츠 등급 설문
4. 비공개 테스트 20명 / 14일 진행
5. 프로덕션 승격

---

## 8. 심사 리스크와 대응

미리 알고 있으면 반려를 피할 수 있는 항목들이다.

| 리스크 | 대응 |
|---|---|
| **상표권** — 스타벅스·CGV 등 브랜드명 사용 | 앱은 브랜드 **로고를 쓰지 않고** 사용자가 입력한 텍스트만 표시한다. 스토어 스크린샷에도 실제 브랜드 로고를 넣지 않는다. 필요 시 "본 앱은 각 브랜드와 제휴 관계가 없습니다"를 설명란에 명시. |
| **Apple 4.2 최소 기능성** | 단순 목록 앱으로 보이면 반려된다. 심사 노트에 "온디바이스 OCR 자동 인식 + 금액권 잔액 관리 + 만료 알림"을 핵심 기능으로 적고, 테스트용 기프티콘 이미지를 첨부한다. |
| **Play 사진 권한 정책** | READ_MEDIA_IMAGES는 "핵심 기능" 정당화가 필요하다. 선언 양식에 "사용자가 저장한 쿠폰 이미지를 기기 내에서 인식해 등록하는 것이 앱의 핵심 기능"이라고 기재. |
| **금융/상품권 오인** | 앱은 쿠폰을 **거래하지 않는다**. 설명에 "구매·판매·현금화 기능이 없습니다"를 명시하면 오분류를 줄일 수 있다. |
| 심사용 계정 요구 | 로그인이 없으므로 해당 없음. 심사 노트에 "계정 없이 모든 기능 사용 가능"이라고 적는다. |

---

## 9. 출시 이후

- 앱 내 광고·트래킹을 넣자는 제안이 오더라도 넣지 않는다. 포지셔닝의 근간이다
  ([`01-market-research.md`](01-market-research.md) 4절).
- 1차 유입은 스윗비콘 종료로 대체 앱을 찾는 커뮤니티(클리앙·더쿠·뽐뿌)다.
  홍보 시 "광고 없음 / 사진이 서버로 가지 않음"을 앞세운다.
- 1.1 범위는 [`TASKS.md`](TASKS.md) 하단 참고.
