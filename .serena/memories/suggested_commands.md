# 개발 명령어

## 서버 실행
```bash
# 개발 서버 실행 (웹 + CSS 워치 + 백그라운드 잡)
bin/dev

# Rails 서버만 실행
bin/rails server

# Tailwind CSS 워치
bin/rails tailwindcss:watch

# 백그라운드 잡 실행
bin/jobs
```

## 테스트
```bash
# 전체 테스트 실행
bundle exec rspec

# 특정 파일 테스트
bundle exec rspec spec/models/user_spec.rb

# 특정 라인 테스트
bundle exec rspec spec/models/user_spec.rb:10
```

## 코드 품질
```bash
# Rubocop 린트
bin/rubocop

# Rubocop 자동 수정
bin/rubocop -a

# 보안 검사 (Brakeman)
bin/brakeman
```

## 데이터베이스
```bash
# 마이그레이션 실행
bin/rails db:migrate

# 데이터베이스 시드
bin/rails db:seed

# 데이터베이스 리셋
bin/rails db:reset
```

## Rails 콘솔
```bash
# Rails 콘솔
bin/rails console

# 라우트 확인
bin/rails routes
```

## 의존성 관리
```bash
# Gem 설치
bundle install

# Gem 업데이트
bundle update
```

## 배포
```bash
# Kamal 배포
bin/kamal deploy
```

## API 문서
```bash
# Swagger 문서 생성
bundle exec rake rswag:specs:swaggerize
```
