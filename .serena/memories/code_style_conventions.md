# 코드 스타일 및 컨벤션

## Ruby/Rails 스타일
- **스타일 가이드**: rubocop-rails-omakase 사용
- **린터**: Rubocop (`bin/rubocop`)

## 주석 언어
- 한국어 주석 사용

## 프론트엔드 스타일
### Tailwind CSS
- 유틸리티 클래스 사용
- 커스텀 CSS는 `app/assets/stylesheets/`에 작성
- Tailwind 설정: `app/assets/tailwind/application.css`

### 다크 모드 필수
모든 UI 요소에 `dark:` 변형 포함:
- 배경: `bg-white dark:bg-gray-800`
- 카드: `bg-gray-50 dark:bg-gray-700`
- 텍스트: `text-gray-900 dark:text-white`
- 보조 텍스트: `text-gray-500 dark:text-gray-400`
- 테두리: `border-gray-200 dark:border-gray-700`
- 입력 테두리: `border-gray-300 dark:border-gray-600`
- 호버: `hover:bg-gray-50 dark:hover:bg-gray-600`
- 폼 입력: `bg-white dark:bg-gray-700 text-gray-900 dark:text-white`
- 상태 배지: `bg-green-100 dark:bg-green-800 text-green-800 dark:text-green-100`

## JavaScript
- Stimulus 컨트롤러 패턴 사용
- ES 모듈 (importmap)

## 테스트
- Minitest 사용
- 테스트 파일 위치: `test/`

## 디자인 패턴
- Service Object 패턴 선호
- Pundit으로 권한 관리
- DRY, KISS, YAGNI, SOLID 원칙 적용
