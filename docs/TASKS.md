# 작업 보드

형식: `- [상태] (담당) T-000 제목`
상태: `[ ]` 대기 · `[~]` 진행 중 · `[x]` 완료
담당: `claude` · `codex`

작업 시작 전 자기 항목을 `[~]`로 바꾸고, 다른 에이전트가 `[~]`로 잡은 항목의 파일은 건드리지 않는다.

---

## 1.0 출시 범위

### 기반
- [x] (claude) T-001 Flutter 프로젝트 스캐폴딩 + 의존성
- [x] (claude) T-002 에이전트 규약(AGENTS.md) 및 문서 체계
- [x] (claude) T-003 디자인 토큰 + 테마
- [x] (claude) T-004 도메인 모델 (Coupon, UsageEntry)
- [x] (claude) T-005 Drift 스키마 + 리포지토리 (네이티브/웹 조건부)

### 인식
- [x] (claude) T-010 OCR 엔진 추상화 + 조건부 import (ML Kit / 스텁)
- [x] (claude) T-011 발행사 규칙 테이블 + 필드 추출기
- [x] (claude) T-012 발행사 규칙 확충 — 해피콘·니콘내콘·기프티스타·팔라고 추가 (총 11곳)
- [x] (claude) T-013 브랜드 사전 확충 — 185개 + 무결성 테스트(중복·별칭 충돌 검출)
- [x] (claude) T-014 파싱 테스트 케이스 확충 — 브랜드 27종·발행사 4종 문구 패턴
- [x] (claude) T-015 갤러리 일괄 스캔 (스크린샷에서 기프티콘 후보 탐지)
- [ ] (claude) T-016 LLM 보정 폴백 — **1.0에서 제외** (배선 없이 스위치만 있었다. T-111 참조)
- [x] (claude) T-017 이미지 검증·판정 어댑터 (형식·용량·해상도·손상, 헤더만 읽음)
- [x] (claude) T-018 검토 필요 판정 강화 — 유효기간 신뢰도 0.95 미만은 사용자 확인 필수

### 저장·관리
- [x] (claude) T-020 보관함 화면 (정렬/필터/검색, 5개 상태)
- [x] (claude) T-021 쿠폰 상세 화면
- [x] (claude) T-022 등록/수정 폼 (검증 + 에러 메시지)
- [x] (claude) T-023 사용 화면 (바코드 확대 + 밝기 최대 + 사용 확인)
- [x] (claude) T-024 금액권 잔액 차감 + 사용 이력
- [x] (claude) T-025 만료 상태 배치 갱신

### 알림
- [x] (claude) T-030 로컬 알림 스케줄러 (D-30/7/3/1)
- [ ] (claude) T-031 주간 다이제스트 — **미구현.** 같은 날 묶음만 구현됐다. 1.1로
- [ ] (claude) T-032 위치 기반 알림 (Pro) — 1.1로 연기

### 선물
- [x] (claude) T-040 쿠폰 재선물 (이미지+정보 공유, 상태 전이)
- [ ] (claude) T-041 가족 공유 — 1.1로 연기 (서버 없는 P2P 방식 설계 필요)

### 설정·보안
- [x] (claude) T-050 설정 화면
- [ ] (claude) T-051 앱 잠금 (생체 인증) — **1.0에서 제외** (실행 시 게이트 없었다. T-110 참조)
- [x] (claude) T-052 암호화 백업/복원 — AES-256-GCM + PBKDF2(210k), 병합 복원, 설정 UI

### 네이티브 설정
- [x] (claude) T-055 iOS 권한 설명 문구 · 로케일 · 암호화 신고
- [x] (claude) T-056 Android 권한 · 알림 receiver · desugaring · ProGuard
- [x] (claude) T-057 FlutterFragmentActivity 전환 (생체 인증 요구사항)

### 디자인 재정비 (1.0 마감 전)
- [x] (claude) T-090 디자인 토큰 전면 재설계 — iOS 타입 램프·스퀘어클·층 구분
- [x] (claude) T-091 공용 컴포넌트 — 그룹 인셋 리스트, 라지 타이틀 내비, 하단 액션 바
- [x] (claude) T-092 보관함 재디자인 — 카드→행, 만료 배너 축소, FAB→내비 바 `+`
- [x] (claude) T-093 상세 재디자인 — 패스 카드 + 절취선 + 바코드 미리보기
- [x] (claude) T-094 사용 화면 재디자인 — 옅은 바탕 위 흰 패스, 세로 가운데, 바코드 140pt
- [x] (claude) T-095 하단 바가 본문을 삼키던 레이아웃 버그 수정 + 회귀 테스트
- [x] (claude) T-096 기본 상태를 빈 보관함으로 — 데모 쿠폰 시딩 제거
- [x] (claude) T-097 사용 방법 화면(/help) + 설정 진입점
- [x] (claude) T-098 첫 실행 안내 — 빈 보관함이 세 걸음을 가르치고, 검색·탭·필터는 숨김
- [x] (claude) T-099 세 걸음 일러스트 3종 (Recraft V4.1 vector, SVG) + flutter_svg 도입
- [x] (claude) T-100 저장 키 v2로 승격 — 이미 시딩된 브라우저가 데모 쿠폰을 계속 불러오던 문제
- [x] (claude) T-101 배포 캐시 무력화 — main.dart.js·flutter_bootstrap.js에 내용 해시 쿼리
- [x] (claude) T-102 안내 문구를 환경에 맞춤 — 웹에서 없는 갤러리 자동 인식을 1번으로 내세우던 문제
- [x] (claude) T-103 로컬 서버를 scripts/serve-web.py로 — SPA 폴백·no-store·PORT 환경변수

### 거짓 약속 감사 (2026-08-16, 감사관 2 + 수퍼바이저 검증)
자세한 근거는 `docs/07-claim-audit.md`.

기능 미구현 — 문구를 고쳐 덮으면 안 되는 것:
- [x] (claude) T-110 앱 잠금 — **1.0에서 제외.** 스위치·local_auth·Face ID 문자열·방침 문단 모두 제거. 1.1로
- [x] (claude) T-111 AI 보정 — **제거.** 스위치·llm_assist.dart·http 의존성·방침 §5 모두 삭제
- [x] (claude) T-112 만료 알림이 스위치 켠 순간의 쿠폰만 예약 — 이후 등록분은 영영 안 걸림
- [x] (claude) T-113 쿠폰 삭제 시 이미지 파일이 안 지워짐 — `ImageStore.remove()` 호출부 0건, 접근 불가 고아 파일로 잔존
- [x] (claude) T-114 웹 선물 공유가 성공해도 "취소"로 처리 — 바코드는 전달됐는데 쿠폰은 active 유지(중복 사용 위험)
- [x] (claude) T-115 웹 백업 성공 시 아무 안내 없음 — 파일은 내려가는데 스낵바 미표시
- [x] (claude) T-116 알림 탭 딥링크 배선 — 실행 중은 콜백, 콜드 스타트는 `initialRoute()`
- [x] (claude) T-117 `nowProvider`가 갱신되지 않음 — 자정 넘기면 D-1 배지가 안 넘어감

거짓 문구 — 환경 분기·사전 고지로 해결:
- [x] (claude) T-120 등록 폼 유효기간 helper가 웹에서도 알림 약속 (웹의 유일 등록 경로)
- [x] (claude) T-121 첫 실행 안내 2번 "밝기를 최대로" — 웹 고지 목록에서 누락
- [x] (claude) T-122 사용 방법 2번 걸음·알림 팁이 웹에서도 무조건 표시
- [x] (claude) T-123 설정 알림·앱잠금 스위치가 눌러야 거절 — 사전 비활성·사유 표시 없음
- [x] (claude) T-124 웹 앱잠금 거절 문구가 불가능한 해결책 안내
- [x] (claude) T-125 백업이 이미지를 포함하지 않는다는 단서 누락

정직하지 않은 스텁:
- [x] (claude) T-130 `app_lock_stub.authenticate()`가 `true` 반환 — T-110 수정 경로 위의 함정
- [x] (claude) T-131 `notification_service_stub.reschedule()`이 0이 아닌 건수 반환

문서 불일치:
- [x] (claude) T-140 "웹 데모 쿠폰 10장" 3곳 (README·테스터 가이드·아키텍처)
- [x] (claude) T-141 T-031 주간 다이제스트 미구현인데 완료 표시
- [x] (claude) T-142 "FLAG_SECURE 적용" 미구현
- [x] (claude) T-143 아키텍처 문서의 웹 OCR 스텁 설명이 코드와 반대
- [x] (claude) T-144 AGENTS.md가 없는 `lib/core/l10n/strings.dart`를 규약으로 지정
- [x] (claude) T-145 심사 노트 "네트워크 전송 없음" vs 방침 §5 "외부 AI 전송" 모순 (T-111과 함께 결정)
- [ ] (사용자) T-146 iOS 수출 규정 신고 `ITSAppUsesNonExemptEncryption=false` vs AES-256-GCM 사용 **[법무 판단]**

재발 방지:
- [x] (claude) T-150 capability 게이트 회귀 테스트 — 환경 의존 기능을 약속하는 문구가 게이트를 거치는지 검사

미확인 (감사 커버리지 공백):
- [x] (claude) T-160 `[x]` 항목 전수 대조 완료 — T-016·T-051 표기 정정, AGENTS.md 죽은 규칙 수정, 문서 3곳 앱잠금 잔재 제거
- [x] (claude) T-165 `nowProvider` 복귀 시 갱신 — autoDispose만으로는 보관함이 watch 중이라 폐기 안 됐다
- [x] (claude) T-166 반응형 회귀 테스트 375/768/1440 — 이전엔 375뿐이었다
- [ ] (claude) T-167 미사용 공개 선언 정리 — `Elevation`, `Layout.breakpointTablet`, `closeCouponRepository`, `Fmt.wonCompact`/`dateShort`
- [ ] (claude) T-168 `lib/data/demo_data.dart`를 `test/` 하위로 — 테스트 전용인데 프로덕션 번들에 남아 있다
- [x] (claude) T-161 `docs/HANDOFF.md` — 8/14의 '전부 끝났다'가 틀렸음을 기록으로 정정
- [x] (claude) T-162 광고·트래킹 SDK 부재 확인 — 의존성 181개에 없음
- [x] (claude) T-163 Android manifest 확인 — 부팅 리시버 존재, inexact 스케줄링이라 정확 알람 권한 불필요. 미사용 USE_BIOMETRIC 제거
- [x] (claude) T-164 share_plus 결과 3분기 처리 — unavailable은 '결과 모름'이므로 사용자에게 확인

### 품질·출시
- [x] (claude) T-060 단위·위젯 테스트
- [x] (claude) T-061 브라우저 반응형/접근성 검증
- [x] (claude) T-070 앱 아이콘 (원본 + 생성 스크립트 + 전 사이즈)
- [x] (claude) T-071 스토어 메타데이터 (docs/04-store-listing.md) — 스크린샷은 실기기 필요
- [x] (claude) T-072 개인정보처리방침 (docs/05-privacy-policy.md) — 게시 URL 필요
- [ ] (사용자) T-073 Apple Developer / Google Play 개발자 계정 등록
- [ ] (사용자) T-074 Xcode · Android Studio 설치
- [x] (claude) T-075 서명 설정 (key.properties 연동) — 키 생성과 빌드는 도구 설치 후
- [ ] (사용자) T-076 스토어 심사 제출

---

## 1.1 이후
- [ ] T-110 앱 잠금 (생체 인증) — 실행 시 인증 게이트부터 배선할 것
- [ ] T-031 주간 다이제스트
- [ ] T-142 Android FLAG_SECURE
- [ ] T-032 위치 기반 알림
- [ ] T-041 가족 공유
- [ ] T-080 홈 위젯
- [ ] T-081 사용 통계 리포트
- [ ] T-082 Pro 인앱결제
