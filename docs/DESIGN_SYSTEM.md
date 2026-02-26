# Console 디자인 시스템

> 모던/미니멀 스타일의 일관된 UI를 위한 디자인 가이드

## 목차
- [디자인 원칙](#디자인-원칙)
- [색상 시스템](#색상-시스템)
- [타이포그래피](#타이포그래피)
- [간격 시스템](#간격-시스템)
- [컴포넌트](#컴포넌트)
- [레이아웃](#레이아웃)
- [애니메이션](#애니메이션)
- [다크 모드](#다크-모드)
- [반응형 디자인](#반응형-디자인)
- [이메일 템플릿](#이메일-템플릿)

---

## 디자인 원칙

### 1. 간결함 (Simplicity)
불필요한 장식 요소를 제거하고 콘텐츠에 집중합니다.

### 2. 여백 활용 (Whitespace)
충분한 여백을 사용하여 콘텐츠를 강조하고 시각적 피로를 줄입니다.

### 3. 일관성 (Consistency)
동일한 요소는 동일한 스타일을 사용합니다. 이 문서의 토큰을 따릅니다.

### 4. 접근성 (Accessibility)
충분한 색상 대비를 유지하고, 포커스 상태를 명확히 표시합니다.

### 5. 다크 모드 (Dark Mode)
모든 UI 요소에 다크 모드 변형(`dark:`)을 필수로 포함합니다.

---

## 색상 시스템

### Primary (Blue) - 주요 액션

| 토큰 | 라이트 모드 | 다크 모드 | 용도 |
|------|------------|----------|------|
| `primary` | `blue-600` | `blue-500` | 주요 버튼, 링크, 강조 |
| `primary-hover` | `blue-700` | `blue-400` | 호버 상태 |
| `primary-bg` | `blue-100` | `blue-900` | 배경 강조 (활성 네비 등) |
| `primary-ring` | `blue-500` | `blue-500` | 포커스 링 |

```erb
<%# Primary 버튼 예시 %>
<button class="bg-blue-600 hover:bg-blue-700 dark:bg-blue-600 dark:hover:bg-blue-500 text-white">
  버튼
</button>

<%# Primary 링크 예시 %>
<a class="text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300">
  링크
</a>
```

### Neutral (Gray) - 기본 UI

| 토큰 | 라이트 모드 | 다크 모드 | 용도 |
|------|------------|----------|------|
| `bg-base` | `gray-100` | `gray-900` | 페이지 배경 |
| `bg-surface` | `white` | `gray-800` | 카드, 컨테이너, 모달 |
| `bg-muted` | `gray-50` | `gray-700` | 중첩 컨테이너, 코드 블록 |
| `bg-hover` | `gray-50` | `gray-600` | 호버 배경 |
| `text-primary` | `gray-900` | `white` | 기본 텍스트, 제목 |
| `text-secondary` | `gray-600` | `gray-400` | 보조 텍스트, 설명 |
| `text-muted` | `gray-500` | `gray-500` | 희미한 텍스트, 힌트 |
| `border-default` | `gray-200` | `gray-700` | 카드 테두리 |
| `border-input` | `gray-300` | `gray-600` | 입력 필드 테두리 |

```erb
<%# 카드 예시 %>
<div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700">
  <h3 class="text-gray-900 dark:text-white">제목</h3>
  <p class="text-gray-600 dark:text-gray-400">설명 텍스트</p>
</div>
```

### Semantic - 상태 표시

#### Success (Green)
| 토큰 | 라이트 모드 | 다크 모드 | 용도 |
|------|------------|----------|------|
| `success` | `green-600` | `green-500` | 성공 텍스트, 아이콘 |
| `success-bg` | `green-50` | `green-900` | 성공 알림 배경 |
| `success-border` | `green-200` | `green-700` | 성공 알림 테두리 |

#### Error (Red)
| 토큰 | 라이트 모드 | 다크 모드 | 용도 |
|------|------------|----------|------|
| `error` | `red-600` | `red-500` | 에러 텍스트, 아이콘 |
| `error-bg` | `red-50` | `red-900` | 에러 알림 배경 |
| `error-border` | `red-200` | `red-700` | 에러 알림 테두리 |

#### Warning (Yellow)
| 토큰 | 라이트 모드 | 다크 모드 | 용도 |
|------|------------|----------|------|
| `warning` | `yellow-600` | `yellow-500` | 경고 텍스트, 아이콘 |
| `warning-bg` | `yellow-50` | `yellow-900` | 경고 알림 배경 |
| `warning-border` | `yellow-200` | `yellow-700` | 경고 알림 테두리 |

```erb
<%# 에러 메시지 예시 %>
<div class="bg-red-50 dark:bg-red-900 border border-red-200 dark:border-red-700 text-red-700 dark:text-red-200 px-4 py-3 rounded-md">
  에러 메시지
</div>
```

---

## 타이포그래피

### 제목 (Headings)

| 토큰 | 크기 | 굵기 | 클래스 | 용도 |
|------|------|------|--------|------|
| `heading-xl` | 2xl → 3xl | bold | `text-2xl sm:text-3xl font-bold` | 페이지 제목 |
| `heading-lg` | xl | semibold | `text-xl font-semibold` | 섹션 제목 |
| `heading-md` | lg | semibold | `text-lg font-semibold` | 카드 제목 |
| `heading-sm` | base | semibold | `text-base font-semibold` | 소제목 |

```erb
<%# 페이지 제목 %>
<h1 class="text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white">
  페이지 제목
</h1>

<%# 섹션 제목 %>
<h2 class="text-xl font-semibold text-gray-900 dark:text-white">
  섹션 제목
</h2>

<%# 카드 제목 %>
<h3 class="text-lg font-semibold text-gray-900 dark:text-white">
  카드 제목
</h3>
```

### 본문 (Body)

| 토큰 | 크기 | 굵기 | 클래스 | 용도 |
|------|------|------|--------|------|
| `body` | sm | normal | `text-sm` | 기본 본문 |
| `body-sm` | xs | normal | `text-xs` | 작은 텍스트, 캡션 |
| `label` | sm | medium | `text-sm font-medium` | 라벨, 버튼 텍스트 |

```erb
<%# 본문 텍스트 %>
<p class="text-sm text-gray-600 dark:text-gray-400">
  본문 텍스트입니다.
</p>

<%# 라벨 %>
<label class="text-sm font-medium text-gray-700 dark:text-gray-300">
  라벨
</label>
```

---

## 간격 시스템

### 간격 토큰

| 토큰 | Tailwind | 픽셀 | 용도 |
|------|----------|------|------|
| `space-xs` | `1` | 4px | 아이콘-텍스트 간격, 인라인 요소 |
| `space-sm` | `2` | 8px | 관련 요소 간격, 버튼 내부 |
| `space-md` | `4` | 16px | 섹션 내 요소 간격 |
| `space-lg` | `6` | 24px | 섹션 간 간격 |
| `space-xl` | `8` | 32px | 큰 섹션 간격, 페이지 패딩 |

### 패딩 가이드

| 요소 | 패딩 | 예시 |
|------|------|------|
| 버튼 (기본) | `px-4 py-2` | 가로 16px, 세로 8px |
| 버튼 (작은) | `px-3 py-1.5` | 가로 12px, 세로 6px |
| 입력 필드 | `px-3 py-2` | 가로 12px, 세로 8px |
| 카드 내부 | `p-4 sm:p-6` | 16px → 24px (반응형) |
| 카드 헤더 | `px-6 py-4` | 가로 24px, 세로 16px |
| 페이지 컨테이너 | `p-4 sm:p-6 lg:p-8` | 16px → 24px → 32px |

### 마진/갭 가이드

| 용도 | 값 | 예시 |
|------|-----|------|
| 폼 필드 간격 | `space-y-4` 또는 `gap-4` | 16px |
| 버튼 그룹 | `gap-2` 또는 `gap-3` | 8px ~ 12px |
| 카드 목록 | `gap-4 lg:gap-6` | 16px → 24px |
| 섹션 간격 | `mb-6` 또는 `mb-8` | 24px ~ 32px |

---

## 컴포넌트

### 버튼 (Buttons)

#### Primary 버튼
주요 액션에 사용합니다. 한 화면에 하나만 사용하는 것을 권장합니다.

```erb
<button type="submit" class="bg-blue-600 hover:bg-blue-700 dark:hover:bg-blue-500 text-white font-medium px-4 py-2 rounded-md transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800">
  저장하기
</button>
```

#### Secondary 버튼
보조 액션에 사용합니다.

```erb
<button type="button" class="bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-600 font-medium px-4 py-2 rounded-md transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800">
  취소
</button>
```

#### Danger 버튼
삭제 등 위험한 액션에 사용합니다.

```erb
<button type="button" class="bg-red-600 hover:bg-red-700 text-white font-medium px-4 py-2 rounded-md transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800">
  삭제
</button>
```

#### Ghost 버튼
덜 중요한 액션에 사용합니다.

```erb
<button type="button" class="text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-700 font-medium px-4 py-2 rounded-md transition-colors duration-200">
  더보기
</button>
```

### 입력 필드 (Input Fields)

#### 텍스트 입력

```erb
<input type="text" class="w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 rounded-md px-3 py-2 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" placeholder="입력하세요">
```

#### 텍스트에어리어

```erb
<textarea class="w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 rounded-md px-3 py-2 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none" rows="4" placeholder="내용을 입력하세요"></textarea>
```

#### 셀렉트

```erb
<select class="w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-md px-3 py-2 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
  <option>옵션 1</option>
  <option>옵션 2</option>
</select>
```

#### 라벨 + 입력 필드 조합

```erb
<div class="space-y-1">
  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
    이메일
  </label>
  <input type="email" class="w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 rounded-md px-3 py-2 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" placeholder="example@email.com">
</div>
```

### 카드 (Cards)

#### 기본 카드

```erb
<div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm overflow-hidden">
  <div class="p-4 sm:p-6">
    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
      카드 제목
    </h3>
    <p class="text-sm text-gray-600 dark:text-gray-400">
      카드 내용
    </p>
  </div>
</div>
```

#### 클릭 가능한 카드

```erb
<a href="#" class="block bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm hover:shadow-md transition-shadow duration-200 overflow-hidden">
  <div class="p-4 sm:p-6">
    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
      카드 제목
    </h3>
    <p class="text-sm text-gray-600 dark:text-gray-400">
      카드 내용
    </p>
  </div>
</a>
```

#### 헤더가 있는 카드

```erb
<div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm overflow-hidden">
  <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
    <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
      카드 제목
    </h3>
  </div>
  <div class="p-6">
    <p class="text-sm text-gray-600 dark:text-gray-400">
      카드 내용
    </p>
  </div>
</div>
```

#### 아이콘 헤더 카드 (설정/마이페이지용)

```erb
<div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm mb-6">
  <div class="p-6">
    <div class="flex items-center mb-4">
      <%= lucide_icon "user", class: "w-6 h-6 text-blue-600 dark:text-blue-400 mr-3" %>
      <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
        카드 제목
      </h2>
    </div>

    <p class="text-sm text-gray-600 dark:text-gray-400 mb-6">
      카드 설명 텍스트
    </p>

    <!-- 카드 내용 -->
  </div>
</div>
```

#### 정보 표시 카드 (프로필 정보 등)

```erb
<div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm mb-6">
  <div class="p-6">
    <div class="flex items-center mb-4">
      <%= lucide_icon "user", class: "w-6 h-6 text-blue-600 dark:text-blue-400 mr-3" %>
      <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
        프로필
      </h2>
    </div>

    <p class="text-sm text-gray-600 dark:text-gray-400 mb-6">
      계정 정보를 확인하세요.
    </p>

    <dl class="space-y-4">
      <div class="flex flex-col sm:flex-row sm:items-center">
        <dt class="text-sm font-medium text-gray-700 dark:text-gray-300 sm:w-32">
          이름
        </dt>
        <dd class="mt-1 sm:mt-0 text-sm text-gray-900 dark:text-white">
          홍길동
        </dd>
      </div>
      <div class="flex flex-col sm:flex-row sm:items-center">
        <dt class="text-sm font-medium text-gray-700 dark:text-gray-300 sm:w-32">
          이메일
        </dt>
        <dd class="mt-1 sm:mt-0 text-sm text-gray-900 dark:text-white">
          user@example.com
        </dd>
      </div>
    </dl>
  </div>
</div>
```

#### 폼 카드 (비밀번호 변경 등)

```erb
<div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm mb-6">
  <div class="p-6">
    <div class="flex items-center mb-4">
      <%= lucide_icon "lock", class: "w-6 h-6 text-blue-600 dark:text-blue-400 mr-3" %>
      <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
        비밀번호 변경
      </h2>
    </div>

    <p class="text-sm text-gray-600 dark:text-gray-400 mb-6">
      폼 설명 텍스트
    </p>

    <%= form_with url: path, method: :patch, class: "space-y-4" do |form| %>
      <div>
        <%= form.label :field, "라벨",
            class: "block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1" %>
        <%= form.password_field :field,
            required: true,
            class: "w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" %>
      </div>

      <div class="pt-2">
        <%= form.submit "저장",
            class: "inline-flex items-center justify-center px-4 py-2 text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 dark:hover:bg-blue-500 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 dark:focus:ring-offset-gray-800" %>
      </div>
    <% end %>
  </div>
</div>
```

### 알림/알럿 (Alerts)

#### 성공 알림

```erb
<div class="bg-green-50 dark:bg-green-900 border border-green-200 dark:border-green-700 text-green-700 dark:text-green-200 px-4 py-3 rounded-md">
  <div class="flex items-center gap-2">
    <%= lucide_icon "check-circle", class: "w-5 h-5" %>
    <span class="text-sm font-medium">성공적으로 저장되었습니다.</span>
  </div>
</div>
```

#### 에러 알림

```erb
<div class="bg-red-50 dark:bg-red-900 border border-red-200 dark:border-red-700 text-red-700 dark:text-red-200 px-4 py-3 rounded-md">
  <div class="flex items-center gap-2">
    <%= lucide_icon "alert-circle", class: "w-5 h-5" %>
    <span class="text-sm font-medium">오류가 발생했습니다.</span>
  </div>
</div>
```

#### 경고 알림

```erb
<div class="bg-yellow-50 dark:bg-yellow-900 border border-yellow-200 dark:border-yellow-700 text-yellow-700 dark:text-yellow-200 px-4 py-3 rounded-md">
  <div class="flex items-center gap-2">
    <%= lucide_icon "alert-triangle", class: "w-5 h-5" %>
    <span class="text-sm font-medium">주의가 필요합니다.</span>
  </div>
</div>
```

### 배지 (Badges)

#### 상태 배지

```erb
<%# 활성 %>
<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 dark:bg-green-800 text-green-800 dark:text-green-100">
  활성
</span>

<%# 비활성 %>
<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200">
  비활성
</span>

<%# 공개 %>
<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 dark:bg-blue-800 text-blue-800 dark:text-blue-100">
  공개
</span>
```

### 링크 (Links)

```erb
<%# 기본 링크 %>
<a href="#" class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 transition-colors duration-200">
  링크 텍스트
</a>

<%# 뒤로가기 링크 %>
<a href="#" class="inline-flex items-center gap-1 text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white transition-colors duration-200">
  <%= lucide_icon "arrow-left", class: "w-4 h-4" %>
  뒤로가기
</a>
```

### 네비게이션 (Navigation)

#### 네비게이션 아이템

```erb
<%# 기본 상태 %>
<a href="#" class="flex items-center gap-3 px-3 py-2 text-sm font-medium text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-700 rounded-md transition-colors duration-200">
  <%= lucide_icon "home", class: "w-5 h-5" %>
  홈
</a>

<%# 활성 상태 %>
<a href="#" class="flex items-center gap-3 px-3 py-2 text-sm font-medium text-blue-700 dark:text-blue-300 bg-blue-100 dark:bg-blue-900 rounded-md">
  <%= lucide_icon "folder", class: "w-5 h-5" %>
  컬렉션
</a>
```

---

## 레이아웃

### 페이지 구조 원칙

모든 페이지는 `application.html.erb` 레이아웃을 사용하며, 다음 구조를 따릅니다:
- 데스크탑: 좌측 고정 사이드바 (w-64) + 메인 콘텐츠 영역
- 모바일: 하단 고정 네비게이션 + 전체 너비 콘텐츠

**메인 콘텐츠 영역은 항상 `w-full`을 사용합니다.**

### 페이지 유형별 구조

| 페이지 유형 | 컨테이너 | 내부 콘텐츠 | 예시 |
|-------------|----------|-------------|------|
| 리스트 페이지 | `w-full` | 그리드 카드 목록 | 컬렉션 목록, 할 일 목록 |
| 설정/마이페이지 | `w-full` | 세로 카드 스택 | 마이페이지, 설정 |
| 폼 페이지 | `w-full` | 단일 폼 카드 | 컬렉션 생성/편집 |
| 인증 페이지 | `blank` 레이아웃 | 중앙 정렬 폼 | 로그인, 회원가입 |

### 표준 페이지 템플릿

#### 리스트 페이지 (컬렉션, 할 일 목록)

```erb
<% content_for :title, "페이지 제목" %>

<div class="w-full">
  <%# 탭 네비게이션 (필요시) %>
  <div class="border-b border-gray-200 dark:border-gray-700 mb-6">
    <nav class="-mb-px flex space-x-8">
      <!-- 탭 링크들 -->
    </nav>
  </div>

  <%# 카드 그리드 %>
  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4 lg:gap-6">
    <!-- 카드들 -->
  </div>

  <%# 빈 상태 (데이터 없을 때) %>
  <div class="text-center py-12">
    <svg class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500">...</svg>
    <h3 class="mt-2 text-sm font-medium text-gray-900 dark:text-white">내용 없음</h3>
    <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">설명 텍스트</p>
  </div>
</div>

<%# FAB (부동 액션 버튼) %>
<%= render "layouts/shared/floating_action_button", path: new_path %>
```

#### 설정/마이페이지

```erb
<% content_for(:title) { "페이지 제목" } %>

<div class="w-full">
  <%# 페이지 헤더 %>
  <div class="mb-8">
    <h1 class="text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white">
      페이지 제목
    </h1>
  </div>

  <%# 설정 카드 1 %>
  <div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm mb-6">
    <div class="p-6">
      <div class="flex items-center mb-4">
        <%= lucide_icon "icon-name", class: "w-6 h-6 text-blue-600 dark:text-blue-400 mr-3" %>
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white">섹션 제목</h2>
      </div>
      <p class="text-sm text-gray-600 dark:text-gray-400 mb-6">섹션 설명</p>
      <!-- 섹션 내용 -->
    </div>
  </div>

  <%# 설정 카드 2... %>
</div>
```

#### 폼 페이지 (생성/편집)

```erb
<% content_for :title, "폼 제목" %>

<div class="w-full">
  <%= form_with(model: resource, class: "space-y-6") do |form| %>
    <%# 상단 액션 버튼 %>
    <div class="flex justify-end mb-6">
      <%= form.submit "저장", class: "..." %>
    </div>

    <%# 폼 필드들 %>
    <div class="space-y-4">
      <!-- 입력 필드들 -->
    </div>
  <% end %>
</div>
```

### 그리드

```erb
<%# 카드 목록 그리드 %>
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 lg:gap-6">
  <!-- 카드들 -->
</div>

<%# 2컬럼 폼 레이아웃 %>
<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- 폼 필드들 -->
</div>
```

### Flexbox 패턴

```erb
<%# 헤더 (양쪽 정렬) %>
<div class="flex items-center justify-between">
  <h1>제목</h1>
  <button>액션</button>
</div>

<%# 버튼 그룹 %>
<div class="flex items-center gap-2">
  <button>버튼 1</button>
  <button>버튼 2</button>
</div>

<%# 중앙 정렬 %>
<div class="flex items-center justify-center min-h-screen">
  <!-- 콘텐츠 -->
</div>
```

### 페이지 레이아웃

```erb
<%# 사이드바 + 메인 콘텐츠 %>
<div class="lg:flex">
  <%# 사이드바 (데스크탑) %>
  <aside class="hidden lg:flex lg:w-64 lg:flex-col lg:fixed lg:inset-y-0">
    <!-- 사이드바 내용 -->
  </aside>

  <%# 메인 콘텐츠 %>
  <main class="lg:pl-64 flex-1">
    <div class="p-4 sm:p-6 lg:p-8">
      <!-- 페이지 콘텐츠 -->
    </div>
  </main>
</div>

<%# 모바일 바텀 네비게이션 %>
<nav class="lg:hidden fixed bottom-0 left-0 right-0 z-50 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700">
  <!-- 네비게이션 아이템들 -->
</nav>
```

---

## 애니메이션

### 전환 효과 (Transitions)

| 용도 | 클래스 | 사용 예시 |
|------|--------|----------|
| 색상 변경 | `transition-colors duration-200` | 버튼 호버, 링크 호버 |
| 그림자 변경 | `transition-shadow duration-200` | 카드 호버 |
| 전체 속성 | `transition-all duration-200` | 복합 효과 |
| 변환 | `transition-transform duration-200` | 확대/이동 |

```erb
<%# 버튼 - 색상 전환 %>
<button class="bg-blue-600 hover:bg-blue-700 transition-colors duration-200">
  버튼
</button>

<%# 카드 - 그림자 전환 %>
<div class="shadow-sm hover:shadow-md transition-shadow duration-200">
  카드
</div>

<%# 확대 효과 %>
<button class="hover:scale-105 transition-transform duration-200">
  버튼
</button>
```

### 애니메이션 지속 시간

| 토큰 | 값 | 용도 |
|------|-----|------|
| `duration-150` | 150ms | 매우 빠른 피드백 |
| `duration-200` | 200ms | 기본 (권장) |
| `duration-300` | 300ms | 느린 전환 |

---

## 다크 모드

### 필수 규칙
**모든 UI 요소에 `dark:` 변형을 반드시 포함해야 합니다.**

### 다크 모드 클래스 매핑

```erb
<%# 배경 %>
bg-white          → dark:bg-gray-800
bg-gray-50        → dark:bg-gray-700
bg-gray-100       → dark:bg-gray-900

<%# 텍스트 %>
text-gray-900     → dark:text-white
text-gray-700     → dark:text-gray-300
text-gray-600     → dark:text-gray-400
text-gray-500     → dark:text-gray-500

<%# 테두리 %>
border-gray-200   → dark:border-gray-700
border-gray-300   → dark:border-gray-600

<%# 링크 %>
text-blue-600     → dark:text-blue-400
hover:text-blue-700 → dark:hover:text-blue-300

<%# 포커스 링 오프셋 %>
focus:ring-offset-2 → dark:focus:ring-offset-gray-800
```

### 체크리스트
새로운 UI 요소 추가 시 확인:
- [ ] 배경색에 `dark:` 변형 추가
- [ ] 텍스트색에 `dark:` 변형 추가
- [ ] 테두리색에 `dark:` 변형 추가
- [ ] 호버 상태에 `dark:` 변형 추가
- [ ] 포커스 링 오프셋에 `dark:` 변형 추가

---

## 반응형 디자인

### 브레이크포인트

| 접두사 | 최소 너비 | 용도 |
|--------|----------|------|
| (없음) | 0px | 모바일 기본 |
| `sm:` | 640px | 작은 태블릿 |
| `md:` | 768px | 태블릿 |
| `lg:` | 1024px | 데스크탑 |
| `xl:` | 1280px | 큰 데스크탑 |

### 반응형 패턴

```erb
<%# 패딩 %>
p-4 sm:p-6 lg:p-8

<%# 텍스트 크기 %>
text-2xl sm:text-3xl

<%# 그리드 컬럼 %>
grid-cols-1 sm:grid-cols-2 lg:grid-cols-3

<%# 레이아웃 방향 %>
flex-col sm:flex-row

<%# 요소 표시/숨김 %>
hidden lg:flex       <%# 데스크탑에서만 표시 %>
lg:hidden            <%# 모바일/태블릿에서만 표시 %>
```

### 모바일 우선 (Mobile First)
항상 모바일 스타일을 기본으로 작성하고, 큰 화면에서 변경이 필요한 경우에만 브레이크포인트 접두사를 사용합니다.

```erb
<%# 좋은 예 %>
<div class="p-4 sm:p-6 lg:p-8">

<%# 나쁜 예 - 불필요한 기본값 지정 %>
<div class="sm:p-4 md:p-6 lg:p-8">
```

---

## 이메일 템플릿

### 기본 원칙

- **인라인 CSS만 사용** — Tailwind 클래스, 외부 CSS 파일 불가 (이메일 클라이언트 제약)
- **테이블 기반 레이아웃** — Outlook 등 구형 클라이언트 호환
- **라이트 모드만 지원** — 다크 모드 미지원 (`dark:` 변형 불필요)
- **`max-width: 600px`** 중앙 정렬 컨테이너
- **시스템 폰트 스택** — `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif`

### 이메일용 색상 토큰

기존 Tailwind 라이트 모드 토큰을 hex 값으로 매핑합니다.

| 토큰 | hex 값 | 용도 |
|------|--------|------|
| `bg-base` | `#f3f4f6` | 이메일 전체 배경 (gray-100) |
| `bg-surface` | `#ffffff` | 카드 배경 (white) |
| `border-default` | `#e5e7eb` | 카드 테두리 (gray-200) |
| `text-primary` | `#111827` | 기본 텍스트 (gray-900) |
| `text-secondary` | `#4b5563` | 보조 텍스트 (gray-600) |
| `text-muted` | `#6b7280` | 희미한 텍스트, 푸터 (gray-500) |
| `primary` | `#2563eb` | CTA 버튼, 링크 (blue-600) |

### 레이아웃 구조

```
배경(#f3f4f6) > 중앙 컨테이너(600px) > 헤더 + 카드(#ffffff) + 푸터
```

- **헤더**: "Console" 텍스트 로고 (이미지 차단 환경 대응), 패딩 `32px 0`
- **카드**: `border: 1px solid #e5e7eb`, `border-radius: 8px`, 패딩 `40px 32px`
- **푸터**: `t("emails.common.footer")`, 색상 `#6b7280`, 패딩 `24px 0`

### 이메일 컴포넌트

#### Primary 버튼 (CTA)

```html
<!-- 비-Outlook -->
<a href="URL" style="display: inline-block; background-color: #2563eb; color: #ffffff; font-size: 16px; font-weight: 600; text-decoration: none; padding: 12px 32px; border-radius: 6px;">
  버튼 텍스트
</a>

<!-- Outlook용 VML 폴백 -->
<!--[if mso]>
<v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" href="URL" style="height: 48px; v-text-anchor: middle; width: 200px;" arcsize="13%" fillcolor="#2563eb" stroke="f">
  <w:anchorlock/>
  <center style="color: #ffffff; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; font-size: 16px; font-weight: 600;">
    버튼 텍스트
  </center>
</v:roundrect>
<![endif]-->
```

#### 본문 텍스트

```html
<p style="font-size: 16px; line-height: 1.6; color: #111827; margin: 0 0 16px;">
  본문 텍스트
</p>
```

#### 보조 텍스트

```html
<p style="font-size: 13px; line-height: 1.5; color: #6b7280; margin: 0;">
  보조 텍스트
</p>
```

#### 링크

```html
<a href="URL" style="color: #2563eb; text-decoration: none;">링크 텍스트</a>
```

### 이메일 클라이언트 호환성

| 기능 | Gmail | Apple Mail | Outlook | Yahoo |
|------|-------|------------|---------|-------|
| 인라인 CSS | O | O | O | O |
| `<style>` 블록 | O | O | 부분 | O |
| `border-radius` | O | O | X | O |
| `background-color` | O | O | O | O |
| VML | X | X | O | X |
| 미디어 쿼리 | X | O | X | X |

> Outlook에서 `border-radius`가 무시되므로 CTA 버튼에 VML 폴백을 포함합니다.

---

## 아이콘

### Lucide 아이콘 사용

```erb
<%# 기본 사용 %>
<%= lucide_icon "icon-name", class: "w-5 h-5" %>

<%# 버튼 내 아이콘 %>
<button class="inline-flex items-center gap-2">
  <%= lucide_icon "plus", class: "w-4 h-4" %>
  추가
</button>

<%# 아이콘만 있는 버튼 %>
<button class="p-2 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700">
  <%= lucide_icon "settings", class: "w-5 h-5 text-gray-600 dark:text-gray-400" %>
</button>
```

### 아이콘 크기

| 용도 | 크기 | 클래스 |
|------|------|--------|
| 인라인 (버튼 내) | 16px | `w-4 h-4` |
| 기본 | 20px | `w-5 h-5` |
| 강조 | 24px | `w-6 h-6` |
| 빈 상태 | 48px | `w-12 h-12` |

---

## 빠른 참조

### 자주 사용하는 클래스 조합

```erb
<%# Primary 버튼 %>
class="bg-blue-600 hover:bg-blue-700 dark:hover:bg-blue-500 text-white font-medium px-4 py-2 rounded-md transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800"

<%# Secondary 버튼 %>
class="bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-600 font-medium px-4 py-2 rounded-md transition-colors duration-200"

<%# 입력 필드 %>
class="w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 rounded-md px-3 py-2 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"

<%# 카드 %>
class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm overflow-hidden"

<%# 기본 링크 %>
class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 transition-colors duration-200"
```
