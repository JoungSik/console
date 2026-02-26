class AddEmailVerifiedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_verified_at, :datetime

    # 기존 사용자는 이메일 인증 완료 상태로 설정
    reversible do |dir|
      dir.up do
        User.where(email_verified_at: nil).update_all(email_verified_at: Time.current)
      end
    end
  end
end
