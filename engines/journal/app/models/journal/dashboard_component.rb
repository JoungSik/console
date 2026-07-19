module Journal
  class DashboardComponent < Console::DashboardComponent
    attr_reader :posts_count, :recent_posts

    def plugin_name = "포스트"

    def load_data
      posts = Journal::Post.by_user(user_id)

      @posts_count = posts.count
      @recent_posts = posts.recent.limit(3)
      self
    end

    def partial_path = "journal/dashboard/widget"
  end
end
