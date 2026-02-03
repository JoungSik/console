require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe '.overdue_pending_reminder' do
    include_context 'with user and todo list'

    let(:active_list) { todo_list }
    let(:archived_list) { TodoList.create!(title: '아카이브 리스트', user: user, archived_at: Time.current) }

    it '마감일이 오늘인 미완료 Todo를 포함한다' do
      todo = Todo.create!(
        title: '오늘 마감',
        todo_list: active_list,
        due_date: Date.current,
        completed: false,
        reminder_sent: false
      )

      expect(Todo.overdue_pending_reminder).to include(todo)
    end

    it '마감일이 지난 미완료 Todo를 포함한다' do
      todo = Todo.create!(
        title: '어제 마감',
        todo_list: active_list,
        due_date: Date.current - 1.day,
        completed: false,
        reminder_sent: false
      )

      expect(Todo.overdue_pending_reminder).to include(todo)
    end

    it '마감일이 미래인 Todo를 제외한다' do
      todo = Todo.create!(
        title: '내일 마감',
        todo_list: active_list,
        due_date: Date.current + 1.day,
        completed: false,
        reminder_sent: false
      )

      expect(Todo.overdue_pending_reminder).not_to include(todo)
    end

    it '이미 리마인더를 보낸 Todo를 제외한다' do
      todo = Todo.create!(
        title: '리마인더 발송됨',
        todo_list: active_list,
        due_date: Date.current,
        completed: false,
        reminder_sent: true
      )

      expect(Todo.overdue_pending_reminder).not_to include(todo)
    end

    it '완료된 Todo를 제외한다' do
      todo = Todo.create!(
        title: '완료됨',
        todo_list: active_list,
        due_date: Date.current,
        completed: true,
        reminder_sent: false
      )

      expect(Todo.overdue_pending_reminder).not_to include(todo)
    end

    it '아카이브된 TodoList의 Todo를 제외한다' do
      todo = Todo.create!(
        title: '아카이브된 리스트',
        todo_list: archived_list,
        due_date: Date.current,
        completed: false,
        reminder_sent: false
      )

      expect(Todo.overdue_pending_reminder).not_to include(todo)
    end

    it 'due_date가 없는 Todo를 제외한다' do
      todo = Todo.create!(
        title: '마감일 없음',
        todo_list: active_list,
        due_date: nil,
        completed: false,
        reminder_sent: false
      )

      expect(Todo.overdue_pending_reminder).not_to include(todo)
    end
  end
end
