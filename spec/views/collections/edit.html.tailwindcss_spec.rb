require 'rails_helper'

RSpec.describe "collections/edit", type: :view do
  let(:collection) {
    Collection.create!()
  }

  before(:each) do
    assign(:collection, collection)
  end

  it "renders the edit collection form" do
    render

    assert_select "form[action=?][method=?]", collection_path(collection), "post" do
    end
  end
end
