# Console

나만의 인생 기록을 위한 프라이빗 대시보드

## 아키텍처

코어 앱 + 플러그인(Rails Engine) 구조. 인증/세션/레이아웃만 코어가 담당하고, 기능은 독립 Engine으로 분리.

```
app/                    # 코어 앱 (인증, 세션, 홈, 레이아웃)
lib/
├── plugin_registry.rb  # 플러그인 중앙 등록소
└── console/
    └── plugin_interface.rb  # 플러그인용 코어 인터페이스
engines/
├── todo/               # 할 일 목록 (Todo::List, Todo::Item)
└── bookmark/           # 북마크 (Bookmark::Group, Bookmark::Link)
```

## 플러그인 목록

| 플러그인 | 설명 | 경로 |
|---------|------|------|
| todo | 할 일 목록 | `/todos` |
| bookmark | 북마크 | `/bookmarks` |

## 기술 스택

- Ruby 3.4.1 / Rails 8.1.2
- SQLite3 (WAL mode)
- Tailwind CSS, Stimulus JS, Turbo
- Solid Queue (백그라운드 잡)
- Kamal + Docker (배포)

## 개발

```bash
bin/setup          # 초기 설정
bin/dev            # 개발 서버 시작
bin/rails test     # 테스트 실행
```

## 새 플러그인 추가

```bash
script/new_plugin.sh <plugin_name> <label> [icon] [position]

# 예시
script/new_plugin.sh note "메모" "notebook" 30
```

생성 후:
1. `Gemfile`에 `gem "<plugin_name>", path: "engines/<plugin_name>"` 추가
2. `config/routes.rb`에 `mount <Module>::Engine, at: "/<mount_path>"` 추가
3. `Dockerfile`에 gemspec COPY 추가
4. `bundle install` 실행
