# Settlement 대시보드 위젯 컴포넌트
module Settlement
  class DashboardComponent < Console::DashboardComponent
    attr_reader :gatherings_count, :recent_gatherings

    def plugin_name = "정산"

    def load_data
      gatherings = Settlement::Gathering.by_user(user_id)

      @gatherings_count = gatherings.count
      @recent_gatherings = gatherings.includes(:members).order(created_at: :desc).limit(3)
      self
    end

    def partial_path = "settlement/dashboard/widget"
  end
end
