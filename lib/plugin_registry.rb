# 플러그인 등록/조회를 관리하는 레지스트리
# 각 Engine은 initializer에서 이 레지스트리에 자기 자신을 등록한다.
class PluginRegistry
  Plugin = Data.define(:name, :label, :icon, :path, :position)

  class << self
    def register(name:, label:, icon:, path:, position: 100)
      plugins[name] = Plugin.new(name:, label:, icon:, path:, position:)
    end

    def all
      plugins.values.sort_by(&:position)
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
