class ProjectsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show, :create, :update_velocity]
  after_action :verify_authorized, only: [:show, :update_velocity]

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
        user_id:   new_project.user_id,
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
    @ordered_iced_stories        = Story.make_iced_stories_array @project
    @ordered_in_progress_stories = Story.make_in_progress_stories_array @project
    if @ordered_iced_stories.count.zero?
      @ordered_iced_stories = nil
    else
      @select_importance = @ordered_iced_stories.clone << Story.new(id: Story::LOWEST, title: '保留')
    end
    if @ordered_in_progress_stories.count.zero?
      @ordered_in_progress_stories = nil
    else
      @in_pr_select_importance = @ordered_in_progress_stories.clone << Story.new(id: Story::LOWEST, title: '保留')
    end
  end

  def update_velocity
    @project = Project.find(params[:id])
    authorize @project, :update?

    redirect_to project_path(@project)
  end

end
