class CreateTextQuestionSets < ActiveRecord::Migration[7.0]
  def change
    create_table :text_question_sets do |t|
      t.text :text
      t.references :lesson, null: false, foreign_key: true

      t.timestamps
    end
  end
end
