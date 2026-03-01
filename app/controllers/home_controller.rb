class HomeController < ApplicationController
  allow_unauthenticated_access only: :index
  layout :choose_layout

  def index
    if authenticated?
      load_dashboard
    else
      render :landing
    end
  end

  private

  def load_dashboard
    # 사용자가 활성화한 플러그인의 대시보드 위젯만 로드
    active_plugins = current_user.enabled_plugins & PluginRegistry.dashboard_plugins

    @dashboard_components = active_plugins.filter_map do |plugin|
      plugin.dashboard_component.constantize.new(user_id: current_user.id).load_data
    rescue => e
      Rails.logger.error("대시보드 로드 실패 [#{plugin.name}]: #{e.message}")
      nil
    end

    # 삭제 임박 플러그인 경고
    @approaching_deletion_plugins = current_user.approaching_deletion_plugins
  end

  def choose_layout
    authenticated? ? "application" : "blank"
  end
end
