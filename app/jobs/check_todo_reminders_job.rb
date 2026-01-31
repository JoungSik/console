# 매일 오전 9시에 실행되어 due_date가 오늘인 Todo에 리마인더 발송
class CheckTodoRemindersJob < ApplicationJob
  queue_as :default

  def perform
    Todo.due_today_pending_reminder.find_each do |todo|
      todo.send_reminder!
    rescue StandardError => e
      Rails.logger.error("Failed to send reminder for Todo ##{todo.id}: #{e.message}")
    end
  end
end
