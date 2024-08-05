class CreateUserAnswerMultiples < ActiveRecord::Migration[7.0]
  def change
    create_table :user_answer_multiples do |t|
      t.references :user, null: false, foreign_key: true
      t.references :answer, null: false, foreign_key: true
      t.references :multiple_question, null: false, foreign_key: true
      t.boolean :correct

      t.timestamps
    end
  end
end
