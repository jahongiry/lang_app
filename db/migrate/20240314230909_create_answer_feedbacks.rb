class CreateAnswerFeedbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :answer_feedbacks do |t|
      t.integer :score
      t.text :comment
      t.references :user_answer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
