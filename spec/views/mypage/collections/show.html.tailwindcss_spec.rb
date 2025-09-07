require 'rails_helper'

RSpec.describe "mypage/collections/show", type: :view do
  before(:each) do
    assign(:mypage_collection, Mypage::Collection.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
