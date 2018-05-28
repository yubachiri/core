class Story < ApplicationRecord
  belongs_to :project
  validates_presence_of :title
  validates :point, numericality: true, length: { maximum: 3 }

  # 進捗状況管理ステータス
  enum progress_status: [:iced, :in_progress, :done]
  # ワークフロー管理
  enum workflow: [:start, :finish, :accept, :completed]
  # 重要度度最下位
  LOWEST = 0

  # 重要度設定をし、モデルを新規登録する
  def create_and_update_importance(lower_story_id)
    project        = Project.find(self.project_id)

    lower_story_id = 0 if lower_story_id.nil?

    self.calc_importance project, lower_story_id, Story.progress_statuses[:iced]
    self.save

  end

  # 自身と上位優先度の重要度を設定し、モデルを更新する
  def save_and_update_importance(new_story_params, lower_story_id)
    self.title       = new_story_params[:title]
    self.description = new_story_params[:description]
    self.point       = new_story_params[:point]
    lower_story_id   = 0 if lower_story_id.nil?

    self.calc_importance project, lower_story_id
    self.save
  end

  # アイス/バックを切り替える
  def update_status_to_other

    project = Project.find(self.project_id)

    if self.iced?
      stat_after_change = Story.progress_statuses[:in_progress]
    elsif self.in_progress?
      stat_after_change = Story.progress_statuses[:iced]
    end

    # 変更後ステータスをもつストーリーの中で重要度が最下位のストーリーを取得する
    bottom_story = project.stories
                     .where([
                              "importance = ? and progress_status = ?",
                              project.stories.minimum('importance'),
                              "#{stat_after_change}"
                            ])
                     .order("importance")
                     .first
    bottom_story.calc_importance project, self.id if bottom_story.present?

    self.calc_importance project, self.id, stat_after_change
    self.progress_status = stat_after_change

    Story.transaction do
      bottom_story.save! if bottom_story.present?
      self.save!
      return true
    end
  rescue => e
    puts e.message
    return false

  end

  # ワークフローを次の状態にする
  def update_workflow_to_next
    case
    when self.start?
      self.finish!
    when self.finish?
      self.accept!
    when self.accept?
      self.completed!
    when self.completed?
      # through
    else
      self.start!
    end
  end


  def calc_importance(project, lower_story_id, which_area = Story.progress_statuses[self.progress_status])

    puts "calc 開始"

    project_stories = project.stories.where("progress_status = ?", which_area).order('importance desc')

    lower_story = project_stories.find_by(id: lower_story_id)
    if lower_story.present? && project_stories.find_index(lower_story) > 0
      upper_story = project_stories[project_stories.find_index(lower_story) - 1]
    end

    puts lower_story.id if lower_story.present?
    puts upper_story.id if upper_story.present?

    if upper_story.present?
      puts "upperあり"
      self.importance = (lower_story.importance.to_f + upper_story.importance.to_f) / 2
    elsif lower_story.present?
      puts "lowerあり"
      self.importance = lower_story.importance + 1
    else
      puts "何もなし"
      if project_stories.present?
        if project_stories.count >= 2
          lowest_story           = project_stories.last
          second_from_last_story = project_stories[project_stories.find_index(lowest_story) - 1]
          average_of_importance  = (lowest_story.importance.to_f + second_from_last_story.importance.to_f) / 2
          lowest_story.update(importance: average_of_importance)
        else
          project_stories.last.update(importance: 1)
        end
      end
      self.importance = LOWEST
    end

  end

  class << self

    # 引数のプロジェクトのicedストーリーを重要度順の配列で返す
    def make_iced_stories_array(project)
      @ordered_iced_stories = project.stories.where(
        "progress_status = ?",
        Story.progress_statuses[:iced]).order("importance desc"
      )
    end

    # 引数のプロジェクトのin_progressストーリーを重要度順の配列で返す
    def make_in_progress_stories_array(project)

      @ordered_iced_stories = project.stories.where(
        "progress_status = ?",
        Story.progress_statuses[:in_progress]
      ).order("importance desc")

    end

  end

end
