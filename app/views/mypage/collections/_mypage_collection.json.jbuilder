json.extract! mypage_collection, :id, :created_at, :updated_at
json.url mypage_collection_url(mypage_collection, format: :json)
