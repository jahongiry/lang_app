module Api
  module V1
    class AnswersController < ApplicationController
      before_action :authenticate_request
      before_action :set_multiple_question

      def create
        correct_count = 0
        params[:questions].each do |q|
          answer = @multiple_question.answers.build(
            content: q[:answer].to_s,
            correct: q[:answer],
            user_id: current_user.id
          )

          if answer.save
            correct_count += 1 if answer.correct
          end
        end

        total_answers = params[:questions].size
        correct_percentage = (correct_count.to_f / total_answers * 100).round(2)
        wrong_percentage = (100 - correct_percentage).round(2)

        render json: { correct_percentage: correct_percentage, wrong_percentage: wrong_percentage }, status: :created
      end

      private

      def set_multiple_question
        @multiple_question = MultipleQuestion.find(params[:multiple_question_id])
      end
    end
  end
end
