module HotwireNative
  class PathConfigurationsController < ApplicationController
    allow_unauthenticated_access

    def show
      expires_in 5.minutes, public: true
      render json: JSON.parse(path_configuration_path.read)
    end

    private

    def path_configuration_path
      Rails.root.join("config/hotwire_native/path-configuration.json")
    end
  end
end
