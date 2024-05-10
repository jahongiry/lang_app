class Lesson < ApplicationRecord
  has_many :user_lessons
  has_many :users, through: :user_lessons
  has_many :text_question_sets, dependent: :destroy
  has_many :media_items, dependent: :destroy
  has_many :multiple_questions, through: :media_items 

def calculate_results(user)
  total_correct = 0
  total_questions = 0
  
  multiple_questions.each do |mq|
    answers = Answer.where(multiple_question_id: mq.id, user_id: user.id)
    total_questions += answers.count
    total_correct += answers.where(correct: true).count
  end
  
  if total_questions == 0
    { correct_percentage: 0, wrong_percentage: 0 }
  else
    correct_percentage = (total_correct.to_f / total_questions * 100).round(2)
    { correct_percentage: correct_percentage, wrong_percentage: (100 - correct_percentage).round(2) }
  end
end


end
