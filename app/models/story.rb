class Story < ApplicationRecord
  belongs_to :project
  validates_presence_of :title
  # 重要度度最下位
  LOWEST = -1

  # 重要度設定をし、ストーリーを新規登録する
  def create_and_update_importance
    # 選択したストーリーの上位に設定されているストーリーを取得する
    upper_story = Story.find_by(importance: self.importance)
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
  def save_and_update_importance(title, description, importance)

    # puts "---全部表示する---"
    #
    # puts self.id
    # puts self.importance
    # puts importance
    #
    # puts "-----------------"

    self.title       = title
    self.description = description

    # 重要度が変更されていなければ自身をupdateしreturnする
    if self.importance.to_i == importance.to_i
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

  class << self

    # 引数のプロジェクトのストーリーを重要度順の配列にして返す
    def make_stories_array(project)
      @ordered_stories = Array.new()
      # importanceが-1となっているストーリーが最も優先度が低い
      if last_story = project.stories.find_by(importance: LOWEST)
        @ordered_stories << last_story

        until @ordered_stories.count == project.stories.count
          # 配列の先頭のidでimportanceを検索することで、一つ上位の優先度となるストーリーを取得し、
          # 配列の先頭に追加する
          @ordered_stories.unshift project.stories.find_by(importance: @ordered_stories.first.id)
        end
      end
      @ordered_stories
    end
  end

end
