module Settlement
  class Engine < ::Rails::Engine
    isolate_namespace Settlement

    initializer "settlement.register_plugin", after: :load_config_initializers do
      ::PluginRegistry.register(
        name: :settlements,
        label: "정산",
        icon: "receipt",
        path: "/settlements",
        position: 30
      )
    end
  end
end
