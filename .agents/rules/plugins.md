# Plugin Rules

## Generator

- 새 플러그인은 반드시 `bin/rails generate plugin <name> <label> [--icon=box] [--position=100]`으로 생성한다.
- 모델, 마이그레이션, 컨트롤러, 테스트 등 Rails가 생성할 수 있는 파일은 generator로 생성한 뒤 수정한다.
- Engine 내부 파일을 루트 generator로 생성해야 한다면 산출물을 확인한 뒤 엔진 경로로 이동하고 불필요한 루트 산출물은 제거한다.

```bash
# 생성 (Gemfile, routes.rb, database.yml, Dockerfile, DashboardComponent, 위젯 뷰 자동 생성)
bin/rails generate plugin note 메모 --icon=notebook --position=30

# 삭제 (모든 변경 자동 되돌림)
bin/rails destroy plugin note 메모

# dry-run
bin/rails generate plugin note 메모 --pretend
```

## Convention

- Engine은 `isolate_namespace`로 격리한다.
- 플러그인마다 독립 SQLite DB를 사용하고 `connects_to database:`로 연결한다.
- `PluginRegistry.register`로 네비게이션을 등록하고, `dashboard_component:` 옵션으로 대시보드 위젯을 등록한다.
- 대시보드 위젯은 `Console::DashboardComponent`를 상속하고 `plugin_name`, `load_data`, `partial_path`를 구현한다.
- `Console::PluginInterface`로 코어 사용자 정보에 접근하고 `verify_plugin_enabled`로 비활성 플러그인 접근을 보호한다.
- 사용자별 플러그인 활성화 상태는 `UserPlugin`과 `/mypage/plugins`에서 관리한다.
- 비활성화 30일 후 `Console::PluginDataCleaner`와 각 Engine의 `DataCleaner`로 데이터를 삭제한다.
- 푸시 알림 항목은 `PluginRegistry.register`의 `push_notification_items:`에 `{ key:, label:, description: }` 해시 배열로 등록한다.
- 알림은 `user.send_push_notification(title:, body:, plugin_name:, item_key:)`로 전송하여 플러그인 활성 여부와 사용자 알림 설정을 확인한다.
- 레이아웃에서 메인 앱 라우트 헬퍼에는 `main_app.` 접두사를 사용한다.
- Engine 뷰에서 자체 라우트 헬퍼에는 엔진명 접두사를 사용한다. 예: `todo.lists_path`, `posts.posts_path`.
- DB가 분리되어 있으므로 테이블명에 네임스페이스 접두사를 붙이지 않고 `table_name_prefix = ""`를 유지한다.
