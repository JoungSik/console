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
        dashboard_component: "Todo::DashboardComponent",
        push_notification_items: [
          { key: "due_date_reminder", label: "마감일 리마인더", description: "매일 오전 9시에 오늘 마감 및 기한 초과 할 일 알림을 보냅니다." }
        ]
      )
    end
  end
end
