class CreateMultipleQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :multiple_questions do |t|
      t.references :media_item, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
