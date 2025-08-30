class CreateLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :links, comment: '링크' do |t|
      t.string :title, null: false, limit: 100
      t.text :url, null: false, comment: '링크 URL'
      t.text :description
      t.references :collection, null: false, foreign_key: true, comment: '링크 모음'
      t.references :user, null: false, foreign_key: true, comment: '링크 생성자'

      t.string :favicon_url, comment: '사이트 파비콘 URL'

      t.timestamps
    end
  end
end
