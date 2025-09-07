require 'rails_helper'

RSpec.describe "mypage/collections/index", type: :view do
  before(:each) do
    assign(:mypage_collections, [
      Mypage::Collection.create!(),
      Mypage::Collection.create!()
    ])
  end

  it "renders a list of mypage/collections" do
    render
    cell_selector = 'div>p'
  end
end
