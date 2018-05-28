class AddVelocityProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :velocity, :integer
  end
end
