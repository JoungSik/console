class TodoPolicy < ApplicationPolicy
  def update?
    user.present? && record.todo_list.user_id == user.id
  end

  def destroy?
    user.present? && record.todo_list.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:todo_list).where(todo_lists: { user_id: user.id })
    end
  end
end
