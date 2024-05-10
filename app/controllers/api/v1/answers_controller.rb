module Api
  module V1
    class AnswersController < ApplicationController
      before_action :authenticate_request

      def create
        answers = Answer.where(id: params[:questions].map { |q| q[:id] })
        multiple_questions = answers.map(&:multiple_question).uniq

        if multiple_questions.length != 1
          render json: { error: "Answers must belong to the same multiple question." }, status: :unprocessable_entity
          return
        end

        @multiple_question = multiple_questions.first
        correct_count = 0
        total_answers = params[:questions].size

        params[:questions].each do |q|
          answer = answers.find { |a| a.id == q[:id].to_i }
          if answer.update(correct: q[:answer])
            correct_count += 1 if q[:answer]
          end
        end

        correct_percentage = (correct_count.to_f / total_answers * 100).round(2)
        wrong_percentage = (100 - correct_percentage).round(2)

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
    end
  end
end
