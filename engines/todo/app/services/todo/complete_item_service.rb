module Todo
  class CompleteItemService
    def initialize(item)
      @item = item
    end

    def call
      ActiveRecord::Base.transaction do
        @item.update!(completed: true)
        create_next_recurrence if @item.can_recur_next?
      end
      @item
    end

    private

    def create_next_recurrence
      @item.list.items.create!(
        title: @item.title,
        url: @item.url,
        recurrence: @item.recurrence,
        recurrence_ends_on: @item.recurrence_ends_on,
        due_date: @item.next_due_date,
        recurrence_parent_id: @item.id
      )
    end
  end
end
