module Api
  module V1
    class AnswerFeedbacksController < ApplicationController
      before_action :set_user_answer, only: [:create, :update]
      before_action :set_answer_feedback, only: [:update]

      def create
        @answer_feedback = @user_answer.build_answer_feedback(answer_feedback_params)
        if @answer_feedback.save
          render json: @answer_feedback, status: :created
        else
          render json: @answer_feedback.errors, status: :unprocessable_entity
        end
      end

      def update
        if @answer_feedback.update(answer_feedback_params)
          render json: @answer_feedback
        else
          render json: @answer_feedback.errors, status: :unprocessable_entity
        end
      end

      private

      def set_user_answer
        @user_answer = UserAnswer.find(params[:user_answer_id])
      end

      def set_answer_feedback
        @answer_feedback = @user_answer.answer_feedback
      end

      def answer_feedback_params
        params.require(:answer_feedback).permit(:score, :comment)
      end
    end
  end
end
