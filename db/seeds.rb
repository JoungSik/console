# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.create_or_find_by(name: "test", email_address: "test@test.com", password: "qwer1234")

# Public
public_collection = Collection.create_or_find_by(title: "포털 사이트",
                                                 description: "각종 포털 사이트 목록",
                                                 is_public: true, user: user)

public_links = [
  { title: "Google", url: "https://www.google.com", description: "Google" },
  { title: "Naver", url: "https://www.naver.com", description: "Naver" },
  { title: "Daum", url: "https://www.daum.net", description: "Daum" }
]

public_links.each { Link.create_or_find_by!(it.merge(collection: public_collection, user: user)) }

# Private
private_collection = Collection.create_or_find_by(title: "업무 사이트",
                                                  description: "각종 업무에 필요한 사이트 목록",
                                                  is_public: false, user: user)

private_links = [
  { title: "GA", url: "https://analytics.google.com/analytics", description: "Google Analytics" },
  { title: "Google Search Console", url: "https://search.google.com/search-console", description: "Google Search Console" },
  { title: "Naver Search Advisor", url: "https://searchadvisor.naver.com/", description: "Naver Search Advisor" }
]

private_links.each { Link.create_or_find_by!(it.merge(collection: private_collection, user: user)) }
