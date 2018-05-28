class CreateStories < ActiveRecord::Migration[5.2]
  def change
    create_table :stories do |t|
      t.string :title, presence: true
      t.string :description
      t.integer :importance
      t.integer :point
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
