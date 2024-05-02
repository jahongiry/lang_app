class TestResult < ApplicationRecord
  belongs_to :user
  belongs_to :multiple_question

  # Here you can add validations such as:
  validates :correct_count, :total_questions, :correct_percentage, :wrong_percentage, presence: true
end
