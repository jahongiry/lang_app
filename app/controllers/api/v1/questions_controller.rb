module Api
  module V1
    class QuestionsController < ApplicationController
      before_action :set_question, only: [:show, :update, :destroy]

      # GET /api/v1/questions
      def index
        @questions = Question.all
        render json: @questions
      end

      # GET /api/v1/questions/:id
      def show
        render json: @question
      end

      # POST /api/v1/questions
      def create
        @question = Question.new(question_params)

        if @question.save
          render json: @question, status: :created
        else
          render json: @question.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/questions/:id
      def update
        if @question.update(question_params)
          render json: @question
        else
          render json: @question.errors, status: :unprocessable_entity
        end
      end

# DELETE /api/v1/questions/:id
def destroy
  @question.user_answers.destroy_all  # Add this line to delete all associated answers
  @question.destroy
  head :no_content
end


      private

      def set_question
        @question = Question.find(params[:id])
      end

      def question_params
        params.require(:question).permit(:text, :text_question_set_id)
      end
    end
  end
end
