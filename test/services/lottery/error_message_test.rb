require "test_helper"

class Lottery::ErrorMessageTest < ActiveSupport::TestCase
  test "하위 예외를 구체적인 안내로 바꾼다" do
    assert_equal I18n.t("lottery.errors.password_change_required"),
      Lottery::ErrorMessage.for(DhLottery::PasswordChangeRequiredError.new("변경 필요"))
    assert_equal I18n.t("lottery.errors.authentication_failed"),
      Lottery::ErrorMessage.for(DhLottery::AuthenticationError.new("실패"))
    assert_equal I18n.t("lottery.errors.insufficient_deposit"),
      Lottery::ErrorMessage.for(DhLottery::InsufficientDepositError.new("부족"))
    assert_equal I18n.t("lottery.errors.transport_failed"),
      Lottery::ErrorMessage.for(DhLottery::TimeoutError.new("시간 초과"))
  end

  test "분류되지 않은 예외는 기본 안내를 쓴다" do
    assert_equal I18n.t("lottery.errors.unknown"), Lottery::ErrorMessage.for(DhLottery::SessionExpiredError.new("만료"))
  end
end
