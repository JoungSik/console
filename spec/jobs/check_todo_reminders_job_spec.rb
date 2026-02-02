require 'rails_helper'

RSpec.describe CheckTodoRemindersJob, type: :job do
  include_context 'with user and todo list'

  describe '#perform' do
    it '마감일이 지났거나 오늘인 Todo에 리마인더를 전송한다' do
      todo = Todo.create!(
        title: '마감 Todo',
        todo_list: todo_list,
        due_date: Date.current,
        completed: false,
        reminder_sent: false
      )

      allow_any_instance_of(User).to receive(:send_push_notification).and_return(true)

      expect { described_class.perform_now }.to change { todo.reload.reminder_sent }.from(false).to(true)
    end

    it '알림 전송 실패 시 에러를 로깅하고 계속 진행한다' do
      todo = Todo.create!(
        title: '마감 Todo',
        todo_list: todo_list,
        due_date: Date.current,
        completed: false,
        reminder_sent: false
      )

      allow_any_instance_of(Todo).to receive(:send_reminder!).and_raise(StandardError, '테스트 에러')

      expect(Rails.logger).to receive(:error).with(/Failed to send reminder for Todo ##{todo.id}/)

      expect { described_class.perform_now }.not_to raise_error
    end

    it '대상이 없으면 아무 작업도 하지 않는다' do
      Todo.create!(
        title: '미래 마감',
        todo_list: todo_list,
        due_date: Date.current + 1.day,
        completed: false,
        reminder_sent: false
      )

      expect_any_instance_of(Todo).not_to receive(:send_reminder!)

      described_class.perform_now
    end
  end
end
