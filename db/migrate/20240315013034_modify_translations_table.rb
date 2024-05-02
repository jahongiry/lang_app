class ModifyTranslationsTable < ActiveRecord::Migration[7.0]
  def change
      remove_column :translations, :word, :string
    remove_column :translations, :translation, :string
    add_column :translations, :array_of_objects, :json, default: []
  end
end
