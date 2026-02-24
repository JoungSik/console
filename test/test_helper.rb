ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Integration 테스트용 로그인 헬퍼
module IntegrationTestHelper
  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: "password123" }
    follow_redirect!
  end
end

module ActiveSupport
  class TestCase
    fixtures :all
    parallelize(workers: :number_of_processors)
  end
end

class ActionDispatch::IntegrationTest
  include IntegrationTestHelper

  # memory_store 사용 시 rate_limit 카운터가 테스트 간 누적되는 것을 방지
  teardown do
    Rails.cache.clear
  end
end
