class Question < ApplicationRecord
  belongs_to :text_question_set
  has_many :user_answers
end
