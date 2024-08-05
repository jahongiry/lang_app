module Api
  module V1
    class TestResultsController < ApplicationController
      before_action :authenticate_request
      before_action :set_multiple_question, only: [:index, :show]

      # GET /api/v1/lessons/:lesson_id/media_items/:media_item_id/multiple_questions/:multiple_question_id/test_results
      def index
        @test_results = @multiple_question.test_results
        render json: @test_results
      end

      # GET /api/v1/lessons/:lesson_id/media_items/:media_item_id/multiple_questions/:multiple_question_id/test_results/:id
      def show
        @test_result = @multiple_question.test_results.find(params[:id])
        render json: @test_result
      end

      private

      def set_multiple_question
        @multiple_question = MultipleQuestion.find(params[:multiple_question_id])
      end
    end
  end
end
