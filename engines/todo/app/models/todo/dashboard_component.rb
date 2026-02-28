# Todo 대시보드 위젯 컴포넌트
module Todo
  class DashboardComponent < Console::DashboardComponent
    attr_reader :incomplete_count, :overdue_count, :today_items

    def plugin_name = "할 일 목록"

    def load_data
      lists = Todo::List.by_user(user_id).active
      items = Todo::Item.where(list: lists)

      @incomplete_count = items.incomplete.count
      @overdue_count = items.overdue.count
      @today_items = items.incomplete
        .where("due_date <= ?", Date.current)
        .order(due_date: :asc)
        .load
      self
    end

    def partial_path = "todo/dashboard/widget"
  end
end
