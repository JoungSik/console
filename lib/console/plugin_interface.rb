# 플러그인이 코어 앱에 접근하기 위한 인터페이스
# 플러그인 컨트롤러에서 include하여 사용한다.
# User 모델을 직접 참조하지 않고 이 인터페이스를 통해서만 접근한다.
module Console
  module PluginInterface
    extend ActiveSupport::Concern

    included do
      helper_method :current_user_id, :current_user_name, :current_user_email
    end

    private

    def current_user_id
      current_user&.id
    end

    def current_user_name
      current_user&.name
    end

    def current_user_email
      current_user&.email_address
    end
  end
end
