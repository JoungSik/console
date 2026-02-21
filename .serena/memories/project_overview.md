# Console 프로젝트 개요

## 프로젝트 목적
나만의 인생 기록을 위한 프라이빗 대시보드. 코어 앱 + 플러그인(Rails Engine) 구조.

## 아키텍처
- **코어 앱**: 인증, 세션, 홈, 레이아웃만 담당
- **플러그인(Engine)**: 기능별 독립 Rails Engine으로 분리
- **Multi-DB**: 플러그인별 독립 SQLite DB (`connects_to database:`)
- **PluginRegistry**: 플러그인 중앙 등록소로 네비게이션 자동 등록

## 기술 스택
- **프레임워크**: Rails 8.1.2
- **언어**: Ruby 3.4.1
- **데이터베이스**: SQLite3 (WAL mode, 플러그인별 독립 DB)
- **프론트엔드**: Tailwind CSS, Stimulus JS, Turbo, Importmap, Lucide icons
- **에셋 파이프라인**: Propshaft
- **백그라운드 잡**: Solid Queue + Mission Control
- **인증**: bcrypt (has_secure_password)
- **권한 관리**: Pundit
- **테스트**: RSpec, Capybara, Selenium
- **API 문서**: rswag/swagger
- **배포**: Kamal, Docker

## 프로젝트 구조
```
app/                    # 코어 앱 (인증, 세션, 홈, 레이아웃)
lib/
├── plugin_registry.rb  # 플러그인 중앙 등록소
├── console/
│   └── plugin_interface.rb  # 플러그인용 코어 인터페이스
└── generators/plugin/  # 플러그인 생성 제너레이터
engines/
├── todo/               # 할 일 목록 (Todo::List, Todo::Item)
└── bookmark/           # 북마크 (Bookmark::Group, Bookmark::Link)
```

## 플러그인 규칙
- 새 플러그인은 `bin/rails generate plugin <name> <label>` 로 생성
- Engine은 `isolate_namespace`로 격리
- 플러그인별 독립 SQLite DB
- `PluginRegistry.register`로 네비게이션 자동 등록
- `Console::PluginInterface`로 코어 사용자 정보 접근
- 레이아웃에서 메인 앱 라우트 헬퍼는 `main_app.` 접두사 사용
- 모델 테이블명은 `self.table_name` 명시, FK는 `foreign_key:` 옵션 명시
