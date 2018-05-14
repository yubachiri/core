class StoriesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :show, :update]

  def new
    @new_story = Story.new
    @project   = Project.find(params[:project_id])
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

  def update
    @project = Project.find(params[:project_id])
    authorize @project, :update_story?

    story_id       = params[:id]
    new_story      = params[story_id]
    original_story = Story.find(story_id)

    if original_story.update(title: new_story[:title], description: new_story[:description])
      flash[:success] = "ストーリーを更新しました。"
    else
      flash[:danger] = "エラーが発生しました。"
    end

    redirect_to @project
  end

  private

  def story_params
    params.require(:story).permit(:title, :description, :project_id)
  end

  def make_param_symbol(tag_type, story_id)
    ":#{tag_type}#{story_id}"
  end

end
