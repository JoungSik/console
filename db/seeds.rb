# 코어 + 플러그인 시드 데이터
# bin/rails db:seed 로 실행

# === 코어: 법적 문서 ===
terms_content = File.read(Rails.root.join("docs/legal/terms/2025-02-25.md"))
terms_doc = LegalDocument.find_or_create_by!(document_type: :terms, version: "2025-02-25") do |d|
  d.title = "이용약관"
  d.content = terms_content
  d.published_at = Time.zone.parse("2025-02-25")
end

privacy_content = File.read(Rails.root.join("docs/legal/privacy/2025-02-25.md"))
privacy_doc = LegalDocument.find_or_create_by!(document_type: :privacy_policy, version: "2025-02-25") do |d|
  d.title = "개인정보처리방침"
  d.content = privacy_content
  d.published_at = Time.zone.parse("2025-02-25")
end

puts "LegalDocument: #{LegalDocument.count} documents"

# === 코어: 사용자 ===
user = User.find_or_create_by!(email_address: "test@test.com") do |u|
  u.name = "test"
  u.password = "qwer1234"
  u.email_verified_at = Time.current
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

# 기존 데이터 초기화
Settlement::Gathering.where(user_id: user.id).destroy_all

# --- 팀 회식 ---
gathering1 = Settlement::Gathering.create!(title: "팀 회식", user_id: user.id, gathering_date: Date.current - 3.days, memo: "강남역 근처 고기집")
g1_철수 = gathering1.members.create!(name: "김철수")
g1_영희 = gathering1.members.create!(name: "이영희")
g1_민수 = gathering1.members.create!(name: "박민수")
g1_수진 = gathering1.members.create!(name: "정수진")

# 1차 고기집: 고기는 공통, 음료는 개인
round1 = gathering1.rounds.create!(name: "1차 고기집", position: 0)
round1.items.create!(name: "삼겹살 2인분", quantity: 2, amount: 18000, is_shared: true)
round1.items.create!(name: "목살 2인분", quantity: 2, amount: 17000, is_shared: true)

sozu = round1.items.create!(name: "소주", quantity: 3, amount: 5000)
sozu.item_members.create!(member: g1_철수)
sozu.item_members.create!(member: g1_민수)
sozu.item_members.create!(member: g1_수진)

drink = round1.items.create!(name: "음료", quantity: 2, amount: 3000)
drink.item_members.create!(member: g1_영희)

# 2차 카페: 각자 주문
round2 = gathering1.rounds.create!(name: "2차 카페", position: 1)

americano = round2.items.create!(name: "아메리카노", quantity: 3, amount: 4500)
americano.item_members.create!(member: g1_철수)
americano.item_members.create!(member: g1_영희)
americano.item_members.create!(member: g1_민수)

latte = round2.items.create!(name: "카페라떼", quantity: 1, amount: 5000)
latte.item_members.create!(member: g1_수진)

# --- 주말 여행 ---
gathering2 = Settlement::Gathering.create!(title: "주말 여행", user_id: user.id, gathering_date: Date.current - 10.days, memo: "속초 1박 2일")
g2_철수 = gathering2.members.create!(name: "김철수")
g2_영희 = gathering2.members.create!(name: "이영희")
g2_준호 = gathering2.members.create!(name: "최준호")

# 숙소/식비: 모두 공통
travel_round = gathering2.rounds.create!(name: "숙소 및 식비", position: 0)
travel_round.items.create!(name: "펜션 1박", quantity: 1, amount: 150000, is_shared: true)
travel_round.items.create!(name: "횟집 저녁", quantity: 1, amount: 90000, is_shared: true)
travel_round.items.create!(name: "아침 식사", quantity: 1, amount: 30000, is_shared: true)

# --- 점심 회식 (나머지 분배 테스트) ---
gathering3 = Settlement::Gathering.create!(title: "점심 회식", user_id: user.id, gathering_date: Date.current - 1.day, memo: "나머지 분배 테스트")
g3_a = gathering3.members.create!(name: "유정현")
g3_b = gathering3.members.create!(name: "김라리네")
g3_c = gathering3.members.create!(name: "김정식")

lunch_round = gathering3.rounds.create!(name: "점심", position: 0)

noodle = lunch_round.items.create!(name: "삼산냉면", quantity: 1, amount: 12000)
noodle.item_members.create!(member: g3_a)

udon = lunch_round.items.create!(name: "삼산우동", quantity: 1, amount: 12000)
udon.item_members.create!(member: g3_b)

bibim = lunch_round.items.create!(name: "수제비빔밥", quantity: 1, amount: 12000)
bibim.item_members.create!(member: g3_c)

# 탕수육 25,000 ÷ 3 → 8,330 × 3 = 24,990, 나머지 10
lunch_round.items.create!(name: "탕수육 소", quantity: 1, amount: 25000, is_shared: true)
# 콜라 2,000 ÷ 3 → 660 × 3 = 1,980, 나머지 20
lunch_round.items.create!(name: "콜라", quantity: 1, amount: 2000, is_shared: true)

puts "Settlement: #{Settlement::Gathering.count} gatherings, #{Settlement::Member.count} members"

puts "Seed 완료!"
