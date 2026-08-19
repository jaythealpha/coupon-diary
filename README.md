# 쿠폰다이어리 (Coupon Diary)

한국 기프티콘 관리 앱. Flutter, iOS/Android.

> 갤러리에 잠들어 있는 기프티콘을 자동으로 찾아내서, 만료 전에 반드시 쓰게 만드는 앱.
> **사진은 폰 밖으로 절대 나가지 않는다.**

---

## 문서

| 문서 | 내용 |
|---|---|
| [AGENTS.md](AGENTS.md) | **작업 전 필독.** 코딩 규약, 절대 규칙, Claude ↔ Codex 협업 방식 |
| [docs/01-market-research.md](docs/01-market-research.md) | 경쟁 앱 리뷰 분석, 니치 포지셔닝, MVP 범위 |
| [docs/02-architecture.md](docs/02-architecture.md) | 계층 구조, 플랫폼 분기, 데이터 모델, 인식 파이프라인 |
| [docs/03-release.md](docs/03-release.md) | 출시 절차 체크리스트 |
| [docs/04-store-listing.md](docs/04-store-listing.md) | 스토어 등록 문구 |
| [docs/05-privacy-policy.md](docs/05-privacy-policy.md) | 개인정보처리방침 |
| [docs/06-tester-guide.md](docs/06-tester-guide.md) | 체험판 테스터 안내 (동료 공유용) |
| [docs/TASKS.md](docs/TASKS.md) | 작업 보드 |

## 절대 규칙

1. 쿠폰 이미지·바코드 번호를 네트워크로 전송하지 않는다.
2. 광고 SDK를 넣지 않는다.
3. 트래킹 SDK를 넣지 않는다.
4. 서버 없이 모든 핵심 기능이 동작해야 한다.

상세는 [AGENTS.md](AGENTS.md) 2절.

## 개발

```bash
flutter pub get
```

Drift 스키마를 바꿨을 때만 코드 생성:

```bash
dart run build_runner build
```

### 검증

```bash
dart format . && flutter analyze && flutter test
```

UI를 손봤다면 브라우저에서 눈으로 확인한다. Xcode·Android SDK 없이도 되는 가장 빠른 경로다.

```bash
flutter build web --release && python3 -m http.server 5321 --directory build/web
```

웹 빌드에서는 OCR·알림·갤러리·밝기 제어가 스텁으로 동작한다. 첫 실행은 빈 보관함이다.
실제 인식은 iOS/Android에서만 확인할 수 있다.

### 체험판 배포 (동료 공유)

최초 1회만 저장소를 만들고, 그다음부터는 스크립트로 갱신한다.

```bash
cd .pages-deploy && gh repo create coupon-diary-web --public --source=. --push
```

```bash
./scripts/deploy-web-trial.sh
```

### 앱 아이콘 재생성

```bash
python3 assets/branding/make_icon.py && dart run flutter_launcher_icons
```

## 구조

```
lib/
  app/         진입점, 라우터, Provider
  core/        포맷터 등 공통 유틸
  design/      디자인 토큰 · 테마 · 공용 위젯
  data/        Drift 스키마, 리포지토리 구현
  domain/      순수 Dart 모델과 리포지토리 인터페이스
  features/    vault · recognition · usage · gift · notification · settings
```

## 상태

1.0 기능 구현 완료. 스토어 제출을 위해서는 Xcode·Android Studio 설치와
개발자 계정 등록이 필요하다 — [docs/03-release.md](docs/03-release.md) 참고.
