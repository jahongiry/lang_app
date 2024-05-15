class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :surname, presence: true

  has_many :user_lessons, dependent: :destroy
  has_many :lessons, through: :user_lessons
  has_many :user_answers, dependent: :destroy

  def teacher?
    teacher
  end

  def lesson_results(lesson)
    # Assuming a has_many relationship through a results or scores table, adjust as necessary
    self.lessons.where(id: lesson.id).first
  end
end
