require "test_helper"
require "support/lottery/fake_client"

class Lottery::AccountsTest < ActionDispatch::IntegrationTest
  include Lottery::FakeClientHelper

  setup do
    @user = users(:test_user)
    sign_in_as @user
  end

  test "계정이 없으면 개요 대신 계정 연결 화면으로 보낸다" do
    get lottery.root_url

    assert_redirected_to lottery.new_account_url
  end

  test "로그인에 성공하면 계정을 저장하고 내역을 불러온다" do
    fake_client = Lottery::FakeClient.new(entries: [ Lottery::FakeClient.build_entry ])

    assert_difference -> { Lottery::Account.count } => 1, -> { Lottery::PurchaseRecord.count } => 1 do
      use_fake_lottery_client(fake_client) do
        post lottery.account_url, params: { account: { login_id: "lotto_user", password: "lotto_pass" } }
      end
    end

    assert_response :see_other
    assert_redirected_to lottery.root_url
    assert_equal @user.id, Lottery::Account.last.user_id
  end

  test "로그인에 실패하면 저장하지 않고 안내한다" do
    fake_client = Lottery::FakeClient.new(errors: { balance: DhLottery::AuthenticationError.new("실패") })

    assert_no_difference -> { Lottery::Account.count } do
      use_fake_lottery_client(fake_client) do
        post lottery.account_url, params: { account: { login_id: "lotto_user", password: "wrong" } }
      end
    end

    assert_response :unprocessable_entity
    assert_select "li", text: I18n.t("lottery.errors.authentication_failed")
  end

  test "비밀번호를 비워 수정하면 기존 비밀번호를 유지한다" do
    account = create_lottery_account(@user)

    use_fake_lottery_client do
      patch lottery.account_url, params: { account: { login_id: "lotto_user", password: "" } }
    end

    assert_redirected_to lottery.root_url
    assert_equal "lotto_pass", account.reload.password
  end

  test "수정 화면에 저장된 비밀번호를 노출하지 않는다" do
    create_lottery_account(@user)

    get lottery.edit_account_url

    assert_response :success
    assert_select "input[name='account[password]']:not([value])"
    assert_no_match "lotto_pass", response.body
  end

  test "계정 연결을 해제하면 계정과 내역을 삭제한다" do
    account = create_lottery_account(@user)
    account.purchase_records.create!(product_name: "로또6/45")

    delete lottery.account_url

    assert_response :see_other
    assert_not Lottery::Account.exists?(account.id)
    assert_equal 0, Lottery::PurchaseRecord.count
  end
end
