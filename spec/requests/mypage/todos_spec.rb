require 'rails_helper'

RSpec.describe "/mypage/todo_lists/:todo_list_id/todos", type: :request do
  let(:user) { User.create!(name: 'Test User', email_address: 'test@example.com', password: 'password') }
  let(:todo_list) { TodoList.create!(title: 'Test Todo List', user: user) }

  before do
    # Create a session for the user and set it in Current
    @session = user.sessions.create!(user_agent: 'test', ip_address: '127.0.0.1')
    allow(Current).to receive(:session).and_return(@session)
  end

  let(:valid_attributes) {
    {
      title: 'Test Todo',
      todo_list: todo_list
    }
  }

  let(:invalid_attributes) {
    {
      title: '',
      todo_list: nil
    }
  }

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { completed: true }
      }

      it "updates the requested todo" do
        todo = Todo.create! valid_attributes
        patch mypage_todo_list_todo_url(todo_list, todo), params: { todo: new_attributes }
        todo.reload
        expect(todo.completed).to be true
      end

      it "redirects to the todo_list" do
        todo = Todo.create! valid_attributes
        patch mypage_todo_list_todo_url(todo_list, todo), params: { todo: new_attributes }
        expect(response).to redirect_to(mypage_todo_list_url(todo_list))
      end
    end

    context "with invalid parameters" do
      it "redirects to the todo_list" do
        todo = Todo.create! valid_attributes
        patch mypage_todo_list_todo_url(todo_list, todo), params: { todo: { title: '' } }
        expect(response).to redirect_to(mypage_todo_list_url(todo_list))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested todo" do
      todo = Todo.create! valid_attributes
      expect {
        delete mypage_todo_list_todo_url(todo_list, todo)
      }.to change(Todo, :count).by(-1)
    end

    it "redirects to the todo_list" do
      todo = Todo.create! valid_attributes
      delete mypage_todo_list_todo_url(todo_list, todo)
      expect(response).to redirect_to(mypage_todo_list_url(todo_list))
    end
  end
end
