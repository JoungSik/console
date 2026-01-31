---
status: completed
created: 2026-01-31
updated: 2026-01-31
---

# 디자인 시스템 구축 및 문서화

## 개요
- **목표:** 모던/미니멀 스타일의 체계적인 디자인 시스템 구축 및 문서화
- **범위:** 색상, 타이포그래피, 간격, 컴포넌트, 레이아웃, 애니메이션 전체
- **예상 영향:** 모든 뷰 파일의 일관성 향상, 향후 개발 생산성 증가

## 배경

### 현재 문제점
분석 결과 다음과 같은 문제점이 발견됨:

1. **입력 필드 스타일 불일치**
   - `sessions/new.html.erb`: `rounded-lg`, `px-4 py-2.5`
   - `passwords/*.html.erb`: `rounded-md`, `px-3 py-2`
   - focus 스타일도 각각 다름

2. **다크 모드 누락**
   - `_link_fields.html.erb`: URL, description 필드
   - `_form_errors.html.erb`: 전체

3. **중복 코드**
   - 버튼, 카드, 입력 필드 스타일이 각 파일에 반복
   - 컴포넌트화 되어있지 않음

4. **보조 텍스트 색상 불일치**
   - `text-gray-600` vs `text-gray-700`

5. **전환 효과 불일치**
   - 다양한 transition 패턴 혼재

## 디자인 시스템 설계

### 디자인 원칙 (모던/미니멀)
1. **간결함**: 불필요한 장식 요소 제거
2. **여백 활용**: 충분한 여백으로 콘텐츠 강조
3. **일관성**: 동일한 요소는 동일한 스타일
4. **접근성**: 충분한 색상 대비, 포커스 상태 명확화
5. **다크 모드**: 모든 요소에 다크 모드 지원

### 색상 시스템

#### Primary (Blue)
| 토큰 | 라이트 | 다크 | 용도 |
|------|--------|------|------|
| primary | `blue-600` | `blue-500` | 주요 버튼, 링크 |
| primary-hover | `blue-700` | `blue-400` | 호버 상태 |
| primary-bg | `blue-100` | `blue-900` | 배경 강조 |

#### Neutral (Gray)
| 토큰 | 라이트 | 다크 | 용도 |
|------|--------|------|------|
| bg-base | `gray-100` | `gray-900` | 페이지 배경 |
| bg-surface | `white` | `gray-800` | 카드, 컨테이너 |
| bg-muted | `gray-50` | `gray-700` | 중첩 컨테이너 |
| text-primary | `gray-900` | `white` | 기본 텍스트 |
| text-secondary | `gray-600` | `gray-400` | 보조 텍스트 |
| text-muted | `gray-500` | `gray-500` | 희미한 텍스트 |
| border-default | `gray-200` | `gray-700` | 기본 테두리 |
| border-input | `gray-300` | `gray-600` | 입력 필드 테두리 |

#### Semantic
| 토큰 | 라이트 | 다크 | 용도 |
|------|--------|------|------|
| success | `green-600` | `green-500` | 성공 상태 |
| success-bg | `green-50` | `green-900` | 성공 배경 |
| error | `red-600` | `red-500` | 에러 상태 |
| error-bg | `red-50` | `red-900` | 에러 배경 |
| warning | `yellow-600` | `yellow-500` | 경고 상태 |

### 타이포그래피

| 토큰 | 크기 | 굵기 | 용도 |
|------|------|------|------|
| heading-xl | `text-2xl sm:text-3xl` | `font-bold` | 페이지 제목 |
| heading-lg | `text-xl` | `font-semibold` | 섹션 제목 |
| heading-md | `text-lg` | `font-semibold` | 카드 제목 |
| body | `text-sm` | `font-normal` | 본문 |
| body-sm | `text-xs` | `font-normal` | 작은 텍스트 |
| label | `text-sm` | `font-medium` | 라벨, 버튼 |

### 간격 시스템

| 토큰 | 값 | 용도 |
|------|-----|------|
| space-xs | `1` (4px) | 아이콘-텍스트 간격 |
| space-sm | `2` (8px) | 관련 요소 간격 |
| space-md | `4` (16px) | 섹션 내 간격 |
| space-lg | `6` (24px) | 섹션 간 간격 |
| space-xl | `8` (32px) | 큰 섹션 간격 |

### 컴포넌트 스타일

#### 버튼
```
// Primary
bg-blue-600 hover:bg-blue-700 dark:bg-blue-600 dark:hover:bg-blue-500
text-white font-medium
px-4 py-2 rounded-md
transition-colors duration-200
focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2
dark:focus:ring-offset-gray-800

// Secondary
bg-white dark:bg-gray-700
border border-gray-300 dark:border-gray-600
text-gray-700 dark:text-gray-200
hover:bg-gray-50 dark:hover:bg-gray-600
px-4 py-2 rounded-md
transition-colors duration-200

// Danger
bg-red-600 hover:bg-red-700 text-white
px-4 py-2 rounded-md
transition-colors duration-200
```

#### 입력 필드
```
w-full
bg-white dark:bg-gray-700
border border-gray-300 dark:border-gray-600
text-gray-900 dark:text-white
placeholder-gray-500 dark:placeholder-gray-400
rounded-md px-3 py-2
transition-colors duration-200
focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent
```

#### 카드
```
bg-white dark:bg-gray-800
border border-gray-200 dark:border-gray-700
rounded-lg shadow-sm
overflow-hidden
```

#### 링크
```
text-blue-600 dark:text-blue-400
hover:text-blue-800 dark:hover:text-blue-300
transition-colors duration-200
```

### 레이아웃 패턴

#### 컨테이너
- 최대 너비: `max-w-7xl mx-auto`
- 패딩: `px-4 sm:px-6 lg:px-8`

#### 그리드
- 카드 목록: `grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 lg:gap-6`
- 폼 필드: `grid grid-cols-1 md:grid-cols-2 gap-4`

### 애니메이션

| 용도 | 값 |
|------|-----|
| 기본 전환 | `transition-colors duration-200` |
| 그림자 전환 | `transition-shadow duration-200` |
| 전체 전환 | `transition-all duration-200` |
| 호버 확대 | `hover:scale-105 transition-transform duration-200` |

## 작업 계획

### Task 1: 디자인 시스템 문서 작성
- **목표:** 디자인 시스템 가이드 문서 생성
- **파일:** `docs/DESIGN_SYSTEM.md` (신규)
- **상세 내용:**
  1. 디자인 원칙 정의
  2. 색상 토큰 문서화
  3. 타이포그래피 가이드
  4. 간격 시스템 정의
  5. 컴포넌트 스타일 가이드 (버튼, 입력, 카드 등)
  6. 레이아웃 패턴 가이드
  7. 애니메이션 가이드
  8. 다크 모드 가이드
- **검증:** 문서 완성도 확인

### Task 2: CLAUDE.md 업데이트
- **목표:** 디자인 시스템 참조 가이드를 CLAUDE.md에 추가
- **파일:** `CLAUDE.md`
- **상세 내용:**
  1. 디자인 시스템 문서 참조 링크 추가
  2. 핵심 스타일 토큰 요약 추가
  3. 컴포넌트 사용 예시 추가
- **검증:** CLAUDE.md에서 디자인 가이드 쉽게 찾을 수 있는지 확인

### Task 3: 다크 모드 누락 수정
- **목표:** 다크 모드 누락된 파일 수정
- **수정 파일:**
  - `app/views/collections/_link_fields.html.erb`
  - `app/views/shared/_form_errors.html.erb`
- **상세 내용:**
  1. URL 입력 필드에 다크 모드 클래스 추가
  2. description 입력 필드에 다크 모드 클래스 추가
  3. form_errors 파셜에 다크 모드 클래스 추가
- **검증:** 다크 모드에서 UI 확인

### Task 4: 입력 필드 스타일 통일
- **목표:** 모든 입력 필드 스타일 일관성 확보
- **수정 파일:**
  - `app/views/sessions/new.html.erb`
  - `app/views/passwords/new.html.erb`
  - `app/views/passwords/edit.html.erb`
- **상세 내용:**
  1. rounded-md로 통일
  2. px-3 py-2로 통일
  3. focus 스타일 통일 (ring-2 ring-blue-500)
  4. placeholder 색상 통일
- **검증:** 모든 폼 페이지에서 입력 필드 스타일 동일한지 확인

### Task 5: 버튼 스타일 통일
- **목표:** 버튼 스타일 일관성 확보
- **수정 파일:** 버튼이 포함된 모든 뷰 파일
- **상세 내용:**
  1. Primary 버튼 스타일 통일
  2. Secondary 버튼 스타일 통일
  3. Danger 버튼 스타일 통일
  4. 전환 효과 통일 (transition-colors duration-200)
- **검증:** 모든 페이지에서 버튼 스타일 동일한지 확인

### Task 6: 보조 텍스트 색상 통일
- **목표:** text-gray-600/700 불일치 해결
- **수정 파일:** 해당 클래스 사용하는 모든 뷰 파일
- **상세 내용:**
  1. 보조 텍스트는 `text-gray-600 dark:text-gray-400`으로 통일
- **검증:** 모든 보조 텍스트 색상 일관성 확인

## 테스트 계획
- [ ] 라이트 모드에서 모든 페이지 UI 확인
- [ ] 다크 모드에서 모든 페이지 UI 확인
- [ ] 모바일 반응형 확인 (sm, md 브레이크포인트)
- [ ] 데스크탑 반응형 확인 (lg 브레이크포인트)
- [ ] 포커스 상태 접근성 확인
- [ ] 버튼 호버 상태 확인

## 롤백 계획
- Git을 통해 변경 전 상태로 복원 가능
- 각 Task별로 커밋하여 부분 롤백 가능

## 열린 질문
- [ ] Tailwind CSS 커스텀 클래스(@apply)를 사용한 컴포넌트 클래스 정의 필요 여부
- [ ] ViewComponent 도입 여부 (뷰 파일만 수정 가능한 제약 조건 고려)
