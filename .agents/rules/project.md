# Project Rules

## Architecture

코어 앱과 플러그인(Rails Engine) 구조로 구성한다. 인증과 세션만 코어가 담당하고, 기능은 독립 Engine으로 분리한다.

## Project Structure

```text
app/                    # 코어 앱 (인증, 세션, 홈, 레이아웃)
├── controllers/        # 코어 컨트롤러
├── models/             # 코어 모델 (User, Session, UserPlugin)
├── services/           # 서비스 오브젝트
├── views/layouts/      # 공유 레이아웃
├── helpers/            # NavigationHelper 등
├── assets/             # CSS/JS assets
├── javascript/         # Stimulus controllers
└── jobs/               # PluginDeletionWarningJob, PluginDataDeletionJob
lib/
├── plugin_registry.rb  # 플러그인 중앙 등록소 (네비게이션 + 대시보드 위젯)
└── console/
    ├── plugin_interface.rb      # 플러그인용 코어 인터페이스 (접근 보호 포함)
    ├── dashboard_component.rb   # 대시보드 위젯 베이스 클래스
    └── plugin_data_cleaner.rb   # 플러그인 데이터 삭제 인터페이스
engines/                # 플러그인 엔진
├── todo/               # 할 일 목록 (Todo::List, Todo::Item - title, url, completed, due_date, recurrence, recurrence_ends_on)
└── journal/            # 포스트 (Journal::Post - body)
docs/
└── DESIGN_SYSTEM.md    # 디자인 시스템 가이드
lib/generators/plugin/  # 플러그인 생성 제너레이터
```

## Tech Stack

- Rails 8.1.3 with ERB templates
- Tailwind CSS (`tailwindcss-rails`)
- Stimulus JS (`stimulus-rails`)
- Turbo (`turbo-rails`)
- Importmap (`importmap-rails`)
- Lucide icons (`lucide-rails`)
- JBuilder for JSON
- Resend (`support@joungsik.com`)
