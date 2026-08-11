class CreatePushRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :push_registrations, comment: "로그인 세션별 FCM 푸시 등록" do |t|
      t.references :user, null: false, foreign_key: true, comment: "푸시 알림을 수신할 사용자"
      t.references :session, null: false, foreign_key: true, comment: "FID를 등록한 로그인 세션"
      t.text :firebase_installation_id, null: false, comment: "FCM이 브라우저 또는 Native 앱 설치를 푸시 대상으로 구분하는 식별자(FID)"
      t.string :platform, null: false, comment: "클라이언트 플랫폼(web, android, ios)"
      t.datetime :last_registered_at, null: false, comment: "FID를 마지막으로 등록하거나 동기화한 시각"

      t.timestamps
    end

    add_index :push_registrations, :firebase_installation_id, unique: true
    add_index :push_registrations, %i[session_id platform], unique: true
  end
end
