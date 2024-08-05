class TestResult < ApplicationRecord
  belongs_to :user
  belongs_to :multiple_question

  validates :user_id, presence: true
  validates :multiple_question_id, presence: true
  validates :correct_count, presence: true
  validates :total_questions, presence: true
  validates :correct_percentage, presence: true
  validates :wrong_percentage, presence: true
end
