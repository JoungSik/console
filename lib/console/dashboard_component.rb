# 대시보드 위젯 베이스 클래스
# 각 플러그인은 이 클래스를 상속하여 홈 대시보드에 위젯을 제공한다.
module Console
  class DashboardComponent
    attr_reader :user_id

    def initialize(user_id:)
      @user_id = user_id
    end

    # 플러그인 이름 (네비게이션 표시용)
    def plugin_name = raise NotImplementedError

    # 데이터 로딩 (self 반환)
    def load_data = raise NotImplementedError

    # 위젯 partial 경로
    def partial_path = raise NotImplementedError

    # partial에 전달할 locals
    def locals
      { component: self }
    end
  end
end
