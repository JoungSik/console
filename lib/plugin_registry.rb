# 플러그인 등록/조회를 관리하는 레지스트리
# 각 Engine은 initializer에서 이 레지스트리에 자기 자신을 등록한다.
class PluginRegistry
  NotificationItem = Data.define(:key, :label, :description)
  Plugin = Data.define(:name, :label, :icon, :path, :position, :dashboard_component, :push_notification_items)

  class << self
    def register(name:, label:, icon:, path:, position: 100, dashboard_component: nil, push_notification_items: [])
      items = push_notification_items.map do |item|
        NotificationItem.new(key: item[:key], label: item[:label], description: item[:description])
      end
      plugins[name] = Plugin.new(name:, label:, icon:, path:, position:, dashboard_component:, push_notification_items: items)
    end

    def all
      plugins.values.sort_by(&:position)
    end

    # dashboard_component가 등록된 플러그인만 반환
    def dashboard_plugins
      all.select(&:dashboard_component)
    end

    # push_notification_items가 등록된 플러그인만 반환
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
