class MultipleQuestion < ApplicationRecord
  belongs_to :media_item
  has_many :answers, dependent: :destroy
  has_many :test_results, dependent: :destroy
  has_many :user_answer_multiples, dependent: :destroy

  accepts_nested_attributes_for :answers

  validates :content, presence: true
end
