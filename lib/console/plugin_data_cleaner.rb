module Console
  module PluginDataCleaner
    def self.clean_data_for(plugin_name:, user_id:)
      cleaner_class_for(plugin_name).call(user_id: user_id)
      true
    rescue NameError => e
      Rails.logger.warn("데이터 클리너 없음 [#{plugin_name}]: #{e.message}")
      false
    end

    def self.cleaner_class_for(plugin_name)
      [
        registered_cleaner_class_name(plugin_name),
        "#{plugin_name.to_s.classify}::DataCleaner",
        "#{plugin_name.to_s.camelize}::DataCleaner"
      ].compact.uniq.find { |class_name| class_name.safe_constantize }&.constantize || raise(NameError, plugin_name.to_s)
    end

    def self.registered_cleaner_class_name(plugin_name)
      plugin = PluginRegistry.find(plugin_name.to_sym)
      plugin&.data_cleaner || cleaner_class_name_from_dashboard(plugin)
    end

    def self.cleaner_class_name_from_dashboard(plugin)
      namespace = plugin&.dashboard_component&.deconstantize
      "#{namespace}::DataCleaner" if namespace
    end
  end
end
