# AGENTS.md — 쿠폰다이어리 에이전트 공통 규약

이 파일은 **Claude Code와 OpenAI Codex가 공유하는 단일 규약**이다.
`CLAUDE.md`는 이 파일을 참조만 하므로, 규칙을 바꿀 때는 항상 **이 파일**을 수정한다.

---

## 1. 프로젝트

**쿠폰다이어리 (Coupon Diary)** — 한국 기프티콘 관리 앱. Flutter, iOS/Android 동시 출시 목표.

포지셔닝 한 줄:
> 갤러리에 잠들어 있는 기프티콘을 자동으로 찾아내서, 만료 전에 반드시 쓰게 만드는 앱. **사진은 폰 밖으로 절대 나가지 않는다.**

배경과 근거는 `docs/01-market-research.md`, 설계는 `docs/02-architecture.md`에 있다.
**코드를 쓰기 전에 두 문서를 읽는다.**

---

## 2. 절대 규칙 (Non-negotiable)

이 앱의 존재 이유이므로 어떤 경우에도 어기지 않는다.

1. **쿠폰 이미지·바코드 번호·교환권 번호를 네트워크로 전송하지 않는다.**
   - OCR·바코드 인식은 전부 온디바이스(ML Kit)로 처리한다.
   - **LLM 보정은 1.0에서 제외했다.** 스위치만 있고 배선이 없어 "켜면 외부로 보낸다"는 설명 자체가 거짓이었다(2026-08-16 감사). 다시 도입한다면 마스킹 로직과 API 키 입력 UI를 함께 넣고, 그 전에는 어떤 문구로도 약속하지 않는다.
   - 지금 이 앱은 **어떤 데이터도 네트워크로 보내지 않는다.** 이 문장이 깨지는 변경은 리뷰에서 반려한다.
2. **광고 SDK를 추가하지 않는다.** 수익은 Pro 인앱결제로만 낸다.
3. **분석/트래킹 SDK를 넣지 않는다.** 크래시 리포트조차 opt-in.
4. **서버가 없어도 앱의 모든 핵심 기능이 동작해야 한다.** 백엔드 의존성을 만들지 않는다.
5. 위 규칙을 바꾸는 변경은 코드로 처리하지 말고 **사용자에게 먼저 물어본다.**

---

## 3. 기술 스택

| 영역 | 선택 | 비고 |
|---|---|---|
| 프레임워크 | Flutter 3.44 / Dart 3.12 | |
| 상태관리 | Riverpod 3 (`flutter_riverpod`) | 코드 생성 미사용, 수동 Provider |
| 라우팅 | go_router | |
| DB | Drift (SQLite) | `drift_flutter`. 코드 생성은 build_runner |
| OCR | `google_mlkit_text_recognition` (Korean) | 온디바이스 |
| 바코드 인식 | `google_mlkit_barcode_scanning` | 온디바이스 |
| 바코드 렌더 | `barcode_widget` | |
| 알림 | `flutter_local_notifications` + `timezone` | 로컬만 |
| 갤러리 | `photo_manager`, `image_picker` | |

---

## 4. 디렉터리 구조

```
lib/
  app/              앱 진입점, 라우터, 테마
  core/             공통 유틸, 결과 타입, 확장, 포맷터
  design/           디자인 토큰 (색/타이포/간격) — 하드코딩 금지, 여기만 사용
  data/
    local/          Drift 테이블·DAO·DB 커넥션 (플랫폼 조건부)
    repository/     리포지토리 구현
  domain/
    model/          순수 Dart 모델 (Flutter 의존성 없음)
    repository/     리포지토리 인터페이스
  features/
    <feature>/
      data/         해당 기능 전용 데이터 소스
      application/  Provider, 컨트롤러, 유스케이스
      presentation/ 화면·위젯
test/
  unit/  widget/
docs/               기획·설계 문서
```

기능 폴더: `vault`(보관함) · `recognition`(인식) · `usage`(사용) · `gift`(선물) · `notification`(알림) · `settings`(설정)

---

## 5. 코딩 규칙

- **디자인 토큰만 사용한다.** `lib/design/tokens.dart` 밖에서 `Color(0x...)`, 임의 숫자 패딩, 임의 폰트 크기를 쓰지 않는다.
- **도메인 모델은 순수 Dart.** `domain/model`에서 `package:flutter/*`를 import하지 않는다.
- **플랫폼 분기는 조건부 import로.** 화면 코드에 `if (Platform.isX)`를 흩뿌리지 않는다. 웹 빌드는 UI 검증용이므로 항상 컴파일되어야 한다.
- **사용자에게 보이는 문자열은 한국어.** 현재는 화면 파일에 직접 쓴다 — 중앙 문자열 테이블은 1.1로 미뤘다.
- **환경에 따라 갈리는 기능을 문구로 약속하지 마라.** 갤러리 자동 인식·밝기 제어·만료 알림은 웹에 없다.
  약속하는 문구를 쓰려면 반드시 해당 capability provider를 읽어 환경별로 갈라라.
  `test/widget/capability_claim_test.dart`가 이를 검사한다.
- 주석은 **왜**를 쓴다. 무엇을 하는지는 코드가 말한다.
- `flutter analyze` 무경고를 유지한다.

### 상태 표현 (필수)

사용자에게 보이는 모든 비동기 화면은 다섯 상태를 전부 구현한다: `loading` / `empty` / `error` / `success` / `disabled`.
에러 메시지는 **무엇이 잘못됐고 어떻게 해결하는지**를 한국어로 설명한다. "오류가 발생했습니다" 단독은 반려.

---

## 6. 검증 절차

작업을 "완료"라고 보고하기 전에 반드시 통과해야 한다.

```bash
dart format .
flutter analyze
flutter test
flutter build web --release      # UI 회귀 확인용 (가장 빠른 컴파일 게이트)
```

UI를 건드렸다면 **브라우저에서 실제로 열어 375 / 768 / 1440 폭을 확인**하고, 발견한 문제는 목록만 남기지 말고 직접 고친다.

---

## 7. Claude Code ↔ Codex 협업 규약

두 에이전트가 같은 저장소에서 동시에 작업한다. 충돌을 막기 위해 아래를 지킨다.

### 7.1 담당 영역 기본값

| 영역 | 기본 담당 |
|---|---|
| 아키텍처, 데이터 모델, 디자인 시스템, UI 화면 | **Claude Code** |
| OCR 파싱 규칙, 정규식, 테스트 케이스 확충, 리팩터링 | **Codex** |
| 릴리스·빌드·스토어 메타데이터 | **Claude Code** |

이건 기본값일 뿐이다. 실제 배정은 아래 작업 보드가 결정한다.

### 7.2 작업 보드

`docs/TASKS.md`가 단일 진실 공급원이다. 형식:

```
- [ ] (claude) T-012 보관함 정렬 옵션 추가
- [~] (codex)  T-013 GS25 기프티콘 파싱 규칙        <- 진행 중
- [x] (codex)  T-014 스타벅스 금액권 잔액 파싱
```

**작업을 시작하기 전에** 자기 이름으로 항목을 `[~]`로 바꾸고, 끝나면 `[x]`로 바꾼다.
다른 에이전트가 `[~]`로 잡고 있는 항목의 파일은 건드리지 않는다.

### 7.3 커밋

- 한 작업 = 한 커밋. 커밋 메시지 첫 줄에 작업 ID를 넣는다: `T-013: GS25 기프티콘 파싱 규칙 추가`
- 커밋 트레일러로 작성자를 남긴다: `Co-Authored-By: Codex <codex@openai.com>` 또는 Claude의 트레일러.
- 커밋 전에 6절의 검증 절차를 통과시킨다.

### 7.4 인계 메모

작업을 끝내고 다음 에이전트가 이어받아야 하면 `docs/HANDOFF.md` 맨 위에 5줄 이내로 적는다: 무엇을 했고, 무엇이 남았고, 어디를 보면 되는지.

---

## 8. Codex CLI 사용법

설치(최초 1회):

```bash
npm install -g @openai/codex
```

이 저장소에서 실행하면 Codex가 이 `AGENTS.md`를 자동으로 읽는다.

```bash
codex
```

작업 보드의 특정 항목을 맡길 때:

```bash
codex "docs/TASKS.md에서 (codex)로 표시된 미완료 항목 중 가장 위의 것을 수행해. AGENTS.md 규약을 지킬 것."
```
