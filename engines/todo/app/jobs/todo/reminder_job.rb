# 마감일 당일 및 기한 초과 할 일에 대해 푸시 알림 발송
module Todo
  class ReminderJob < ApplicationJob
    queue_as :default

    def perform
      send_due_today_reminders
      send_overdue_reminders
    end

    private

    # 오늘 마감인 미완료 항목 알림 발송
    def send_due_today_reminders
      items_scope = Item.incomplete.where(due_date: Date.current, reminder_sent: false)
      send_reminders_for(items_scope, type: :due_today)
    end

    # 기한 초과된 미완료 항목 알림 발송
    def send_overdue_reminders
      send_reminders_for(Item.reminder_pending, type: :overdue)
    end

    def send_reminders_for(items_scope, type:)
      items_by_user_id = items_scope.includes(:list).group_by { |item| item.list.user_id }
      users = User.where(id: items_by_user_id.keys).index_by(&:id)

      items_by_user_id.each do |user_id, items|
        user = users[user_id]
        next unless user

        title, body = build_message(items, type: type)
        sent = user.send_push_notification(
          title: title,
          body: body,
          url: "/todos",
          plugin_name: "todos",
          item_key: "due_date_reminder"
        )

        Item.where(id: items.map(&:id)).update_all(reminder_sent: true) if sent
      end
    end

    def build_message(items, type:)
      if type == :due_today
        title = "오늘 마감"
        plural_body = "오늘 마감인 할 일이 #{items.size}개 있습니다"
      else
        title = "기한 초과"
        plural_body = "기한이 초과된 할 일이 #{items.size}개 있습니다"
      end

      if items.size == 1
        [title, items.first.title]
      else
        [title, plural_body]
      end
    end
  end
end
