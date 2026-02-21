module Todo
  class Engine < ::Rails::Engine
    isolate_namespace Todo

    initializer "todo.register_plugin", after: :load_config_initializers do
      ::PluginRegistry.register(
        name: :todos,
        label: "할 일 목록",
        icon: "layout-list",
        path: "/todos",
        position: 10
      )
    end

    initializer "todo.append_migrations" do |app|
      unless app.root.to_s.match?(root.to_s)
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
