class MediaItem < ApplicationRecord
  belongs_to :lesson
  has_many :translations, dependent: :destroy
  has_one_attached :image
  has_many :multiple_questions, dependent: :destroy
end
