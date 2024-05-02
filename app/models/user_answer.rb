class UserAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :question
  has_many :answer_feedbacks, dependent: :destroy
end
