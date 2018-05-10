class ProjectMembersController < ApplicationController
  def new
    @project = Project.find(params[:project_id])
  end

  def create
    @project       = Project.find(params[:project_id])
    invited_member = User.find(params[:member_id])

    if invited_member
      new_project_member = ProjectMember.new(
        user_id:    invited_member.id,
        project_id: @project.id
      )
    end

    if new_project_member.save
      flash[:success] = "メンバーを追加しました。"
      redirect_to project_users_path(@project)
    else
      flash[:danger] = "エラーが発生しました。"
      redirect_to new_project_project_member_path(@project)
    end

  end

  def confirm
    @project       = Project.find(params[:project_id])
    @invited_member = User.search(params[:search])
    respond_to do |format|
      format.html
      format.js
    end
  end
end
