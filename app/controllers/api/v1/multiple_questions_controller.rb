module Api
  module V1
    class MultipleQuestionsController < ApplicationController
      before_action :set_media_item
      before_action :set_multiple_question, only: [:show, :update, :destroy]

      # GET /api/v1/lessons/:lesson_id/media_items/:media_item_id/multiple_questions
      def index
        @multiple_questions = @media_item.multiple_questions
        render json: @multiple_questions, include: 'answers'
      end

      # GET /api/v1/lessons/:lesson_id/media_items/:media_item_id/multiple_questions/:id
      def show
        render json: @multiple_question, include: 'answers'
      end

      # POST /api/v1/lessons/:lesson_id/media_items/:media_item_id/multiple_questions
      def create
        @multiple_question = @media_item.multiple_questions.new(multiple_question_params)

        if @multiple_question.save
          render json: @multiple_question, status: :created
        else
          render json: @multiple_question.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/lessons/:lesson_id/media_items/:media_item_id/multiple_questions/:id
      def update
        if @multiple_question.update(multiple_question_params)
          render json: @multiple_question
        else
          render json: @multiple_question.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/lessons/:lesson_id/media_items/:media_item_id/multiple_questions/:id
      def destroy
        @multiple_question.destroy
      end

      private

      def set_media_item
        @media_item = MediaItem.find(params[:media_item_id])
      end

      def set_multiple_question
        @multiple_question = @media_item.multiple_questions.find(params[:id])
      end

      def multiple_question_params
        params.require(:multiple_question).permit(:content, answers_attributes: [:id, :content, :correct])
      end
    end
  end
end
