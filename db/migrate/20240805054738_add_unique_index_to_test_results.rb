class AddUniqueIndexToTestResults < ActiveRecord::Migration[7.0]
  def change
    add_index :test_results, [:user_id, :multiple_question_id], unique: true
  end
end
