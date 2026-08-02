# Hotwire Rules

Rails 웹 UI는 JavaScript 애플리케이션을 별도로 만들지 않고 서버가 HTML을 반환하는 Hotwire 방식을 기본으로 한다.
“Turbo를 최대한 활용한다”는 모든 화면을 Frame으로 감싸는 것이 아니라, 화면 전환과 변경 범위에 맞는 Turbo 기능을 우선 선택하는 것을 의미한다.

## 기본 선택 순서

새 UI 흐름을 구현하기 전에 다음 순서로 설계한다.

1. 독립 화면 간 이동은 Turbo Drive로 처리한다.
2. 한 화면 안에서 독립적으로 탐색하는 영역은 Turbo Frame으로 처리한다.
3. 사용자 요청으로 현재 화면 일부를 변경하면 Turbo Stream으로 처리한다.
4. 서로 떨어진 영역이 광범위하게 바뀌고 개별 Stream target이 오히려 복잡하면 morph refresh를 사용한다.
5. Stimulus는 위 방법만으로 해결할 수 없는 클라이언트 동작에만 사용한다.

`data-turbo="false"`와 수동 `fetch`는 기본 해결책으로 사용하지 않는다. 불가피하게 Turbo를 비활성화할 때는 이유를 설명하고 일반 브라우저 fallback을 테스트한다.

## Turbo Drive

- 일반 링크와 폼의 top-level 화면 전환은 Turbo Drive에 맡긴다.
- 상세, 작성, 수정 화면처럼 브라우저 history와 Native navigation stack에 남아야 하는 화면은 top-level 방문을 유지한다.
- Frame 안에서 top-level 화면으로 이동하는 링크에는 `data-turbo-frame="_top"`을 지정한다.
- 성공한 `POST`, `PATCH`, `PUT`, `DELETE`의 HTML 응답은 `303 See Other`로 redirect한다.
- 검증 오류는 입력값과 오류 메시지를 포함한 화면을 `422 Unprocessable Content`로 render한다.
- GET 이외 요청을 성공 후 `200 OK` HTML로 직접 render하지 않는다.

## Turbo Frame

- 전체 layout과 함께 이동할 필요가 없는 독립 탐색 영역에만 사용한다.
- Frame ID는 페이지에서 고유하고 재렌더링 후에도 안정적이어야 한다.
- Frame 요청의 응답에는 요청한 ID와 일치하는 `<turbo-frame>`을 포함한다.
- 탭, 필터, 페이지네이션처럼 URL 공유와 뒤로가기 의미가 있는 Frame 탐색에는 `data-turbo-action="advance"`를 사용한다.
- Frame 내부 링크가 상세·작성·수정 화면으로 이동한다면 `_top` target으로 Drive 흐름을 복원한다.
- 한 번에 대부분의 페이지를 감싸는 거대한 Frame이나 불필요하게 중첩된 Frame은 만들지 않는다.

## Turbo Stream

- 생성, 상태 전환, 삭제처럼 현재 화면에 머물러야 하는 변경은 요청에 대한 직접 Stream 응답을 우선한다.
- `.turbo_stream.erb` 템플릿을 사용해 변경 target을 명시적으로 드러낸다.
- target은 `dom_id`, 명명된 Frame ID, `#flash`처럼 안정적인 DOM ID를 사용한다.
- `replace`는 target 자체와 속성이 바뀔 때, `update`는 target을 유지하고 내부 HTML만 바꿀 때 사용한다.
- 항목 변경 시 해당 항목만 보지 말고 정렬, 개수, 빈 상태, 반복 항목, 관련 action 상태까지 함께 갱신해야 하는지 확인한다.
- 성공과 실패 결과는 안정적인 `#flash` target을 갱신한다.
- 같은 endpoint에서 `turbo_stream`과 `html`을 모두 지원하여 JavaScript나 Bridge가 없어도 기능이 동작하게 한다.
- 사용자 요청에 대한 직접 응답이면 Action Cable/model broadcast를 추가하지 않는다. 다른 세션에 실시간 전파해야 하는 명확한 요구가 있을 때만 broadcast를 사용한다.

## Morph와 영속 DOM

- 전역 refresh는 `turbo_refreshes_with method: :morph, scroll: :preserve`를 기본으로 한다.
- morph가 안정적으로 대응할 수 있도록 반복 요소와 갱신 target에 고유한 DOM ID를 부여한다.
- `data-turbo-permanent`는 재생성하면 안 되는 실제 클라이언트 상태가 있을 때만 사용한다. 일반 폼, 입력 오류 보존, 편의 목적에는 사용하지 않는다.
- morph 대상에서 보존해야 하는 입력값이나 focus가 있다면 Turbo의 기본 동작을 먼저 활용하고 필요한 경우에만 morph event를 사용한다.

## Stimulus

- Stimulus는 DOM 이벤트 연결, 토글, 브라우저 API, Bridge 연결 같은 얇은 progressive enhancement 역할만 담당한다.
- 서버 데이터 변경과 HTML 생성은 Rails controller/view가 담당한다.
- Turbo가 처리할 수 있는 폼 제출과 탐색을 Stimulus의 `fetch`, `window.location`, 수동 HTML 삽입으로 다시 구현하지 않는다.
- controller는 `target`, `value`, `class`, `action` API를 사용하고 전역 selector 의존을 최소화한다.
- `setTimeout`, `setInterval`, event listener, observer, 비동기 후속 작업은 `disconnect()`에서 정리한다.
- Turbo 방문, Frame 교체, morph 이후 controller가 다시 연결되어도 타이머나 요청이 중복되지 않아야 한다.

## Hotwire Native와 Bridge

- Native 감지는 `turbo-rails`가 제공하는 `hotwire_native_app?`를 사용한다. 별도 User-Agent 판별 helper를 만들지 않는다.
- 일반 브라우저의 미인증 요청은 로그인 redirect, Hotwire Native 미인증 요청은 복귀 URL을 보존한 `401 Unauthorized`를 반환한다.
- Native navigation에는 `recede_or_redirect_to`, `resume_or_redirect_to`, `refresh_or_redirect_to` 계열 helper를 우선 사용하고 HTML fallback URL을 항상 제공한다.
- Bridge controller는 `bridge--*` namespace를 사용하고 플랫폼 공용 component 이름과 message 계약을 유지한다.
- Bridge가 연결되지 않은 웹 브라우저에서도 submit 버튼, 메뉴, 링크를 숨기거나 비활성화하지 않는다.
- 플랫폼별 Swift/Kotlin 구현이 없어도 모든 핵심 기능이 웹 UI만으로 동작해야 한다.
- 웹 페이지 제목 영역에는 `data-native-page-title`, Native 자체 뒤로가기로 대체되는 웹 탐색 영역에는 `data-native-page-navigation`을 지정한다.
- 뷰에서는 위 marker만 선언한다. 공통 layout이 `hotwire_native_app?`일 때만 `hotwire_native.css`를 로드해 marker 영역을 숨기고, 일반 브라우저에서는 그대로 노출한다.

## Layout과 DOM 계약

- 모든 top-level 화면은 고유한 `<title>`을 제공한다.
- `application`과 `blank` layout의 `<main>` 여백은 `layout_main_classes`를 사용하며 Native 분기를 중복 작성하지 않는다.
- top-level 화면을 추가하거나 경로를 변경하면 `HotwireNativePageContractTest`에 경로와 title을 등록한다.
- Native에서 숨기는 제목 위에 `pt-*` 또는 `py-*` 여백이 있으면 `data-native-top-flush` 계약과 모바일 viewport의 실제 상단 좌표를 검증한다.
- flash는 모든 layout에서 동일한 `#flash` target을 사용한다.
- partial의 root ID는 Stream 교체 전후 동일해야 한다.
- HTML의 의미 구조와 접근성을 유지하고 Turbo target을 위해 중복 wrapper를 만들지 않는다.
- Engine 뷰의 Stream partial 경로와 route helper에는 해당 Engine namespace를 명시한다.

## 테스트

Hotwire 동작을 변경하면 다음 항목을 변경 범위에 맞게 검증한다.

- Integration test
  - 일반 HTML 요청의 `303` redirect와 fallback URL
  - 검증 오류의 `422`, 입력값과 오류 메시지 보존
  - Turbo Stream의 `action`, `target`, 반환 HTML
  - 일반 브라우저 redirect와 Hotwire Native `401`
- System test
  - Stream 동작 후 현재 URL 유지
  - Frame 탐색의 URL 변경과 뒤로가기·앞으로가기
  - target 영역, 빈 상태, 정렬, flash의 실제 갱신
  - 직접 URL 접근과 새로고침
  - 데스크톱과 모바일에서 동일 기능 동작
  - Native User-Agent와 모바일 viewport에서 상단 좌표와 document overflow
- `data-turbo="false"`, 수동 navigation, 수동 `fetch`를 추가했다면 Turbo로 해결할 수 없는 이유와 fallback test가 반드시 있어야 한다.
- Native top-level UI를 변경하면 `bin/rails test test/integration/hotwire_native_page_contract_test.rb`와 `bin/rails test test/system/hotwire_native_layout_test.rb`를 실행한다.

## 리뷰 체크리스트

- 이 동작은 Drive, Frame, Stream, morph 중 가장 작은 변경 범위를 선택했는가?
- JavaScript 없이도 서버 렌더링과 HTML fallback으로 완료할 수 있는가?
- 브라우저 history, 새로고침, 직접 URL 접근이 자연스러운가?
- Stream target과 partial root ID가 안정적인가?
- 성공 `303`, 검증 실패 `422`, Native navigation 응답이 올바른가?
- Turbo 재연결 후 Stimulus 부작용이 중복되지 않는가?
