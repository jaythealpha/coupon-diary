import '../../../domain/model/coupon.dart';

/// 브랜드 한 개의 인식 규칙.
class BrandEntry {
  const BrandEntry(this.canonical, this.category, {this.aliases = const []});

  /// 저장에 쓰는 정식 명칭.
  final String canonical;
  final CouponCategory category;

  /// OCR이 읽어낼 수 있는 표기 변형. 영문 표기, 띄어쓰기 차이, 흔한 오인식.
  final List<String> aliases;

  Iterable<String> get allForms => [canonical, ...aliases];
}

/// 브랜드 사전.
///
/// 확충은 Codex 담당 (docs/TASKS.md T-013). 항목을 추가할 때는
/// 1) 정식 명칭은 매장 간판 표기를 따르고,
/// 2) 별칭에는 영문 표기와 띄어쓰기 변형을 반드시 넣는다.
///    OCR은 "파리 바게뜨"처럼 띄어쓰기를 만들어내는 일이 잦다.
const List<BrandEntry> kBrandDictionary = [
  // ─── 카페 ────────────────────────────────────────────────────────────────
  BrandEntry(
    '스타벅스',
    CouponCategory.cafe,
    aliases: ['STARBUCKS', 'Starbucks', '스타 벅스', '스벅'],
  ),
  BrandEntry(
    '투썸플레이스',
    CouponCategory.cafe,
    aliases: ['A TWOSOME PLACE', 'TWOSOME', '투썸 플레이스', '투썸'],
  ),
  BrandEntry(
    '이디야커피',
    CouponCategory.cafe,
    aliases: ['EDIYA', 'EDIYA COFFEE', '이디야 커피', '이디야'],
  ),
  BrandEntry(
    '메가커피',
    CouponCategory.cafe,
    aliases: ['MEGA COFFEE', '메가 커피', '메가엠지씨커피', 'MEGA MGC'],
  ),
  BrandEntry(
    '컴포즈커피',
    CouponCategory.cafe,
    aliases: ['COMPOSE COFFEE', '컴포즈 커피', '컴포즈'],
  ),
  BrandEntry(
    '빽다방',
    CouponCategory.cafe,
    aliases: ['PAIK\'S COFFEE', 'PAIKS', '빽 다방'],
  ),
  BrandEntry(
    '커피빈',
    CouponCategory.cafe,
    aliases: ['THE COFFEE BEAN', 'COFFEE BEAN', '커피 빈', '커피빈코리아'],
  ),
  BrandEntry(
    '할리스',
    CouponCategory.cafe,
    aliases: ['HOLLYS', 'HOLLYS COFFEE', '할리스커피', '할리스 커피'],
  ),
  BrandEntry('탐앤탐스', CouponCategory.cafe, aliases: ['TOM N TOMS', '탐앤탐스커피']),
  BrandEntry('폴바셋', CouponCategory.cafe, aliases: ['PAUL BASSETT', '폴 바셋']),
  BrandEntry(
    '엔제리너스',
    CouponCategory.cafe,
    aliases: ['ANGEL-IN-US', 'ANGELINUS'],
  ),
  BrandEntry('더벤티', CouponCategory.cafe, aliases: ['THE VENTI', '더 벤티']),
  BrandEntry('공차', CouponCategory.cafe, aliases: ['GONG CHA', 'GONGCHA']),

  // ─── 편의점 ──────────────────────────────────────────────────────────────
  BrandEntry('GS25', CouponCategory.convenience, aliases: ['지에스25', 'GS 25']),
  BrandEntry(
    'CU',
    CouponCategory.convenience,
    aliases: ['씨유', 'CU편의점', 'CU 편의점'],
  ),
  BrandEntry(
    '세븐일레븐',
    CouponCategory.convenience,
    aliases: ['7-ELEVEN', '7ELEVEN', '세븐 일레븐'],
  ),
  BrandEntry(
    '이마트24',
    CouponCategory.convenience,
    aliases: ['EMART24', '이마트 24', '이마트24시'],
  ),

  // ─── 치킨·피자 ───────────────────────────────────────────────────────────
  BrandEntry('BBQ', CouponCategory.chickenPizza, aliases: ['비비큐', 'BBQ치킨']),
  BrandEntry('BHC', CouponCategory.chickenPizza, aliases: ['비에이치씨', 'bhc치킨']),
  BrandEntry('교촌치킨', CouponCategory.chickenPizza, aliases: ['KYOCHON', '교촌']),
  BrandEntry('굽네치킨', CouponCategory.chickenPizza, aliases: ['GOOBNE', '굽네']),
  BrandEntry('네네치킨', CouponCategory.chickenPizza, aliases: ['NENE', '네네']),
  BrandEntry(
    '도미노피자',
    CouponCategory.chickenPizza,
    aliases: ["DOMINO'S", 'DOMINOS', '도미노 피자'],
  ),
  BrandEntry(
    '피자헛',
    CouponCategory.chickenPizza,
    aliases: ['PIZZA HUT', '피자 헛'],
  ),
  BrandEntry('미스터피자', CouponCategory.chickenPizza, aliases: ['MR.PIZZA']),

  // ─── 베이커리·디저트 ─────────────────────────────────────────────────────
  BrandEntry(
    '파리바게뜨',
    CouponCategory.bakery,
    aliases: ['PARIS BAGUETTE', '파리 바게뜨', '파리바게트', '파바'],
  ),
  BrandEntry(
    '뚜레쥬르',
    CouponCategory.bakery,
    aliases: ['TOUS les JOURS', 'TOUSLESJOURS', '뚜레 쥬르'],
  ),
  BrandEntry(
    '던킨',
    CouponCategory.bakery,
    aliases: ['DUNKIN', "DUNKIN'", '던킨도너츠', '던킨 도너츠'],
  ),
  BrandEntry(
    '배스킨라빈스',
    CouponCategory.bakery,
    aliases: ['BASKIN ROBBINS', 'BR31', '베스킨라빈스', '배라'],
  ),
  BrandEntry('설빙', CouponCategory.bakery, aliases: ['SULBING']),
  BrandEntry('요거프레소', CouponCategory.bakery, aliases: ['YOGERPRESSO']),

  // ─── 외식 ────────────────────────────────────────────────────────────────
  BrandEntry(
    '맥도날드',
    CouponCategory.dining,
    aliases: ["McDonald's", 'MCDONALDS', '맥날'],
  ),
  BrandEntry('버거킹', CouponCategory.dining, aliases: ['BURGER KING', '버거 킹']),
  BrandEntry('롯데리아', CouponCategory.dining, aliases: ['LOTTERIA']),
  BrandEntry('맘스터치', CouponCategory.dining, aliases: ["MOM'S TOUCH", '맘스 터치']),
  BrandEntry('KFC', CouponCategory.dining, aliases: ['케이에프씨']),
  BrandEntry('서브웨이', CouponCategory.dining, aliases: ['SUBWAY']),
  BrandEntry('아웃백', CouponCategory.dining, aliases: ['OUTBACK', '아웃백스테이크하우스']),
  BrandEntry('빕스', CouponCategory.dining, aliases: ['VIPS']),

  // ─── 영화·문화 ───────────────────────────────────────────────────────────
  BrandEntry('CGV', CouponCategory.culture, aliases: ['씨지브이', 'CJ CGV']),
  BrandEntry('메가박스', CouponCategory.culture, aliases: ['MEGABOX', '메가 박스']),
  BrandEntry('롯데시네마', CouponCategory.culture, aliases: ['LOTTE CINEMA']),
  BrandEntry('교보문고', CouponCategory.culture, aliases: ['KYOBO', '교보 문고']),
  BrandEntry('예스24', CouponCategory.culture, aliases: ['YES24', '예스 24']),

  // ─── 뷰티 ────────────────────────────────────────────────────────────────
  BrandEntry(
    '올리브영',
    CouponCategory.beauty,
    aliases: ['OLIVE YOUNG', 'OLIVEYOUNG', '올리브 영'],
  ),
  BrandEntry('아리따움', CouponCategory.beauty, aliases: ['ARITAUM']),
  BrandEntry('이니스프리', CouponCategory.beauty, aliases: ['INNISFREE']),

  // ─── 카페 (추가) ──────────────────────────────────────────────────────────
  BrandEntry('파스쿠찌', CouponCategory.cafe, aliases: ['PASCUCCI', '파스쿠치']),
  BrandEntry(
    '드롭탑',
    CouponCategory.cafe,
    aliases: ['DROPTOP', '카페 드롭탑', '카페드롭탑'],
  ),
  BrandEntry(
    '카페베네',
    CouponCategory.cafe,
    aliases: ['CAFFE BENE', 'CAFFEBENE', '카페 베네'],
  ),
  BrandEntry(
    '요거트아이스크림의정석',
    CouponCategory.cafe,
    aliases: ['요아정', '요거트 아이스크림의 정석'],
  ),
  BrandEntry('스무디킹', CouponCategory.cafe, aliases: ['SMOOTHIE KING', '스무디 킹']),
  BrandEntry('쥬씨', CouponCategory.cafe, aliases: ['JUICY']),
  BrandEntry('카페게이트', CouponCategory.cafe, aliases: ['CAFE GATE']),
  BrandEntry('바나프레소', CouponCategory.cafe, aliases: ['BANAPRESSO', '바나 프레소']),
  BrandEntry('감성커피', CouponCategory.cafe, aliases: ['GAMSUNG COFFEE', '감성 커피']),
  BrandEntry(
    '매머드커피',
    CouponCategory.cafe,
    aliases: ['MAMMOTH COFFEE', '매머드 커피', '맘모스커피'],
  ),
  BrandEntry('하삼동커피', CouponCategory.cafe, aliases: ['하삼동 커피']),
  BrandEntry('더리터', CouponCategory.cafe, aliases: ['THE LITER', '더 리터']),
  BrandEntry('토프레소', CouponCategory.cafe, aliases: ['TOPRESSO']),
  BrandEntry('커피에반하다', CouponCategory.cafe, aliases: ['커피에 반하다', '커반']),
  BrandEntry(
    '달콤커피',
    CouponCategory.cafe,
    aliases: ['DAL.KOMM', 'DALKOMM', '달콤 커피'],
  ),
  BrandEntry('블루보틀', CouponCategory.cafe, aliases: ['BLUE BOTTLE', '블루 보틀']),
  BrandEntry('아마스빈', CouponCategory.cafe, aliases: ['AMASVIN', '아마스빈 버블티']),

  // ─── 치킨·피자 (추가) ─────────────────────────────────────────────────────
  BrandEntry(
    '푸라닭',
    CouponCategory.chickenPizza,
    aliases: ['PURADAK', '푸라닭 치킨'],
  ),
  BrandEntry(
    '처갓집양념치킨',
    CouponCategory.chickenPizza,
    aliases: ['처갓집', '처갓집 양념치킨'],
  ),
  BrandEntry('60계치킨', CouponCategory.chickenPizza, aliases: ['60계', '육십계']),
  BrandEntry('노랑통닭', CouponCategory.chickenPizza, aliases: ['노랑 통닭']),
  BrandEntry(
    '호식이두마리치킨',
    CouponCategory.chickenPizza,
    aliases: ['호식이', '호식이 두마리치킨'],
  ),
  BrandEntry(
    '멕시카나',
    CouponCategory.chickenPizza,
    aliases: ['MEXICANA', '멕시카나치킨'],
  ),
  BrandEntry(
    '페리카나',
    CouponCategory.chickenPizza,
    aliases: ['PELICANA', '페리카나치킨'],
  ),
  BrandEntry('자담치킨', CouponCategory.chickenPizza, aliases: ['자담 치킨', 'ZADAM']),
  BrandEntry('바른치킨', CouponCategory.chickenPizza, aliases: ['바른 치킨']),
  BrandEntry(
    '파파존스',
    CouponCategory.chickenPizza,
    aliases: ["PAPA JOHN'S", 'PAPA JOHNS', '파파 존스'],
  ),
  BrandEntry(
    '반올림피자',
    CouponCategory.chickenPizza,
    aliases: ['반올림 피자', '반올림피자샵'],
  ),
  BrandEntry(
    '피자알볼로',
    CouponCategory.chickenPizza,
    aliases: ['ALVOLO', '알볼로', '피자 알볼로'],
  ),
  BrandEntry('고피자', CouponCategory.chickenPizza, aliases: ['GOPIZZA', '고 피자']),
  BrandEntry(
    '피자스쿨',
    CouponCategory.chickenPizza,
    aliases: ['PIZZA SCHOOL', '피자 스쿨'],
  ),
  BrandEntry(
    '7번가피자',
    CouponCategory.chickenPizza,
    aliases: ['7번가 피자', '칠번가피자'],
  ),

  // ─── 베이커리·디저트 (추가) ───────────────────────────────────────────────
  BrandEntry(
    '성심당',
    CouponCategory.bakery,
    aliases: ['SUNGSIMDANG', '성심당 케익부띠끄'],
  ),
  BrandEntry(
    '크리스피크림도넛',
    CouponCategory.bakery,
    aliases: ['KRISPY KREME', '크리스피 크림', '크리스피크림 도넛'],
  ),
  BrandEntry(
    '노티드',
    CouponCategory.bakery,
    aliases: ['KNOTTED', '카페 노티드', '카페노티드'],
  ),
  BrandEntry('아티제', CouponCategory.bakery, aliases: ['ARTISEE']),
  BrandEntry('브레댄코', CouponCategory.bakery, aliases: ['BREAD&CO', '브레드앤코']),
  BrandEntry(
    '앤티앤스',
    CouponCategory.bakery,
    aliases: ["AUNTIE ANNE'S", '앤티 앤스', '앤티앤스 프레즐'],
  ),
  BrandEntry('와플대학', CouponCategory.bakery, aliases: ['와플 대학']),
  BrandEntry('디저트39', CouponCategory.bakery, aliases: ['DESSERT39', '디저트 39']),
  BrandEntry('나뚜루', CouponCategory.bakery, aliases: ['NATUUR', '나뚜루팝']),
  BrandEntry(
    '하겐다즈',
    CouponCategory.bakery,
    aliases: ['HAAGEN-DAZS', 'HAAGENDAZS', '하겐 다즈'],
  ),

  // ─── 외식 (추가) ──────────────────────────────────────────────────────────
  BrandEntry('신전떡볶이', CouponCategory.dining, aliases: ['신전 떡볶이', 'SINJEON']),
  BrandEntry(
    '엽기떡볶이',
    CouponCategory.dining,
    aliases: ['동대문엽기떡볶이', '엽떡', '엽기 떡볶이'],
  ),
  BrandEntry('청년다방', CouponCategory.dining, aliases: ['청년 다방']),
  BrandEntry(
    '두끼떡볶이',
    CouponCategory.dining,
    aliases: ['두끼', 'DOOKKI', '두끼 떡볶이'],
  ),
  BrandEntry('본죽', CouponCategory.dining, aliases: ['BONJUK', '본죽&비빔밥']),
  BrandEntry('본도시락', CouponCategory.dining, aliases: ['본 도시락']),
  BrandEntry(
    '한솥도시락',
    CouponCategory.dining,
    aliases: ['한솥', 'HANSOT', '한솥 도시락'],
  ),
  BrandEntry('김밥천국', CouponCategory.dining, aliases: ['김밥 천국']),
  BrandEntry('바르다김선생', CouponCategory.dining, aliases: ['바르다 김선생']),
  BrandEntry(
    '이삭토스트',
    CouponCategory.dining,
    aliases: ['ISAAC', '이삭 토스트', 'ISAAC TOAST'],
  ),
  BrandEntry(
    '에그드랍',
    CouponCategory.dining,
    aliases: ['EGG DROP', 'EGGDROP', '에그 드랍'],
  ),
  BrandEntry(
    '프랭크버거',
    CouponCategory.dining,
    aliases: ['FRANK BURGER', '프랭크 버거'],
  ),
  BrandEntry(
    '노브랜드버거',
    CouponCategory.dining,
    aliases: ['NO BRAND BURGER', '노브랜드 버거'],
  ),
  BrandEntry(
    '쉐이크쉑',
    CouponCategory.dining,
    aliases: ['SHAKE SHACK', '쉑쉑버거', '쉐이크 쉑'],
  ),
  BrandEntry(
    '파이브가이즈',
    CouponCategory.dining,
    aliases: ['FIVE GUYS', '파이브 가이즈'],
  ),
  BrandEntry('타코벨', CouponCategory.dining, aliases: ['TACO BELL', '타코 벨']),
  BrandEntry('서가앤쿡', CouponCategory.dining, aliases: ['서가 앤 쿡', 'SEOGA&COOK']),
  BrandEntry(
    '애슐리',
    CouponCategory.dining,
    aliases: ['ASHLEY', '애슐리퀸즈', '애슐리 퀸즈'],
  ),
  BrandEntry('사보텐', CouponCategory.dining, aliases: ['SABOTEN']),
  BrandEntry('놀부부대찌개', CouponCategory.dining, aliases: ['놀부', '놀부 부대찌개']),
  BrandEntry('원할머니보쌈', CouponCategory.dining, aliases: ['원할머니', '원할머니 보쌈']),
  BrandEntry('족발야시장', CouponCategory.dining, aliases: ['족발 야시장']),
  BrandEntry('가장맛있는족발', CouponCategory.dining, aliases: ['가장 맛있는 족발']),
  BrandEntry('명륜진사갈비', CouponCategory.dining, aliases: ['명륜 진사갈비']),
  BrandEntry('하남돼지집', CouponCategory.dining, aliases: ['하남 돼지집']),
  BrandEntry(
    '매드포갈릭',
    CouponCategory.dining,
    aliases: ['MAD FOR GARLIC', '매드 포 갈릭'],
  ),
  BrandEntry('계절밥상', CouponCategory.dining, aliases: ['계절 밥상']),
  BrandEntry('자연별곡', CouponCategory.dining, aliases: ['자연 별곡']),

  // ─── 영화·문화 (추가) ─────────────────────────────────────────────────────
  BrandEntry('알라딘', CouponCategory.culture, aliases: ['ALADIN', '알라딘 중고서점']),
  BrandEntry('인터파크', CouponCategory.culture, aliases: ['INTERPARK', '인터파크 티켓']),
  BrandEntry('멜론', CouponCategory.culture, aliases: ['MELON', '멜론 이용권']),
  BrandEntry('지니뮤직', CouponCategory.culture, aliases: ['GENIE', '지니 뮤직']),
  BrandEntry('플로', CouponCategory.culture, aliases: ['FLO']),
  BrandEntry('왓챠', CouponCategory.culture, aliases: ['WATCHA']),
  BrandEntry('웨이브', CouponCategory.culture, aliases: ['WAVVE']),
  BrandEntry('티빙', CouponCategory.culture, aliases: ['TVING']),
  BrandEntry('넷플릭스', CouponCategory.culture, aliases: ['NETFLIX']),
  BrandEntry(
    '리디',
    CouponCategory.culture,
    aliases: ['RIDI', '리디북스', 'RIDIBOOKS'],
  ),
  BrandEntry('밀리의서재', CouponCategory.culture, aliases: ['밀리의 서재', 'MILLIE']),
  BrandEntry(
    '문화상품권',
    CouponCategory.culture,
    aliases: ['컬쳐랜드', 'CULTURELAND', '문화 상품권'],
  ),
  BrandEntry(
    '도서문화상품권',
    CouponCategory.culture,
    aliases: ['북앤라이프', 'BOOK&LIFE', '도서 문화상품권'],
  ),
  BrandEntry(
    '해피머니',
    CouponCategory.culture,
    aliases: ['HAPPY MONEY', '해피머니상품권'],
  ),
  BrandEntry(
    '롯데월드',
    CouponCategory.culture,
    aliases: ['LOTTE WORLD', '롯데월드 어드벤처'],
  ),
  BrandEntry('에버랜드', CouponCategory.culture, aliases: ['EVERLAND', '에버 랜드']),
  BrandEntry('서울랜드', CouponCategory.culture, aliases: ['SEOUL LAND', '서울 랜드']),
  BrandEntry(
    '아쿠아플라넷',
    CouponCategory.culture,
    aliases: ['AQUA PLANET', '아쿠아 플라넷'],
  ),
  BrandEntry(
    '캐리비안베이',
    CouponCategory.culture,
    aliases: ['CARIBBEAN BAY', '캐리비안 베이'],
  ),

  // ─── 뷰티·생활 (추가) ─────────────────────────────────────────────────────
  BrandEntry('에뛰드', CouponCategory.beauty, aliases: ['ETUDE', '에뛰드하우스']),
  BrandEntry('미샤', CouponCategory.beauty, aliases: ['MISSHA']),
  BrandEntry('토니모리', CouponCategory.beauty, aliases: ['TONYMOLY', '토니 모리']),
  BrandEntry(
    '네이처리퍼블릭',
    CouponCategory.beauty,
    aliases: ['NATURE REPUBLIC', '네이처 리퍼블릭'],
  ),
  BrandEntry(
    '더페이스샵',
    CouponCategory.beauty,
    aliases: ['THE FACE SHOP', '더 페이스샵'],
  ),
  BrandEntry('러쉬', CouponCategory.beauty, aliases: ['LUSH']),
  BrandEntry('바디프랜드', CouponCategory.beauty, aliases: ['BODYFRIEND', '바디 프랜드']),
  BrandEntry('준오헤어', CouponCategory.beauty, aliases: ['JUNO HAIR', '준오 헤어']),
  BrandEntry('다이소', CouponCategory.etc, aliases: ['DAISO']),

  // ─── 상품권·유통 ─────────────────────────────────────────────────────────
  BrandEntry('신세계상품권', CouponCategory.voucher, aliases: ['신세계 상품권', 'SSG']),
  BrandEntry('이마트', CouponCategory.voucher, aliases: ['EMART', 'E-MART']),
  BrandEntry('홈플러스', CouponCategory.voucher, aliases: ['HOMEPLUS', '홈 플러스']),
  BrandEntry('롯데마트', CouponCategory.voucher, aliases: ['LOTTE MART']),
  BrandEntry('롯데상품권', CouponCategory.voucher, aliases: ['롯데 상품권']),
  BrandEntry(
    '현대백화점상품권',
    CouponCategory.voucher,
    aliases: ['현대백화점 상품권', '현대 상품권'],
  ),
  BrandEntry('갤러리아상품권', CouponCategory.voucher, aliases: ['갤러리아 상품권']),
  BrandEntry('코스트코', CouponCategory.voucher, aliases: ['COSTCO']),
  BrandEntry(
    '트레이더스',
    CouponCategory.voucher,
    aliases: ['TRADERS', '이마트 트레이더스'],
  ),
  BrandEntry('킴스클럽', CouponCategory.voucher, aliases: ['KIMS CLUB', '킴스 클럽']),
  BrandEntry('하나로마트', CouponCategory.voucher, aliases: ['하나로 마트', '농협하나로마트']),
  BrandEntry('SSG닷컴', CouponCategory.voucher, aliases: ['SSG.COM', '쓱닷컴']),
  BrandEntry('마켓컬리', CouponCategory.voucher, aliases: ['KURLY', '컬리', '마켓 컬리']),

  // ─── 주유·이동 ────────────────────────────────────────────────────────────
  BrandEntry('GS칼텍스', CouponCategory.etc, aliases: ['GS CALTEX', 'GS 칼텍스']),
  BrandEntry(
    'SK에너지',
    CouponCategory.etc,
    aliases: ['SK ENERGY', 'SK 에너지', 'SK주유소'],
  ),
  BrandEntry('S-OIL', CouponCategory.etc, aliases: ['에쓰오일', 'SOIL', '에스오일']),
  BrandEntry('현대오일뱅크', CouponCategory.etc, aliases: ['HD현대오일뱅크', '현대 오일뱅크']),
  BrandEntry('쏘카', CouponCategory.etc, aliases: ['SOCAR']),
  BrandEntry(
    '카카오T',
    CouponCategory.etc,
    aliases: ['KAKAO T', '카카오 T', '카카오택시'],
  ),

  // ─── 온라인·기타 ─────────────────────────────────────────────────────────
  BrandEntry('배달의민족', CouponCategory.etc, aliases: ['배민', '배달의 민족', 'BAEMIN']),
  BrandEntry('요기요', CouponCategory.etc, aliases: ['YOGIYO']),
  BrandEntry('쿠팡이츠', CouponCategory.etc, aliases: ['COUPANG EATS', '쿠팡 이츠']),
  BrandEntry('쿠팡', CouponCategory.etc, aliases: ['COUPANG']),
  BrandEntry('네이버페이', CouponCategory.etc, aliases: ['NAVER PAY', '네이버 페이']),
  BrandEntry('카카오페이', CouponCategory.etc, aliases: ['KAKAO PAY', '카카오 페이']),
  BrandEntry('페이코', CouponCategory.etc, aliases: ['PAYCO']),
  BrandEntry('토스', CouponCategory.etc, aliases: ['TOSS']),
  BrandEntry('지마켓', CouponCategory.etc, aliases: ['GMARKET', 'G마켓', 'G 마켓']),
  BrandEntry('옥션', CouponCategory.etc, aliases: ['AUCTION']),
  BrandEntry('11번가', CouponCategory.etc, aliases: ['11ST', '십일번가']),
  BrandEntry('위메프', CouponCategory.etc, aliases: ['WEMAKEPRICE', 'WMP']),
  BrandEntry('티몬', CouponCategory.etc, aliases: ['TMON']),
  BrandEntry('무신사', CouponCategory.etc, aliases: ['MUSINSA']),
  BrandEntry('에이블리', CouponCategory.etc, aliases: ['ABLY']),
  BrandEntry('지그재그', CouponCategory.etc, aliases: ['ZIGZAG']),
  BrandEntry('당근마켓', CouponCategory.etc, aliases: ['당근', 'DAANGN', '당근 마켓']),
  BrandEntry('넥슨캐시', CouponCategory.etc, aliases: ['NEXON', '넥슨 캐시']),
  BrandEntry(
    '구글플레이기프트',
    CouponCategory.etc,
    aliases: ['GOOGLE PLAY', '구글플레이 기프트코드', '구글 기프트카드'],
  ),
  BrandEntry(
    '앱스토어기프트',
    CouponCategory.etc,
    aliases: ['APP STORE', '앱스토어 기프트카드', '애플 기프트카드'],
  ),
];

/// 정규화된 텍스트에서 브랜드를 찾는다.
///
/// 가장 **긴** 표기부터 맞춰본다. "이디야"만 먼저 매칭되면 "이디야커피"를
/// 놓치고, "CU"가 "CU편의점"보다 먼저 걸리는 문제도 같은 원인이다.
BrandEntry? matchBrand(String text) {
  final haystack = normalizeForMatch(text);
  BrandEntry? best;
  var bestLength = 0;

  for (final entry in kBrandDictionary) {
    for (final form in entry.allForms) {
      final needle = normalizeForMatch(form);
      if (needle.isEmpty || !haystack.contains(needle)) continue;
      if (needle.length > bestLength) {
        best = entry;
        bestLength = needle.length;
      }
    }
  }
  return best;
}

/// 매칭용 정규화: 공백·특수문자 제거 + 대문자 통일.
///
/// OCR은 "파리 바게뜨", "PARIS  BAGUETTE", "GS 25"처럼 공백을 임의로 넣는다.
String normalizeForMatch(String text) =>
    text.replaceAll(RegExp(r"[\s\-_.,'·]"), '').toUpperCase();
