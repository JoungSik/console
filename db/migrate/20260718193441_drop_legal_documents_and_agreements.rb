class DropLegalDocumentsAndAgreements < ActiveRecord::Migration[8.1]
  def up
    drop_table :legal_agreements, if_exists: true
    drop_table :legal_documents, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
