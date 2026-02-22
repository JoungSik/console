# Bookmark 대시보드 위젯 컴포넌트
module Bookmark
  class DashboardComponent < Console::DashboardComponent
    attr_reader :groups_count, :links_count, :recent_groups

    def plugin_name = "북마크"

    def load_data
      groups = Bookmark::Group.by_user(user_id)

      @groups_count = groups.count
      @links_count = groups.sum(:links_count)
      @recent_groups = groups.order(created_at: :desc).limit(3)
      self
    end

    def partial_path = "bookmark/dashboard/widget"
  end
end
