class UserAnswerMultiple < ApplicationRecord
  belongs_to :user
  belongs_to :answer
  belongs_to :multiple_question

  validates :user_id, presence: true
  validates :answer_id, presence: true
  validates :multiple_question_id, presence: true
end
