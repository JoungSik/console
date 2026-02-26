class AddEmailVerifiedAtToUsers < ActiveRecord::Migration[8.1]
  # 마이그레이션 안정성을 위해 임시 모델 정의
  class MigrationUser < ApplicationRecord
    self.table_name = :users
  end

  def change
    add_column :users, :email_verified_at, :datetime

    # 기존 사용자는 이메일 인증 완료 상태로 설정
    reversible do |dir|
      dir.up do
        MigrationUser.where(email_verified_at: nil).update_all(email_verified_at: Time.current)
      end
    end
  end
end
