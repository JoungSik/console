# Project Rules

## Architecture

코어 앱과 플러그인(Rails Engine) 구조로 구성한다. 인증과 세션만 코어가 담당하고, 기능은 독립 Engine으로 분리한다.

## Project Structure

```text
app/                    # 코어 앱 (인증, 세션, 홈, 레이아웃)
├── controllers/        # 코어 컨트롤러
├── models/             # 코어 모델 (User, Session, UserPlugin, PushRegistration)
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

## Service Design

- 서비스의 구현 형태는 상태 보유 여부를 기준으로 결정한다.
- 인스턴스 상태 없이 입력을 처리하거나 설정을 조회하는 기능은 `module`과 `module_function`으로 구현한다.
- 요청별 상태, 생성 시 주입된 의존성 또는 객체 생명주기를 보유해야 할 때만 `class`를 사용한다.
- 네임스페이스는 `module`로 정의하고 내부 상수는 `Fcm::NotificationSender`처럼 명시적인 네임스페이스 표기를 사용한다.
- 상태가 없는 협력 객체는 불필요하게 인스턴스화하지 않고 모듈 자체를 기본 의존성으로 주입한다.
- 예외 타입은 `raise`와 `rescue`를 위해 클래스로 정의하되, 동작이 없는 관련 예외마다 파일을 분리하지 않고 네임스페이스 루트 파일에 함께 선언할 수 있다.
- 서비스 파일이나 상수 구조를 변경한 뒤에는 `bin/rails zeitwerk:check`와 관련 테스트를 실행한다.

## Internationalization

- 실제로 사용자에게 표시되는 메시지만 I18n으로 관리한다.
- 화면 상태, flash, validation 오류, 이메일, 알림, 푸시, JavaScript 안내처럼 사용자가 읽는 메시지는 locale 키를 사용한다.
- 내부 예외, 로그, `console` 진단 메시지와 API 상태·오류 코드는 I18n 대상에서 제외한다.
- 내부 오류 메시지를 사용자에게 그대로 노출하지 않고, 사용자 경계에서 상황에 맞는 I18n 메시지로 변환한다.
- JavaScript와 Bridge는 사용자 문구를 직접 만들거나 외부 응답의 메시지를 표시하지 않고, 서버가 렌더링한 번역문 또는 오류 코드에 대응하는 locale 키를 사용한다.

## Tech Stack

- Rails 8.1.3 with ERB templates
- Tailwind CSS (`tailwindcss-rails`)
- Stimulus JS (`stimulus-rails`)
- Turbo (`turbo-rails`)
- Importmap (`importmap-rails`)
- Lucide icons (`lucide-rails`)
- Firebase Cloud Messaging (HTTP v1, Web, Android, iOS)
- Resend (`support@joungsik.com`)
