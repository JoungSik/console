require "test_helper"
require "support/lottery/fake_client"

class Lottery::AccountTest < ActiveSupport::TestCase
  include Lottery::FakeClientHelper

  setup do
    @user = users(:test_user)
  end

  test "아이디와 비밀번호가 필요하다" do
    account = Lottery::Account.new(user_id: @user.id)

    assert_not account.valid?
    assert account.errors.added?(:login_id, :blank)
    assert account.errors.added?(:password, :blank)
  end

  test "사용자당 하나의 계정만 연결할 수 있다" do
    create_lottery_account(@user)

    duplicate = Lottery::Account.new(user_id: @user.id, login_id: "other", password: "secret")

    assert_not duplicate.valid?
    assert duplicate.errors.added?(:user_id, :taken, value: @user.id)
  end

  test "아이디와 비밀번호를 암호화해 저장한다" do
    account = create_lottery_account(@user)

    stored = Lottery::Account.connection.select_one("SELECT login_id, password FROM accounts WHERE id = #{account.id}")

    assert_not_includes stored["login_id"], "lotto_user"
    assert_not_includes stored["password"], "lotto_pass"
    assert_equal "lotto_pass", account.reload.password
  end
end
