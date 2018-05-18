class Story < ApplicationRecord
  belongs_to :project
  validates_presence_of :title
  validates :point, numericality: true

  # 進捗状況管理ステータス
  enum progress_status: [:iced, :in_progress, :done]
  # 重要度度最下位
  LOWEST = -1

  # 重要度設定をし、ストーリーを新規登録する
  def create_and_update_importance
    # 選択したストーリーの上位に設定されているストーリーを取得する
    upper_story = Story.find_by(importance: self.importance, progress_status: Story.progress_statuses[:iced])
    Story.transaction do
      self.save!
      upper_story.update!(importance: self.id) if upper_story.present?
      return true
    end
  rescue => e
    puts e.message
    return false
  end

  # 自身と上位優先度の重要度を設定し、モデルを更新する
  def save_and_update_importance(title, description, importance, point, progress_status)
    self.title           = title
    self.description     = description
    self.point           = point
    self.progress_status = progress_status

    # 重要度が変更されていなければ自身をupdateしreturnする
    if (self.importance.to_i == importance.to_i) || (self.importance.to_i == LOWEST && self.id == importance.to_i)
      return self.save
    end

    # 現在の自身の上位ストーリー
    cur_upper_story            = Story.find_by(importance: self.id)
    cur_upper_story.importance = self.importance if cur_upper_story.present?

    # 編集後の自身の上位ストーリー
    aft_upper_story            = Story.find_by(importance: importance)
    aft_upper_story.importance = self.id if aft_upper_story.present?

    if self.id != importance.to_i
      self.importance = importance
    end

    Story.transaction do
      self.save!
      cur_upper_story.save! if cur_upper_story.present?
      aft_upper_story.save! if aft_upper_story.present?
    end
    return true
  rescue => e
    puts e.message
    return false
  end

  # アイス/バックを切り替える
  def update_status_to_other

    if self.iced?
      stat_afer_change = Story.progress_statuses[:in_progress]
    elsif self.in_progress?
      stat_afer_change = Story.progress_statuses[:iced]
    end

    cur_upper_story            = Story.find_by(importance: self.id)
    cur_upper_story.importance = self.importance if cur_upper_story.present?

    # 自身を最下位に追加するため、変更後ステータスで現在最下位のストーリーを更新する
    aft_upper_story            = Story.find_by(importance: LOWEST, progress_status: stat_afer_change)
    aft_upper_story.importance = self.id if aft_upper_story.present?

    Story.transaction do
      self.update!(progress_status: stat_afer_change, importance: LOWEST)
      cur_upper_story.save! if cur_upper_story.present?
      aft_upper_story.save! if aft_upper_story.present?
    end
  rescue => e
    puts e.message
    return false
  end


  class << self

    # 引数のプロジェクトのicedストーリーを重要度順の配列で返す
    def make_iced_stories_array(project)
      @ordered_iced_stories = Array.new()
      # importanceが-1となっているストーリーが最も優先度が低い
      if last_story = project.stories.find_by(importance: LOWEST, progress_status: Story.progress_statuses[:iced])
        @ordered_iced_stories << last_story

        until @ordered_iced_stories.count == project.stories.where(progress_status: Story.progress_statuses[:iced]).count
          # 配列の先頭のidでimportanceを検索することで、一つ上位の優先度となるストーリーを取得し、
          # 配列の先頭に追加する
          @ordered_iced_stories.unshift project.stories.find_by(importance: @ordered_iced_stories.first.id)
        end
      end
      @ordered_iced_stories
    end

    # 引数のプロジェクトのin_progressストーリーを重要度順の配列で返す
    def make_in_progress_stories_array(project)
      @ordered_in_progress_stories = Array.new()
      if last_story = project.stories.find_by(importance: LOWEST, progress_status: Story.progress_statuses[:in_progress])
        @ordered_in_progress_stories << last_story

        until @ordered_in_progress_stories.count == project.stories.where(progress_status: Story.progress_statuses[:in_progress]).count
          @ordered_in_progress_stories.unshift project.stories.find_by(importance: @ordered_in_progress_stories.first.id)
        end
      end
      @ordered_in_progress_stories
    end
  end

end
