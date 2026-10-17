module Inspiration
  class DashboardComponent < Console::DashboardComponent
    RECENT_IDEAS_LIMIT = 5

    attr_reader :recent_ideas

    def plugin_name = I18n.t("inspiration.title")

    def load_data
      @recent_ideas = Inspiration::Idea.by_user(user_id).recent.limit(RECENT_IDEAS_LIMIT).load
      self
    end

    def partial_path = "inspiration/dashboard/widget"
  end
end
