module Bookmark
  class Engine < ::Rails::Engine
    isolate_namespace Bookmark

    initializer "bookmark.hashids" do
      settings = {
        development: { salt: "dev-bookmark-salt", min_length: 6, alphabet: "abcdefghijklmnopqrstuvwxyz0123456789" },
        test: { salt: "test-bookmark-salt", min_length: 6, alphabet: "abcdefghijklmnopqrstuvwxyz0123456789" },
        production: {
          salt: Rails.application.credentials.dig(:bookmark, :hashids_salt) || ENV["BOOKMARK_HASHIDS_SALT"] || "bookmark-fallback-salt",
          min_length: 8,
          alphabet: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
      }
      config = settings[Rails.env.to_sym] || settings[:production]
      Bookmark.hashids_encoder = Hashids.new(config[:salt], config[:min_length], config[:alphabet])
    end

    initializer "bookmark.register_plugin", after: :load_config_initializers do
      ::PluginRegistry.register(
        name: :bookmarks,
        label: "북마크",
        icon: "bookmark",
        path: "/bookmarks",
        position: 20
      )
    end
  end
end
