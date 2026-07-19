module Console
  class DashboardComponent
    attr_reader :user_id

    def initialize(user_id:)
      @user_id = user_id
    end

    def plugin_name = raise NotImplementedError

    def load_data = raise NotImplementedError

    def partial_path = raise NotImplementedError

    def locals
      { component: self }
    end
  end
end
