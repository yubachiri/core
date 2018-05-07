class Project < ApplicationRecord
  has_many :users, through: :project_members
  has_many :project_members
  belongs_to :user
  accepts_nested_attributes_for :project_members
  validates :name, presence: true
  validates :user_id, presence: true

  class << self

    # 自分が作成したプロジェクトと参加しているプロジェクトをそれぞれ返す
    def get_visible_projects(current_user)
      @owner_prj  = current_user.projects.all
      @joined_prj = current_user.joined_projects.all
    end
  end
end
