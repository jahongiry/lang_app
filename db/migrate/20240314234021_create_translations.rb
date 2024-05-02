class CreateTranslations < ActiveRecord::Migration[7.0]
  def change
    create_table :translations do |t|
      t.references :media_item, null: false, foreign_key: true
      t.string :word
      t.string :translation

      t.timestamps
    end
  end
end
