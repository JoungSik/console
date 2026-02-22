class HomeController < ApplicationController
  def index
    @dashboard_components = PluginRegistry.dashboard_plugins.filter_map do |plugin|
      plugin.dashboard_component.constantize.new(user_id: current_user.id).load_data
    rescue => e
      Rails.logger.error("대시보드 로드 실패 [#{plugin.name}]: #{e.message}")
      nil
    end
  end
end
