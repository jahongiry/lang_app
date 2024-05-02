class Translation < ApplicationRecord
  belongs_to :media_item

  attribute :array_of_objects, :json, default: []

  def as_json(options = {})
    super(options).merge({
      array_of_objects: array_of_objects
    })
  end
end
