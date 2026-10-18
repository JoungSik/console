module Lottery
  class Engine < ::Rails::Engine
    isolate_namespace Lottery

    initializer "lottery.register_plugin", after: :load_config_initializers do
      ::PluginRegistry.register(
        name: :lotteries,
        label: "동행복권",
        icon: "ticket",
        path: "/lotteries",
        position: 60,
        dashboard_component: "Lottery::DashboardComponent",
        data_cleaner: "Lottery::DataCleaner",
        restricted: true
      )
    end
  end
end
