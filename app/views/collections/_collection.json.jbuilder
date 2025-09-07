json.extract! collection, :id, :title, :description, :is_public, :created_at, :updated_at
json.url collection_url(collection, format: :json)
json.links_count collection.links.count
