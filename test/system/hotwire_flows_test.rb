require "application_system_test_case"

class HotwireFlowsTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
    sign_in_as @user
  end

  test "Journal 생성 검증 수정 인덱스 삭제를 Turbo 흐름으로 처리한다" do
    visit posts.root_url
    original_path = current_path

    fill_in "post[body]", with: ""
    click_button "포스트 남기기"
    assert_text "개의 오류가 있습니다"
    assert_current_path original_path

    fill_in "post[body]", with: "브라우저 Stream 포스트"
    click_button "포스트 남기기"
    assert_text "포스트가 생성되었습니다."
    assert_text "브라우저 Stream 포스트"
    assert_field "post[body]", with: ""
    assert_current_path original_path

    post = Journal::Post.find_by!(body: "브라우저 Stream 포스트")
    within("#post_#{post.id}") do
      find("a[aria-label='포스트 수정']").click
    end
    assert_current_path posts.edit_post_path(post)

    fill_in "post[body]", with: "수정된 브라우저 포스트"
    click_button "포스트 수정"
    assert_current_path posts.post_path(post)
    assert_text "수정된 브라우저 포스트"

    within("main") { find("a[href='#{posts.root_path}']", match: :first).click }
    assert_current_path posts.root_path
    within("#post_#{post.id}") do
      accept_confirm { find("a[aria-label='포스트 삭제']").click }
    end
    assert_current_path posts.root_path
    assert_text "포스트가 삭제되었습니다."
    assert_no_text "수정된 브라우저 포스트"
  end

  test "Journal 상세 삭제는 상위 목록으로 이동한다" do
    post = Journal::Post.create!(body: "상세 삭제 대상", user_id: @user.id)
    visit posts.post_url(post)

    within("#post_#{post.id}") do
      accept_confirm { find("a[aria-label='포스트 삭제']").click }
    end

    assert_current_path posts.root_path
    assert_text "포스트가 삭제되었습니다."
  end

  test "Todo 탭은 URL history를 유지하고 목록 링크는 top-level로 이동한다" do
    active_list = Todo::List.create!(title: "일반 목록", user_id: @user.id)
    Todo::List.create!(title: "보관 목록", user_id: @user.id, archived_at: Time.current)
    visit todo.lists_url

    click_link "보관됨"
    assert_current_path todo.lists_path(tab: :archived)
    assert_text "보관 목록"
    assert_no_text "일반 목록"

    page.go_back
    assert_current_path todo.lists_path
    assert_text active_list.title

    page.go_forward
    assert_current_path todo.lists_path(tab: :archived)
    click_link "보관 목록"
    assert_current_path todo.list_path(Todo::List.find_by!(title: "보관 목록"))
  end

  test "Todo 반복 항목 완료 취소 삭제는 같은 URL에서 컨테이너를 갱신한다" do
    list = Todo::List.create!(title: "반복 테스트", user_id: @user.id)
    item = list.items.create!(
      title: "매일 확인", due_date: Date.current, recurrence: "daily", completed: false
    )
    visit todo.list_url(list)
    original_path = current_path

    find("button[aria-label='할 일 완료']").click
    assert_current_path original_path
    assert_text "할 일이 수정되었습니다."
    assert item.reload.completed?
    assert_equal 2, page.all("span", text: "매일 확인", exact_text: true).size

    within("#item_#{item.id}") do
      find("button[aria-label='할 일 완료 해제']").click
    end
    assert_current_path original_path
    assert_selector "#item_#{item.id} button[aria-label='할 일 완료']"
    assert_not item.reload.completed?
    assert_equal 1, page.all("span", text: "매일 확인", exact_text: true).size

    within("#item_#{item.id}") do
      accept_confirm { find("button[aria-label='할 일 삭제']").click }
    end
    assert_current_path original_path
    assert_text "아직 할 일이 없습니다."
  end

  test "플러그인과 푸시 알림 설정은 같은 URL에서 카드만 갱신한다" do
    visit mypage_plugins_url
    original_path = current_path

    within("#plugin_posts") { click_button }
    assert_current_path original_path
    assert_text I18n.t("settings.plugins.deactivated", plugin: "포스트")
    within("#plugin_posts") { assert_button I18n.t("settings.plugins.activate") }

    visit mypage_push_notifications_url
    original_path = current_path
    assert_selector "[data-controller~='web-push-subscription']"
    assert_selector "[data-web-push-subscription-target='subscriptionBadge']"
    assert_selector "[data-web-push-subscription-target='permissionBadge']"
    assert_no_text I18n.t("settings.push_notifications.status_checking")
    assert_no_text I18n.t("settings.push_notifications.status.subscribed")

    within("#notification_todos_due_date_reminder") { click_button }
    assert_current_path original_path
    assert_text I18n.t("settings.push_notifications.item_disabled")
  end
end
