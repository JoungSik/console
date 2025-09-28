module NavigationHelper
  def navigation_items
    items = [
      {
        name: t("navigation.home"),
        path: root_path,
        icon: "home",
        active_paths: [ root_path ]
      },
      {
        name: t("navigation.collections"),
        path: collections_path,
        icon: "folder",
        active_paths: [ collections_path, mypage_collections_path ]
      }
    ]

    # 로그인한 사용자만 볼 수 있는 메뉴
    if authenticated?
      items << {
        name: t("navigation.todo_links"),
        path: todo_lists_path,
        icon: "layout-list",
        active_paths: [ todo_lists_path ]
      }
      items << {
        name: t("navigation.profile"),
        path: "#", # TODO: 프로필 페이지 구현 후 수정
        icon: "user",
        active_paths: []
      }
    else
      items << {
        name: t("navigation.login"),
        path: new_session_path,
        icon: "log-in",
        active_paths: [ new_session_path ]
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

    # 홈페이지는 정확히 일치할 때만 활성화
    if item[:path] == root_path
      return current_path == root_path
    end

    # 다른 페이지들은 start_with 로직 사용
    item[:active_paths].any? { |path| current_path.start_with?(path.split("?").first) }
  end
end
