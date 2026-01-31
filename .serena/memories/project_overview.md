# Console 프로젝트 개요

## 프로젝트 목적
Rails 기반 웹 콘솔 애플리케이션

## 기술 스택
- **프레임워크**: Rails 8.1.2
- **언어**: Ruby
- **데이터베이스**: SQLite3
- **프론트엔드**:
  - Tailwind CSS (tailwindcss-rails)
  - Stimulus JS (stimulus-rails)
  - Turbo (turbo-rails)
  - Importmap (importmap-rails)
  - Lucide icons (lucide-rails)
- **에셋 파이프라인**: Propshaft
- **백그라운드 잡**: Solid Queue + Mission Control
- **인증**: bcrypt
- **권한 관리**: Pundit
- **테스트**: RSpec, Capybara, Selenium
- **API 문서**: rswag/swagger
- **배포**: Kamal, Docker
- **크론 작업**: Whenever

## 프로젝트 구조
```
app/
├── assets/       # CSS, 이미지 등 에셋
├── channels/     # Action Cable 채널
├── controllers/  # 컨트롤러
├── helpers/      # 뷰 헬퍼
├── javascript/   # Stimulus 컨트롤러
├── jobs/         # Active Job
├── mailers/      # 메일러
├── models/       # 모델
├── policies/     # Pundit 정책
└── views/        # ERB 템플릿

bin/              # 실행 스크립트
config/           # 설정 파일
db/               # 데이터베이스 마이그레이션
lib/              # 라이브러리 코드
spec/             # RSpec 테스트
swagger/          # API 문서
```

## 주요 제약사항 (CLAUDE.md)
- 뷰 파일만 수정 가능
- 컨트롤러/모델/서비스 변경 불가
- 모든 UI에 다크 모드 지원 필수
