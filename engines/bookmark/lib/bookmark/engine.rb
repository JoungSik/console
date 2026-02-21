module Bookmark
  class Engine < ::Rails::Engine
    isolate_namespace Bookmark

    initializer "bookmark.register_plugin", after: :load_config_initializers do
      ::PluginRegistry.register(
        name: :bookmarks,
        label: "북마크",
        icon: "bookmark",
        path: "/bookmarks",
        position: 20
      )
    end

    initializer "bookmark.append_migrations" do |app|
      unless app.root.to_s.match?(root.to_s)
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
