# Claude Rules

## Core
- Answer in Korean
- 사용하지 않는 코드는 삭제 (dead code 정리)

## Architecture
코어 앱 + 플러그인(Rails Engine) 구조. 인증/세션만 코어가 담당하고, 기능은 독립 Engine으로 분리.

### Project Structure
```
app/                    # 코어 앱 (인증, 세션, 홈, 레이아웃)
├── controllers/        # 코어 컨트롤러
├── models/             # 코어 모델 (User, Session)
├── views/layouts/      # 공유 레이아웃
├── helpers/            # NavigationHelper 등
├── assets/             # CSS/JS assets
└── javascript/         # Stimulus controllers
lib/
├── plugin_registry.rb  # 플러그인 중앙 등록소
└── console/
    └── plugin_interface.rb  # 플러그인용 코어 인터페이스
engines/                # 플러그인 엔진들
├── todo/               # 할 일 목록 (Todo::List, Todo::Item - title, url, completed, due_date, recurrence, recurrence_ends_on)
└── bookmark/           # 북마크 (Bookmark::Group, Bookmark::Link)
lib/generators/plugin/  # 플러그인 생성 제너레이터
```

### Plugin Convention
- **새 플러그인 생성은 반드시 Rails generator 사용**: `bin/rails generate plugin <name> <label> [--icon=box] [--position=100]`
- Engine은 `isolate_namespace`로 격리
- 플러그인별 독립 SQLite DB (`connects_to database:`)
- `PluginRegistry.register`로 네비게이션 자동 등록
- `Console::PluginInterface`로 코어 사용자 정보 접근
- 레이아웃에서 메인 앱 라우트 헬퍼는 `main_app.` 접두사 사용
- Engine 뷰에서 자체 라우트 헬퍼는 엔진명 접두사 사용 (예: `todo.lists_path`, `bookmark.groups_path`)
- 테이블명에 네임스페이스 접두사 불필요 (DB 분리됨, `table_name_prefix = ""` 설정 완료)

### Plugin Generator
```bash
# 생성 (Gemfile, routes.rb, database.yml, Dockerfile 자동 업데이트)
bin/rails generate plugin note 메모 --icon=notebook --position=30

# 삭제 (모든 변경 자동 되돌림)
bin/rails destroy plugin note 메모

# dry-run (변경 없이 미리보기)
bin/rails generate plugin note 메모 --pretend
```

## Tech Stack
- Rails 8.1.2 with ERB templates
- **Tailwind CSS** (tailwindcss-rails) - Use utility classes
- Stimulus JS (stimulus-rails)
- Turbo (turbo-rails)
- Importmap (importmap-rails)
- Lucide icons (lucide-rails)
- JBuilder for JSON

## Design System
> **전체 문서:** [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)

### 디자인 원칙
- **모던/미니멀**: 간결함, 여백 활용, 일관성
- **다크 모드 필수**: 모든 요소에 `dark:` 변형 포함
- **접근성**: 충분한 색상 대비, 명확한 포커스 상태

### 색상 토큰 (Quick Reference)
| 용도 | 라이트 | 다크 |
|------|--------|------|
| 페이지 배경 | `bg-gray-100` | `dark:bg-gray-900` |
| 카드/컨테이너 | `bg-white` | `dark:bg-gray-800` |
| 중첩 컨테이너 | `bg-gray-50` | `dark:bg-gray-700` |
| 기본 텍스트 | `text-gray-900` | `dark:text-white` |
| 보조 텍스트 | `text-gray-600` | `dark:text-gray-400` |
| 기본 테두리 | `border-gray-200` | `dark:border-gray-700` |
| 입력 테두리 | `border-gray-300` | `dark:border-gray-600` |
| 링크 | `text-blue-600` | `dark:text-blue-400` |

### 컴포넌트 스타일

#### Primary 버튼
```erb
class="bg-blue-600 hover:bg-blue-700 dark:hover:bg-blue-500 text-white font-medium px-4 py-2 rounded-md transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800"
```

#### Secondary 버튼
```erb
class="bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-600 font-medium px-4 py-2 rounded-md transition-colors duration-200"
```

#### 입력 필드
```erb
class="w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
```

#### 카드
```erb
class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm"
```

#### 링크
```erb
class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 transition-colors duration-200"
```

### 타이포그래피
| 용도 | 클래스 |
|------|--------|
| 페이지 제목 | `text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white` |
| 섹션 제목 | `text-xl font-semibold text-gray-900 dark:text-white` |
| 카드 제목 | `text-lg font-semibold text-gray-900 dark:text-white` |
| 라벨 | `text-sm font-medium text-gray-700 dark:text-gray-300` |
| 본문 | `text-sm text-gray-600 dark:text-gray-400` |

### 애니메이션
- 기본: `transition-colors duration-200`
- 그림자: `transition-shadow duration-200`

## Styling Guidelines
- Use Tailwind utility classes in ERB
- Custom CSS in app/assets/stylesheets/
- Tailwind config: app/assets/tailwind/application.css

## Git Commit
- 커밋 타입: `feat`, `fix`, `chore` 만 사용
  - `feat`: 새로운 기능
  - `fix`: 버그 수정
  - `chore`: 기타 (문서, 설정, 스타일 등)

## Process
1. Read CLAUDE.md first