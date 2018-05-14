class StoriesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :show]

  def new
    @new_story = Story.new
    @project = Project.find(params[:project_id])
    authorize @project, :new_story?
  end

  def create
    @project = Project.find(params[:project_id])
    authorize @project, :new_story?
    if @project.stories.create(story_params)
      flash[:success] = "ストーリーを追加しました。"
      redirect_to project_path(@project)
    else
      flash[:danger] = "エラーが発生しました。"
      redirect_to new_project_story(@project)
    end
  end

  def show
  end

  private

  def story_params
    params.require(:story).permit(:title, :description, :project_id)
  end

end
