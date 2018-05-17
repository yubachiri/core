class StoriesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :show, :update]

  def new
    @new_story = Story.new
    @project   = Project.find(params[:project_id])

    @ordered_stories = Story.make_stories_array @project
    # ストーリー配列の末尾に、そのストーリーの優先度を最低にするための選択肢を追加する
    @ordered_stories << Story.new(id: Story::LOWEST, title: '保留')
    authorize @project, :new_story?
  end

  def create
    @project = Project.find(params[:project_id])
    authorize @project, :new_story?

    new_story = @project.stories.new(story_params)
    if new_story.create_and_update_importance
      flash[:success] = "ストーリーを追加しました。"
      redirect_to project_path(@project)
    else
      flash[:danger] = "エラーが発生しました。"
      redirect_to new_project_story_path(@project)
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

    if original_story.save_and_update_importance(new_story[:title], new_story[:description], new_story[:importance][original_story.importance.to_s])
      flash[:success] = "ストーリーを更新しました。"
    else
      flash[:danger] = "エラーが発生しました。"
    end

    redirect_to @project
  end

  private

  def story_params
    params.require(:story).permit(:title, :description, :project_id, :importance)
  end

end
