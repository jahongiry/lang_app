class RemoveCompletedFromLessons < ActiveRecord::Migration[7.0]
  def change
    remove_column :lessons, :completed, :boolean
  end
end
