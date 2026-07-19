class PluginRegistry
  NotificationItem = Data.define(:key, :label, :description)
  Plugin = Data.define(:name, :label, :icon, :path, :position, :dashboard_component, :data_cleaner, :push_notification_items)

  class << self
    def register(name:, label:, icon:, path:, position: 100, dashboard_component: nil, data_cleaner: nil, push_notification_items: [])
      items = push_notification_items.map do |item|
        NotificationItem.new(key: item[:key], label: item[:label], description: item[:description])
      end
      plugins[name] = Plugin.new(name:, label:, icon:, path:, position:, dashboard_component:, data_cleaner:, push_notification_items: items)
    end

    def all
      plugins.values.sort_by(&:position)
    end

    def dashboard_plugins
      all.select(&:dashboard_component)
    end

    def notification_plugins
      all.select { |p| p.push_notification_items.any? }
    end

    def find(name)
      plugins[name]
    end

    def registered?(name)
      plugins.key?(name)
    end

    def clear!
      plugins.clear
    end

    private

    def plugins
      @plugins ||= {}
    end
  end
end
