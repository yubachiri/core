class AddProgressStatusStory < ActiveRecord::Migration[5.2]
  def change
    add_column :stories, :progress_status, :integer
  end
end
