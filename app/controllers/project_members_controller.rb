class ProjectMembersController < ApplicationController
  def new
    @project = Project.find(params[:project_id])
  end

  def create
    new_member = User.find(params[:member_id])
    @project   = Project.find(params[:project_id])

    if @project.project_members.build(user: new_member).save
      flash[:success] = "メンバーを追加しました。"
      redirect_to project_users_path(@project)
    else
      flash[:danger] = "エラーが発生しました。"
      redirect_to new_project_project_member_path(@project)
    end

  end

  def confirm
    @project        = Project.find(params[:project_id])
    @invited_member = User.search(params[:search])
  end

  def destroy
    @removed_user = User.find(params[:id])
    @project = Project.find(params[:project_id])
    is_admin = @project.project_members.find_by(user_id: current_user.id).admin_flg?

    if is_admin && @project.project_members.find_by(user: @removed_user).delete
      flash[:success] = "#{@removed_user.name}さんをプロジェクトから外しました。"
    else
      flash[:danger] = "エラーが発生しました。"
    end

    redirect_to project_users_path(@project)
  end
end
