class CreateMediaItems < ActiveRecord::Migration[7.0]
  def change
    create_table :media_items do |t|
      t.references :lesson, null: false, foreign_key: true
      t.string :media_type
      t.string :media_link

      t.timestamps
    end
  end
end
