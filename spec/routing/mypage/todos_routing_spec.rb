require "rails_helper"

RSpec.describe Mypage::TodosController, type: :routing do
  describe "routing" do
    it "routes to #update via PUT" do
      expect(put: "/mypage/todo_lists/1/todos/1").to route_to("mypage/todos#update", todo_list_id: "1", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/mypage/todo_lists/1/todos/1").to route_to("mypage/todos#update", todo_list_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/mypage/todo_lists/1/todos/1").to route_to("mypage/todos#destroy", todo_list_id: "1", id: "1")
    end
  end
end
