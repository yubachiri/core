class ProjectMember < ApplicationRecord
  belongs_to :user
  belongs_to :project

  def self.regist_new_member(new_member, project)
    temp_obj = ProjectMember.new(
                              user_id: new_member.id,
                              project_id: project.id
    )
    temp_obj.save
  end
end
