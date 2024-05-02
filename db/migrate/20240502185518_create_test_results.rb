class CreateTestResults < ActiveRecord::Migration[7.0]
  def change
    create_table :test_results do |t|
      t.references :user, null: false, foreign_key: true
      t.references :multiple_question, null: false, foreign_key: true
      t.integer :correct_count
      t.integer :total_questions
      t.float :correct_percentage
      t.float :wrong_percentage

      t.timestamps
    end
  end
end
