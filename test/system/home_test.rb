require "application_system_test_case"

class HomeSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
  end

  test "로그인 후 홈 화면이 표시된다" do
    sign_in_as @user
    assert_current_path root_path
  end

  test "비인증 상태에서 접근하면 랜딩 페이지가 표시된다" do
    visit root_url
    assert_text "Console"
    assert_text "포스트와 할 일을 한곳에서"
  end

  test "랜딩 페이지에서 시작하기를 클릭하면 회원가입 페이지로 이동한다" do
    visit root_url
    click_link "시작하기"
    assert_current_path new_registration_path
  end

  test "랜딩 페이지에서 로그인을 클릭하면 로그인 페이지로 이동한다" do
    visit root_url
    click_link "로그인"
    assert_current_path new_session_path
  end

  test "랜딩 페이지의 주요 버튼은 같은 너비로 화면 중앙에 배치된다" do
    visit root_url

    layout = page.evaluate_script(<<~JS)
      (() => {
        const hero = document.querySelector("section");
        const registration = hero.querySelector("a[href='#{new_registration_path}']").getBoundingClientRect();
        const session = hero.querySelector("a[href='#{new_session_path}']").getBoundingClientRect();

        return {
          registrationWidth: registration.width,
          sessionWidth: session.width,
          actionsCenter: (registration.left + session.right) / 2,
          viewportCenter: document.documentElement.clientWidth / 2
        };
      })()
    JS

    assert_in_delta layout["registrationWidth"], layout["sessionWidth"], 1
    assert_in_delta layout["viewportCenter"], layout["actionsCenter"], 1
  end

  test "랜딩 페이지의 정책 링크 묶음은 화면 중앙에 배치된다" do
    visit root_url

    layout = page.evaluate_script(<<~JS)
      (() => {
        const footer = document.querySelector("footer");
        const terms = footer.querySelector("a[href='#{terms_path}']").getBoundingClientRect();
        const privacy = footer.querySelector("a[href='#{privacy_path}']").getBoundingClientRect();

        return {
          linksCenter: (terms.left + privacy.right) / 2,
          viewportCenter: document.documentElement.clientWidth / 2
        };
      })()
    JS

    assert_in_delta layout["viewportCenter"], layout["linksCenter"], 1
  end

  test "대시보드에 지원되는 플러그인 위젯만 표시된다" do
    sign_in_as @user

    assert_text "대시보드"
    assert_selector "h2", text: "할 일 목록"
    assert_no_selector "h2", text: "포스트"
  end

  test "위젯에서 전체보기 링크로 이동할 수 있다" do
    sign_in_as @user

    todo_widget = find("h2", text: "할 일 목록").ancestor(".shadow-sm")
    within(todo_widget) do
      click_link "전체보기"
    end

    assert_current_path todo.root_path
  end

  test "공지 제목을 선택하면 상세 내용을 볼 수 있다" do
    notice = Notice.create!(
      title: "시스템 테스트 공지",
      body: "상세 공지 내용",
      published_on: Date.current,
      position: 1
    )
    sign_in_as @user

    within "#dashboard-notices" do
      click_link notice.title
    end

    assert_current_path notice_path(notice)
    assert_selector "h1", text: notice.title
    assert_text "상세 공지 내용"
  end
end
