# 디자인 시스템 요약

> 전체 문서: `docs/DESIGN_SYSTEM.md`

## 디자인 원칙
- 모던/미니멀 스타일
- 다크 모드 필수 (모든 요소에 `dark:` 변형)
- 일관된 컴포넌트 스타일

## 핵심 색상 토큰
| 용도 | 라이트 | 다크 |
|------|--------|------|
| 페이지 배경 | `bg-gray-100` | `dark:bg-gray-900` |
| 카드/컨테이너 | `bg-white` | `dark:bg-gray-800` |
| 기본 텍스트 | `text-gray-900` | `dark:text-white` |
| 보조 텍스트 | `text-gray-600` | `dark:text-gray-400` |
| 라벨 | `text-gray-700` | `dark:text-gray-300` |
| 기본 테두리 | `border-gray-200` | `dark:border-gray-700` |
| 입력 테두리 | `border-gray-300` | `dark:border-gray-600` |

## 컴포넌트 클래스

### Primary 버튼
```
bg-blue-600 hover:bg-blue-700 dark:hover:bg-blue-500 text-white font-medium px-4 py-2 rounded-md transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800
```

### Secondary 버튼
```
bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-600 font-medium px-4 py-2 rounded-md transition-colors duration-200
```

### 입력 필드
```
w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent
```

### 카드
```
bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm
```

## 애니메이션
- 기본: `transition-colors duration-200`
- 그림자: `transition-shadow duration-200`
