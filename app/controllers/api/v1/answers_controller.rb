module Api
  module V1
    class AnswersController < ApplicationController
      before_action :authenticate_request
      before_action :set_multiple_question

      def create
        correct_count = 0
        total_answers = params[:questions].size

        params[:questions].each do |q|
          is_correct = q[:answer]
          @multiple_question.answers.create(
            content: "User's choice was: #{is_correct}",  # Placeholder for actual answer content
            correct: is_correct
          )

          correct_count += 1 if is_correct
        end

        correct_percentage = (correct_count.to_f / total_answers * 100).round(2)
        wrong_percentage = (100 - correct_percentage).round(2)

        # Save the test result
        test_result = TestResult.create(
          user_id: current_user.id,
          multiple_question_id: @multiple_question.id,
          correct_count: correct_count,
          total_questions: total_answers,
          correct_percentage: correct_percentage,
          wrong_percentage: wrong_percentage
        )

        if test_result.save
          render json: { test_result_id: test_result.id, correct_percentage: correct_percentage, wrong_percentage: wrong_percentage }, status: :created
        else
          render json: { errors: test_result.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_multiple_question
        @multiple_question = MultipleQuestion.find(params[:multiple_question_id])
      end
    end
  end
end
