# Frontend Rules

전체 디자인 기준은 [docs/DESIGN_SYSTEM.md](../../docs/DESIGN_SYSTEM.md)를 따른다.

## Principles

- 모던하고 미니멀하게 구성하고 여백과 일관성을 유지한다.
- 모든 UI 요소에 `dark:` 변형을 포함한다.
- 충분한 색상 대비와 명확한 포커스 상태를 제공한다.
- ERB에서는 Tailwind utility class를 사용한다.
- Custom CSS는 `app/assets/stylesheets/`에 작성한다.
- Tailwind 설정 진입점은 `app/assets/tailwind/application.css`이다.

## Color Tokens

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

## Components

### Primary Button

```erb
class="bg-blue-600 hover:bg-blue-700 dark:hover:bg-blue-500 text-white font-medium px-4 py-2 rounded-md transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800"
```

### Secondary Button

```erb
class="bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-600 font-medium px-4 py-2 rounded-md transition-colors duration-200"
```

### Input

```erb
class="w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
```

### Card

```erb
class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm"
```

### Link

```erb
class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 transition-colors duration-200"
```

## Typography

| 용도 | 클래스 |
|------|--------|
| 페이지 제목 | `text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white` |
| 섹션 제목 | `text-xl font-semibold text-gray-900 dark:text-white` |
| 카드 제목 | `text-lg font-semibold text-gray-900 dark:text-white` |
| 라벨 | `text-sm font-medium text-gray-700 dark:text-gray-300` |
| 본문 | `text-sm text-gray-600 dark:text-gray-400` |

## Animation

- 기본 색상 전환: `transition-colors duration-200`
- 그림자 전환: `transition-shadow duration-200`
