module Todo
  class UncompleteItemService
    def initialize(item)
      @item = item
    end

    def call
      ActiveRecord::Base.transaction do
        @item.update!(completed: false)
        @item.recurrence_child&.destroy!
      end
      @item
    end
  end
end
