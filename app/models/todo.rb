class Todo < ApplicationRecord
  belongs_to :todo_list

  validates :title, presence: true, length: { maximum: 200 }

  scope :not_completed, -> { where(completed: false) }

  # due_date가 오늘이거나 지난 미완료 작업 (비아카이브 TodoList만)
  scope :overdue_pending_reminder, -> {
    joins(:todo_list)
      .where(reminder_sent: false, completed: false)
      .where("due_date <= ?", Date.current)
      .where(todo_lists: { archived_at: nil })
  }

  # 리마인더 전송 (알림 전송 성공 시에만 reminder_sent 업데이트)
  def send_reminder!
    return if reminder_sent? || due_date.blank?
    return if completed?

    user = todo_list.user
    if user.send_push_notification(
      title: "Todo 리마인더",
      body: title,
      url: "/mypage/todo_lists/#{todo_list_id}"
    )
      update!(reminder_sent: true)
    end
  end
end
