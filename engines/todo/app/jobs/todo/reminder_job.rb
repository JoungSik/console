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
      due_today_items = Item.joins(:list)
        .incomplete
        .where(due_date: Date.current, reminder_sent: false)

      due_today_items.group_by { |item| item.list.user_id }.each do |user_id, items|
        user = User.find_by(id: user_id)
        next unless user

        title, body = build_message(items, type: :due_today)
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

    # 기한 초과된 미완료 항목 알림 발송
    def send_overdue_reminders
      overdue_items = Item.reminder_pending.joins(:list)

      overdue_items.group_by { |item| item.list.user_id }.each do |user_id, items|
        user = User.find_by(id: user_id)
        next unless user

        title, body = build_message(items, type: :overdue)
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
        if items.size == 1
          [ "오늘 마감", items.first.title ]
        else
          [ "오늘 마감", "오늘 마감인 할 일이 #{items.size}개 있습니다" ]
        end
      else
        if items.size == 1
          [ "기한 초과", items.first.title ]
        else
          [ "기한 초과", "기한이 초과된 할 일이 #{items.size}개 있습니다" ]
        end
      end
    end
  end
end
