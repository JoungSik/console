module Todo
  class Engine < ::Rails::Engine
    isolate_namespace Todo

    initializer "todo.register_plugin", after: :load_config_initializers do
      ::PluginRegistry.register(
        name: :todos,
        label: "할 일 목록",
        icon: "layout-list",
        path: "/todos",
        position: 10,
        dashboard_component: "Todo::DashboardComponent"
      )
    end
  end
end
