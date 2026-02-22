# Todo 대시보드 위젯 컴포넌트
module Todo
  class DashboardComponent < Console::DashboardComponent
    attr_reader :lists_count, :incomplete_count, :overdue_count, :recent_items

    def plugin_name = "할 일 목록"

    def load_data
      lists = Todo::List.by_user(user_id).active
      incomplete_items = Todo::Item.where(list: lists).incomplete.order(created_at: :desc).to_a

      @lists_count = lists.count
      @incomplete_count = incomplete_items.size
      @overdue_count = incomplete_items.count(&:overdue?)
      @recent_items = incomplete_items.take(5)
      self
    end

    def partial_path = "todo/dashboard/widget"
  end
end
