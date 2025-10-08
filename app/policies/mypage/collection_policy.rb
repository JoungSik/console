class Mypage::CollectionPolicy < ApplicationPolicy
  def edit?
    user.present? && record.user_id == user.id
  end

  def update?
    user.present? && record.user_id == user.id
  end

  def destroy?
    user.present? && record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: user)
    end
  end
end
