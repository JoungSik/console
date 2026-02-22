# 코어 + 플러그인 시드 데이터
# bin/rails db:seed 로 실행

# === 코어: 사용자 ===
user = User.find_or_create_by!(email_address: "test@test.com") do |u|
  u.name = "test"
  u.password = "qwer1234"
end
puts "User: #{user.email_address}"

# === Todo 엔진 ===
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

# === Bookmark 엔진 ===
group1 = Bookmark::Group.find_or_create_by!(title: "포털 사이트", user_id: user.id) do |g|
  g.description = "각종 포털 사이트 목록"
  g.is_public = true
end
[
  { title: "Google", url: "https://www.google.com", description: "구글 검색" },
  { title: "Naver", url: "https://www.naver.com", description: "네이버" },
  { title: "Daum", url: "https://www.daum.net", description: "다음" }
].each do |attrs|
  group1.links.find_or_create_by!(title: attrs[:title]) do |link|
    link.url = attrs[:url]
    link.description = attrs[:description]
  end
end

group2 = Bookmark::Group.find_or_create_by!(title: "업무 사이트", user_id: user.id) do |g|
  g.description = "각종 업무에 필요한 사이트 목록"
  g.is_public = false
end
[
  { title: "Google Analytics", url: "https://analytics.google.com/analytics", description: "GA" },
  { title: "Google Search Console", url: "https://search.google.com/search-console", description: "GSC" },
  { title: "Naver Search Advisor", url: "https://searchadvisor.naver.com/", description: "NSA" }
].each do |attrs|
  group2.links.find_or_create_by!(title: attrs[:title]) do |link|
    link.url = attrs[:url]
    link.description = attrs[:description]
  end
end

puts "Bookmark: #{Bookmark::Group.count} groups, #{Bookmark::Link.count} links"

# === Settlement 엔진 ===
gathering1 = Settlement::Gathering.find_or_create_by!(title: "팀 회식", user_id: user.id) do |g|
  g.gathering_date = Date.current - 3.days
  g.memo = "강남역 근처 고기집"
end

members1 = %w[김철수 이영희 박민수 정수진].map do |name|
  gathering1.members.find_or_create_by!(name: name)
end

round1 = gathering1.rounds.find_or_create_by!(name: "1차 고기집") do |r|
  r.position = 0
end
[
  { name: "삼겹살 2인분", quantity: 2, amount: 18000 },
  { name: "목살 2인분", quantity: 2, amount: 17000 },
  { name: "소주", quantity: 3, amount: 5000 },
  { name: "음료", quantity: 2, amount: 3000 }
].each do |attrs|
  round1.items.find_or_create_by!(name: attrs[:name]) do |item|
    item.quantity = attrs[:quantity]
    item.amount = attrs[:amount]
  end
end

round2 = gathering1.rounds.find_or_create_by!(name: "2차 카페") do |r|
  r.position = 1
end
[
  { name: "아메리카노", quantity: 3, amount: 4500 },
  { name: "카페라떼", quantity: 1, amount: 5000 }
].each do |attrs|
  round2.items.find_or_create_by!(name: attrs[:name]) do |item|
    item.quantity = attrs[:quantity]
    item.amount = attrs[:amount]
  end
end

gathering2 = Settlement::Gathering.find_or_create_by!(title: "주말 여행", user_id: user.id) do |g|
  g.gathering_date = Date.current - 10.days
  g.memo = "속초 1박 2일"
end

members2 = %w[김철수 이영희 최준호].map do |name|
  gathering2.members.find_or_create_by!(name: name)
end

travel_round = gathering2.rounds.find_or_create_by!(name: "숙소 및 식비") do |r|
  r.position = 0
end
[
  { name: "펜션 1박", quantity: 1, amount: 150000, is_shared: true },
  { name: "횟집 저녁", quantity: 1, amount: 90000, is_shared: true },
  { name: "아침 식사", quantity: 1, amount: 30000, is_shared: true }
].each do |attrs|
  travel_round.items.find_or_create_by!(name: attrs[:name]) do |item|
    item.quantity = attrs[:quantity]
    item.amount = attrs[:amount]
    item.is_shared = attrs[:is_shared] || false
  end
end

puts "Settlement: #{Settlement::Gathering.count} gatherings, #{Settlement::Member.count} members"

puts "Seed 완료!"
