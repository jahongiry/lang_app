module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy, :lesson_details]
      before_action :authorize_teacher!, only: [:destroy]

      # GET /api/v1/users
      def index
        @users = User.all
        render json: @users
      end

      # GET /api/v1/users/:id
      def show
        render json: @user
      end

      # POST /api/v1/users
      def create
        @user = User.new(user_params)

        if @user.save
          token = generate_token(@user.id) # Generate JWT token
          render json: { user: @user, token: token }, status: :created # Return token in response
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

    # DELETE /api/v1/users/:id
      def destroy
        @user.destroy
        render json: { message: 'User deleted successfully' }, status: :ok
      end


            # GET /api/v1/users/:id/lessons/:lesson_id/details
def lesson_details
  lesson = Lesson.find_by(id: params[:lesson_id])
  if lesson.nil?
    render json: { error: 'Lesson not found' }, status: :not_found
  else
    results_percentage = lesson.calculate_results(@user)  # Existing result calculation

    # Fetch all user answers related to the lesson through question sets
    user_answers = UserAnswer.includes(:question, :answer_feedback)
                             .where(user_id: @user.id)
                             .where(questions: { text_question_set_id: lesson.text_question_sets.select(:id) })

    # Format the answers for the response
    formatted_answers = user_answers.map do |answer|
      {
        question_id: answer.question_id,
        question_text: answer.question.text,
        user_answer_text: answer.text,
        correct: answer.correct,
        feedback: answer.answer_feedback&.comment,
        feedback_score: answer.answer_feedback&.score
      }
    end

    render json: {
      user: @user,
      lesson: {
        title: lesson.title,
        description: lesson.description,
        test_results: results_percentage,
        essay_answer: formatted_answers
      }
    }
  end
end


      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:email, :password, :name, :surname)
      end

      def generate_token(user_id)
        secret_key_base = Rails.application.credentials.secret_key_base
        JWT.encode({ user_id: user_id }, secret_key_base)
      end

      def authorize_teacher!
        unless current_user&.teacher? || @user == current_user
          render json: { error: 'Unauthorized' }, status: :unauthorized
      end
      end
    end
  end
end
