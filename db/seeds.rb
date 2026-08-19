user = User.find_or_initialize_by(email_address: "test@test.com")
if user.new_record?
  user.name = "test"
  user.password = "qwer1234"
  user.email_verified_at = Time.current
end
user.admin = true
user.save!
puts "User: #{user.email_address}"

list1 = Todo::List.find_or_create_by!(title: "오늘 할 일", user_id: user.id)
[
  { title: "장보기", completed: false, due_date: Date.current, url: "https://www.coupang.com" },
  { title: "운동하기", completed: false, due_date: Date.current, url: "https://www.youtube.com/watch?v=example" },
  { title: "독서 30분", completed: true }
].each do |attrs|
  list1.items.find_or_create_by!(title: attrs[:title]) do |item|
    item.completed = attrs[:completed]
    item.due_date = attrs[:due_date]
    item.url = attrs[:url]
  end
end

list2 = Todo::List.find_or_create_by!(title: "이번 주 목표", user_id: user.id)
[
  { title: "프로젝트 마일스톤 완료", completed: false, due_date: Date.current.end_of_week, url: "https://github.com" },
  { title: "코드 리뷰 3건", completed: true },
  { title: "기술 블로그 글 작성", completed: false, url: "https://velog.io" }
].each do |attrs|
  list2.items.find_or_create_by!(title: attrs[:title]) do |item|
    item.completed = attrs[:completed]
    item.due_date = attrs[:due_date]
    item.url = attrs[:url]
  end
end

list3 = Todo::List.find_or_create_by!(title: "완료된 목록", user_id: user.id) do |l|
  l.archived_at = Time.current
end
list3.items.find_or_create_by!(title: "환경 설정 완료") { |i| i.completed = true }

puts "Todo: #{Todo::List.count} lists, #{Todo::Item.count} items"

[
  "오늘은 Console에 포스트 모듈을 추가했다. 짧은 기록을 남기기 좋다.",
  "새 기능은 작게 시작하고, 검증 가능한 단위로 확장하는 편이 유지보수에 좋다.",
  "개인 대시보드에 하루의 생각을 남길 수 있으니 작업 흐름이 더 자연스러워졌다."
].each do |body|
  Journal::Post.find_or_create_by!(body: body, user_id: user.id)
end

puts "Journal: #{Journal::Post.count} posts"

if Rails.env.development?
  [
    {
      title: "Console 공지사항 기능 안내",
      published_on: Date.new(2020, 1, 1),
      expires_on: nil,
      position: 10,
      body: <<~HTML
        <p><strong>Console 공지사항 기능을 확인해 보세요.</strong></p>
        <p>공지 본문에는 <a href="https://lexxy.dev/">링크와 다양한 서식</a>을 사용할 수 있습니다.</p>
      HTML
    },
    {
      title: "개발 환경 점검 안내",
      published_on: Date.new(2020, 1, 1),
      expires_on: Date.new(2099, 12, 31),
      position: 20,
      body: <<~HTML
        <p><strong>개발 환경 점검 안내</strong></p>
        <ul>
          <li>라이트 모드와 다크 모드의 콘텐츠 스타일을 확인하세요.</li>
          <li>여러 공지가 노출 순서대로 표시되는지 확인하세요.</li>
        </ul>
      HTML
    }
  ].each do |attributes|
    body = attributes.delete(:body)
    notice = Notice.find_or_initialize_by(attributes.except(:title))
    notice.title = attributes[:title]
    notice.body = body
    notice.save!
  end

  puts "Notice: #{Notice.count} notices"
end

puts "Seed 완료!"
