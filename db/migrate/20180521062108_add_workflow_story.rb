class AddWorkflowStory < ActiveRecord::Migration[5.2]
  def change
    add_column :stories, :workflow, :integer
  end
end
