class StoriesController < ApplicationController
  before_action :authenticate_user!
  # パラメータより@projectを生成する
  before_action :find_current_project

  def new
    @new_story = Story.new
    authorize @project, :new_story?

    @ordered_iced_stories = Story.make_iced_stories_array @project
  end

  def create
    authorize @project, :new_story?

    new_story       = @project.stories.new(story_params)
    new_story.point = new_story.point.to_i
    # 進行状況・ワークフローはアイスボックス・startとする
    new_story.progress_status = Story.progress_statuses[:iced]
    new_story.workflow        = Story.workflows[:start]

    if new_story.create_and_update_importance(new_story.importance)
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

    story_id = params[:id]
    new_story      = params[story_id]
    original_story = Story.find(story_id)

    if original_story.save_and_update_importance(new_story, new_story[:importance])
      flash[:success] = "ストーリーを更新しました。"
    else
      flash[:danger] = "エラーが発生しました。"
    end

    redirect_to project_path(@project)
  end

  def update_status
    authorize @project, :update?
    target_story = Story.find(params[:id])
    target_story.update_status_to_other

    redirect_to project_path(@project)
  end

  # ストーリーのワークフローを次の状態にする
  def update_workflow
    authorize @project, :update?
    target_story = Story.find(params[:id])
    target_story.update_workflow_to_next

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
