require "rails_helper"

RSpec.describe Mypage::CollectionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/mypage/collections").to route_to("mypage/collections#index")
    end

    it "routes to #new" do
      expect(get: "/mypage/collections/new").to route_to("mypage/collections#new")
    end

    it "routes to #show" do
      expect(get: "/mypage/collections/1").to route_to("mypage/collections#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/mypage/collections/1/edit").to route_to("mypage/collections#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/mypage/collections").to route_to("mypage/collections#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/mypage/collections/1").to route_to("mypage/collections#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/mypage/collections/1").to route_to("mypage/collections#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/mypage/collections/1").to route_to("mypage/collections#destroy", id: "1")
    end
  end
end
