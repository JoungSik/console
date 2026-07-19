module Journal
  class Engine < ::Rails::Engine
    isolate_namespace Journal

    initializer "journal.register_plugin", after: :load_config_initializers do
      ::PluginRegistry.register(
        name: :posts,
        label: "포스트",
        icon: "message-square",
        path: "/posts",
        position: 40,
        data_cleaner: "Journal::DataCleaner"
      )
    end
  end
end
