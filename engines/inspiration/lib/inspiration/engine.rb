module Inspiration
  class Engine < ::Rails::Engine
    isolate_namespace Inspiration

    initializer "inspiration.register_plugin", after: :load_config_initializers do
      ::PluginRegistry.register(
        name: :inspirations,
        label: "아이디어 꾸러미",
        icon: "lightbulb",
        path: "/inspirations",
        position: 50,
        dashboard_component: "Inspiration::DashboardComponent",
        data_cleaner: "Inspiration::DataCleaner"
      )
    end
  end
end
