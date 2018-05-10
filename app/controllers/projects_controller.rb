class ProjectsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]
  # before_action :pundit_auth, only: [:index]
  after_action :verify_authorized, only: [:show]

  def index
    # ユーザが閲覧可能なプロジェクトの一覧を表示する
    @owner_prj, @joined_prj = Project.get_visible_projects current_user
  end

  def new
  end

  def create
    new_project = current_user.projects.build(name: params[:project_name])
    if new_project.save
      new_project.project_members.create(
        user_id: new_project.user_id,
        admin_flg: true)
      flash[:success] = "プロジェクトを作成しました。"
    else
      flash[:danger] = "エラーが発生しました。"
      redirect_back(fallback_location: projects_path)
    end
    redirect_to projects_path
  end

  def show
    @project = Project.find(params[:id])
    authorize @project
  end

end
