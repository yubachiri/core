class User < ApplicationRecord
  has_many :projects
  has_many :project_members
  has_many :joined_projects, through: :project_members, source: :project
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  validates :name, presence: true

end
