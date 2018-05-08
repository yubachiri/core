class ProjectPolicy < ApplicationPolicy
  def index?
    # @user current_userが空ならfalseを返す
    !@user.nil?
  end

  def show?
    # 渡されたプロジェクトの参加者に現在のユーザがいればtrue
    !!@record.users.find_by(id: @user.id) || @record.user_id == @user.id
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
