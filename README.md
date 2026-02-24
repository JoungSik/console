# Console

나만의 인생 기록을 위한 프라이빗 대시보드

## 아키텍처

코어 앱 + 플러그인(Rails Engine) 구조. 인증/세션/레이아웃만 코어가 담당하고, 기능은 독립 Engine으로 분리.

```
app/                    # 코어 앱 (인증, 세션, 홈, 레이아웃)
lib/
├── plugin_registry.rb  # 플러그인 중앙 등록소
└── console/
    ├── plugin_interface.rb      # 플러그인용 코어 인터페이스
    ├── dashboard_component.rb   # 대시보드 위젯 베이스 클래스
    └── plugin_data_cleaner.rb   # 플러그인 데이터 삭제 인터페이스
engines/
├── todo/               # 할 일 목록 (Todo::List, Todo::Item)
├── bookmark/           # 북마크 (Bookmark::Group, Bookmark::Link)
└── settlement/         # 정산 (Settlement::Gathering, Round, Member, Item)
```

## 플러그인 목록

| 플러그인 | 설명 | 경로 |
|---------|------|------|
| todo | 할 일 목록 | `/todos` |
| bookmark | 북마크 | `/bookmarks` |
| settlement | 정산 | `/settlements` |

사용자는 마이페이지 > 플러그인 설정(`/mypage/plugins`)에서 플러그인을 활성화/비활성화할 수 있습니다. 비활성화된 플러그인은 네비게이션에서 숨겨지고, 30일 후 데이터가 자동 삭제됩니다.

## 기술 스택

- Ruby 3.4.1 / Rails 8.1.2
- SQLite3 (WAL mode)
- Tailwind CSS, Stimulus JS, Turbo
- Solid Queue (백그라운드 잡)
- Resend (이메일 발송)
- Kamal + Docker (배포)

## 개발

```bash
bin/setup          # 초기 설정
bin/dev            # 개발 서버 시작
bin/rails test     # 테스트 실행
```

## 새 플러그인 추가

Rails generator로 플러그인 scaffold를 생성합니다. Engine 파일 생성과 함께 `Gemfile`, `config/routes.rb`, `config/database.yml`, `Dockerfile`이 자동 업데이트됩니다.

```bash
# 생성
bin/rails generate plugin <name> <label> [--icon=<lucide_icon>] [--position=<number>]

# 예시
bin/rails generate plugin note 메모 --icon=notebook --position=30

# 삭제 (모든 변경 자동 되돌림)
bin/rails destroy plugin note 메모
```

생성 후:
1. `bundle install` 실행
2. 모델, 컨트롤러, 뷰, 마이그레이션 작성
3. `bin/rails db:migrate` 실행
