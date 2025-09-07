require 'rails_helper'

RSpec.describe "mypage/collections/edit", type: :view do
  let(:mypage_collection) {
    Mypage::Collection.create!()
  }

  before(:each) do
    assign(:mypage_collection, mypage_collection)
  end

  it "renders the edit mypage_collection form" do
    render

    assert_select "form[action=?][method=?]", mypage_collection_path(mypage_collection), "post" do
    end
  end
end
