class ProjectPolicy < ApplicationPolicy
  def index?
    # @user current_userが空ならfalseを返す
    !@user.nil?
  end

  def show?
    true
  end

  def create?
    true
  end

  def new?
    create?
  end

  def update?
    true
  end

  def edit?
    update?
  end

  def destroy?
    true
  end
end
