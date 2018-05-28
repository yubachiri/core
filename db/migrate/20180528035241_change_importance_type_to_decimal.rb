class ChangeImportanceTypeToDecimal < ActiveRecord::Migration[5.2]
  def change
    change_column :stories, :importance, :decimal
    add_index :stories, :importance
  end
end
