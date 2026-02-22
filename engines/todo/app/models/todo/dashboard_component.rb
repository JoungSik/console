# Todo 대시보드 위젯 컴포넌트
module Todo
  class DashboardComponent < Console::DashboardComponent
    attr_reader :lists_count, :incomplete_count, :overdue_count, :recent_items

    def plugin_name = "할 일 목록"

    def load_data
      lists = Todo::List.by_user(user_id).active
      items = Todo::Item.where(list: lists)

      @lists_count = lists.count
      @incomplete_count = items.incomplete.count
      @overdue_count = items.overdue.count
      @recent_items = items.incomplete.order(created_at: :desc).limit(5)
      self
    end

    def partial_path = "todo/dashboard/widget"
  end
end
