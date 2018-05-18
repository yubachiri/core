class StoriesController < ApplicationController
  before_action :authenticate_user!
  # パラメータより@projectを生成する
  before_action :find_current_project

  def new
    @new_story = Story.new
    authorize @project, :new_story?

    @ordered_iced_stories = Story.make_iced_stories_array @project
    # ストーリー配列の末尾に、そのストーリーの優先度を最低にするための選択肢を追加する
    @ordered_iced_stories << Story.new(id: Story::LOWEST, title: '保留')
  end

  def create
    authorize @project, :new_story?

    new_story = @project.stories.new(story_params)
    new_story.point = new_story.point.to_i
    new_story.progress_status = Story.progress_statuses[:iced]

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
    authorize @project, :update_story?

    story_id       = params[:id]
    new_story      = params[story_id]
    original_story = Story.find(story_id)

    if original_story.save_and_update_importance(new_story[:title], new_story[:description], new_story[:importance][original_story.importance.to_s], new_story[:point], original_story.progress_status)
      flash[:success] = "ストーリーを更新しました。"
    else
      flash[:danger] = "エラーが発生しました。"
    end

    redirect_to project_path(@project)
  end

  def update_status
    # story_id       = params[:id]
    # new_story      = params[story_id]
    target_story = Story.find(params[:id])
    target_story.update_status_to_in_progress
    # target_story.update(progress_status: Story.progress_status[:in_progress])

    redirect_to project_path(@project)
  end

  private

  def story_params
    params.require(:story).permit(:title, :description, :project_id, :importance, :point)
  end

  def find_current_project
    @project = Project.find(params[:project_id])
  end

end
