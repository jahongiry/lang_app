module Api
  module V1
    class AnswersController < ApplicationController
      before_action :authenticate_request
      before_action :set_multiple_question

      def create
        correct_count = 0
        total_answers = params[:questions].size

        params[:questions].each do |q|
          # Directly take the provided answer's correctness
          is_correct = q[:answer]

          # Create the answer with given correctness
          answer = @multiple_question.answers.create(
            content: "User's choice was: #{is_correct}",  # Placeholder for actual answer content
            correct: is_correct
          )

          # Update the correct count based on the answer's correctness
          correct_count += 1 if answer.correct
        end

        # Calculate the percentages
        correct_percentage = (correct_count.to_f / total_answers * 100).round(2)
        wrong_percentage = (100 - correct_percentage).round(2)

        # Render the results as JSON
        render json: { correct_percentage: correct_percentage, wrong_percentage: wrong_percentage }, status: :created
      end

      private

      def set_multiple_question
        @multiple_question = MultipleQuestion.find(params[:multiple_question_id])
      end
    end
  end
end
