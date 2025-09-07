require 'rails_helper'

RSpec.describe "mypage/collections/new", type: :view do
  before(:each) do
    assign(:mypage_collection, Mypage::Collection.new())
  end

  it "renders new mypage_collection form" do
    render

    assert_select "form[action=?][method=?]", mypage_collections_path, "post" do
    end
  end
end
