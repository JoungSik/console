class CreateCollections < ActiveRecord::Migration[8.0]
  def change
    create_table :collections, comment: '링크 모음집' do |t|
      t.string :title, null: false, limit: 100
      t.text :description
      t.boolean :is_public, default: false, null: false
      t.integer :links_count, default: 0, null: false, comment: '포함된 링크 수'
      t.references :user, null: false, foreign_key: true, comment: '링크 모음 생성자'

      t.timestamps
    end
  end
end
