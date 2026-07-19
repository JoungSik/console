module NavigationHelper
  def navigation_items
    items = [
      {
        name: t("navigation.home"),
        path: main_app.root_path,
        icon: "home",
        active_paths: [ main_app.root_path ]
      }
    ]

    if authenticated?
      current_user.enabled_plugins.each do |plugin|
        items << {
          name: plugin.label,
          path: plugin.path,
          icon: plugin.icon,
          active_paths: [ plugin.path ]
        }
      end

      items << {
        name: t("navigation.mypage"),
        path: main_app.mypage_user_path,
        icon: "user",
        active_paths: [ main_app.mypage_user_path ]
      }
    else
      items << {
        name: t("navigation.login"),
        path: main_app.new_session_path,
        icon: "log-in",
        active_paths: [ main_app.new_session_path ]
      }
    end

    items
  end

  def current_navigation_item
    current_path = request.path
    navigation_items.find do |item|
      item[:active_paths].any? { |path| current_path.start_with?(path.split("?").first) }
    end
  end

  def navigation_item_active?(item)
    current_path = request.path

    if item[:path] == main_app.root_path
      return current_path == main_app.root_path
    end

    item[:active_paths].any? { |path| current_path.start_with?(path.split("?").first) }
  end
end
