module Api
  module V1
    class TextQuestionSetsController < ApplicationController
      before_action :set_text_question_set, only: [:show, :update, :destroy]

      # GET /api/v1/text_question_sets
      def index
        @text_question_sets = TextQuestionSet.all
        render json: @text_question_sets
      end

      # GET /api/v1/text_question_sets/:id
      def show
        render json: @text_question_set, include: :questions
      end

      # POST /api/v1/text_question_sets
      def create
        @text_question_set = TextQuestionSet.new(text_question_set_params)

        if @text_question_set.save
          render json: @text_question_set, status: :created
        else
          render json: @text_question_set.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/text_question_sets/:id
      def update
        if @text_question_set.update(text_question_set_params)
          render json: @text_question_set
        else
          render json: @text_question_set.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/text_question_sets/:id
      def destroy
        @text_question_set.destroy
        head :no_content
      end

      private

      def set_text_question_set
        @text_question_set = TextQuestionSet.find(params[:id])
      end

      def text_question_set_params
        params.require(:text_question_set).permit(:text, :lesson_id)
      end
    end
  end
end
