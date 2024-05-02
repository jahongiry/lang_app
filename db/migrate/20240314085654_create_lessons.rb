class CreateLessons < ActiveRecord::Migration[7.0]
  def change
    create_table :lessons do |t|
      t.integer :index
      t.string :title
      t.text :description
      t.boolean :completed, default: false
      t.integer :score
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :lessons, :index
  end
end
