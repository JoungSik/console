class CreateLegalAgreements < ActiveRecord::Migration[8.1]
  def change
    create_table :legal_agreements do |t|
      t.references :user, null: false, foreign_key: true
      t.references :legal_document, null: false, foreign_key: true
      t.datetime :accepted_at, null: false

      t.timestamps
    end

    add_index :legal_agreements, [ :user_id, :legal_document_id ], unique: true
  end
end
