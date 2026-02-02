# 매일 오전 9시에 실행되어 due_date가 오늘이거나 지난 미완료 Todo에 리마인더 발송
class CheckTodoRemindersJob < ApplicationJob
  queue_as :default

  def perform
    Todo.overdue_pending_reminder.find_each do |todo|
      todo.send_reminder!
    rescue StandardError => e
      Rails.logger.error("Failed to send reminder for Todo ##{todo.id}: #{e.message}")
    end
  end
end
