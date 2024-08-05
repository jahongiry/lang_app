class Answer < ApplicationRecord
  belongs_to :multiple_question
  has_many :user_answer_multiples, dependent: :destroy
end
