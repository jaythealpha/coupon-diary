#!/usr/bin/env bash
# 웹 체험판을 GitHub Pages에 배포한다.
#
# 최초 1회는 저장소를 만들어야 하므로 아래 두 명령을 직접 실행한다.
#   cd .pages-deploy && gh repo create coupon-diary-web --public --source=. --push
#   gh api -X POST repos/<계정>/coupon-diary-web/pages -f "source[branch]=main" -f "source[path]=/"
#
# 그 다음부터는 이 스크립트만 실행하면 최신 코드가 반영된다.
set -euo pipefail

REPO_NAME="coupon-diary-web"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "▸ 검증"
dart format --set-exit-if-changed . > /dev/null
flutter analyze
flutter test

echo "▸ 빌드 (base-href=/$REPO_NAME/)"
flutter build web --release --base-href "/$REPO_NAME/"

echo "▸ 캐시 무력화 (?v=해시)"
# GitHub Pages는 자산에 Cache-Control: max-age=600을 붙이는데, Flutter는
# main.dart.js를 버전 없는 이름으로 불러온다. 그래서 새로 배포해도 이미 방문한
# 브라우저는 최대 10분 동안 옛 번들을 그대로 쓴다 — 테스터가 "고친 게 안 보인다"고
# 하는 이유가 대부분 이것이다. 내용 해시를 쿼리로 붙여 URL 자체를 바꾼다.
BUILD_HASH="$(shasum -a 256 build/web/main.dart.js | cut -c1-12)"
for f in build/web/flutter_bootstrap.js build/web/index.html; do
  [ -f "$f" ] || continue
  # 이미 붙은 ?v= 는 건드리지 않는다.
  perl -pi -e "s{(?<![?&=])\b(main\.dart\.js|flutter_bootstrap\.js)(?!\?)}{\$1?v=$BUILD_HASH}g" "$f"
done
echo "  해시 $BUILD_HASH"

echo "▸ 배포 스냅샷 갱신"
# .git은 보존하고 산출물만 교체한다. 히스토리가 남아야 되돌릴 수 있다.
if [ -d .pages-deploy/.git ]; then
  mv .pages-deploy/.git /tmp/pages-git-$$
  rm -rf .pages-deploy
  cp -R build/web .pages-deploy
  mv /tmp/pages-git-$$ .pages-deploy/.git
else
  rm -rf .pages-deploy
  cp -R build/web .pages-deploy
  git -C .pages-deploy init -q
  git -C .pages-deploy checkout -q -b main
fi
# Jekyll이 밑줄로 시작하는 디렉터리를 무시해 flutter 산출물이 깨지는 것을 막는다.
touch .pages-deploy/.nojekyll

cd .pages-deploy
git add -A
if git diff --cached --quiet; then
  echo "▸ 변경 없음"
  exit 0
fi
git commit -qm "체험판 갱신 $(date '+%Y-%m-%d %H:%M')"

if git remote get-url origin > /dev/null 2>&1; then
  git push -q origin main
  OWNER="$(gh api user --jq .login)"
  URL="https://$OWNER.github.io/$REPO_NAME/"
  echo "▸ 푸시 완료. 반영까지 1~2분 걸린다."
  echo "▸ $URL"

  echo "▸ 응답 확인 중"
  for _ in $(seq 1 30); do
    CODE="$(curl -s -o /dev/null -w '%{http_code}' "$URL" || true)"
    if [ "$CODE" = "200" ]; then
      echo "▸ 배포 확인 (HTTP 200): $URL"
      exit 0
    fi
    sleep 10
  done
  echo "▸ 아직 200이 아니다 (마지막 응답: $CODE). 몇 분 뒤 다시 열어보라."
else
  echo "▸ origin이 없다. 최초 1회 저장소 생성이 필요하다:"
  echo "    cd $ROOT/.pages-deploy && gh repo create $REPO_NAME --public --source=. --push"
fi
