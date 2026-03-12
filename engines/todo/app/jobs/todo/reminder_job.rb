# 마감일 당일 및 기한 초과 할 일에 대해 매일 통합 푸시 알림 발송
module Todo
  class ReminderJob < ApplicationJob
    queue_as :default

    def perform
      items = Item.incomplete.includes(:list).where("due_date <= ?", Date.current).to_a

      # 사용자별로 그룹핑하여 통합 알림 발송
      items_by_user = items.group_by { |i| i.list.user_id }
      users = User.where(id: items_by_user.keys).index_by(&:id)

      items_by_user.each do |user_id, items|
        user = users[user_id]
        next unless user

        today_count = items.count { |i| i.due_date == Date.current }
        overdue_count = items.count { |i| i.due_date < Date.current }

        body = build_body(today_count, overdue_count)
        user.send_push_notification(
          title: "할 일 리마인더",
          body: body,
          url: "/todos",
          plugin_name: "todos",
          item_key: "due_date_reminder"
        )
      end
    end

    private

    def build_body(due_today_count, overdue_count)
      if due_today_count > 0 && overdue_count > 0
        "오늘 마감 #{due_today_count}개, 기한 초과 #{overdue_count}개의 할 일이 있습니다"
      elsif due_today_count > 0
        "오늘 마감인 할 일이 #{due_today_count}개 있습니다"
      else
        "기한이 초과된 할 일이 #{overdue_count}개 있습니다"
      end
    end
  end
end
