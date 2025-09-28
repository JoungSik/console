require "rails_helper"

RSpec.describe Mypage::TodoListsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/mypage/todo_lists").to route_to("mypage/todo_lists#index")
    end

    it "routes to #new" do
      expect(get: "/mypage/todo_lists/new").to route_to("mypage/todo_lists#new")
    end

    it "routes to #show" do
      expect(get: "/mypage/todo_lists/1").to route_to("mypage/todo_lists#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/mypage/todo_lists/1/edit").to route_to("mypage/todo_lists#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/mypage/todo_lists").to route_to("mypage/todo_lists#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/mypage/todo_lists/1").to route_to("mypage/todo_lists#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/mypage/todo_lists/1").to route_to("mypage/todo_lists#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/mypage/todo_lists/1").to route_to("mypage/todo_lists#destroy", id: "1")
    end
  end
end
