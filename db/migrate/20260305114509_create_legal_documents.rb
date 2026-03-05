class CreateLegalDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :legal_documents do |t|
      t.integer :document_type, null: false
      t.string :version, null: false
      t.string :title, null: false
      t.text :content, null: false
      t.datetime :published_at, null: false

      t.timestamps
    end

    add_index :legal_documents, [ :document_type, :version ], unique: true
    add_index :legal_documents, [ :document_type, :published_at ]
  end
end
