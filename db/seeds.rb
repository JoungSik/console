user = User.find_or_create_by!(email_address: "test@test.com") do |u|
  u.name = "test"
  u.password = "qwer1234"
  u.email_verified_at = Time.current
end
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

puts "Seed 완료!"
