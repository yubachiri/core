class ProjectMembersController < ApplicationController
  def new
    @project = Project.find(params[:project_id])
  end

  def create
    puts "-----------"
    puts "呼ばれ！！"
    new_member = User.find(params[:member_id])
    @project       = Project.find(params[:project_id])

    if ProjectMember.regist_new_member new_member, @project
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
end
