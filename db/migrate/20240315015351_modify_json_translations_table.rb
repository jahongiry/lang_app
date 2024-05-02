class ModifyJsonTranslationsTable < ActiveRecord::Migration[7.0]
  def change
    change_column_default :translations, :array_of_objects, from: nil, to: [].to_json
  end
end
