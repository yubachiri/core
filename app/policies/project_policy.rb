class ProjectPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    # 渡されたプロジェクトの所持者か参加者に現在のユーザがいればtrue
    @record.users.find_by(id: @user.id).present? || @record.user_id == @user.id
  end

  def show_user_index?
    show?
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
