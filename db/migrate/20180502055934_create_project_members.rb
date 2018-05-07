class CreateProjectMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :project_members do |t|
      t.references :user, index: true, foreign_key: true
      t.references :projects, index: true, foreign_key: true
      t.boolean :admin_flg, default: false, null: false

      t.timestamps
    end
  end
end
