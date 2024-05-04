module Api
  module V1
    class LessonsController < ApplicationController
      before_action :authorize_teacher, only: [:create, :update, :destroy]
      before_action :set_lesson, only: [:show, :destroy, :update]

      # GET /api/v1/lessons
      def index
        lessons = Lesson.includes(:media_items, text_question_sets: :questions).all

        response = lessons.map do |lesson|
          lesson_data = lesson.as_json(include: {
            media_items: { 
              include: { multiple_questions: { include: :answers } }
            }, 
            text_question_sets: {
              include: { 
                questions: {
                  only: [:id, :text]
                }
              }
            }
          })

          # Sort and take the latest media item
          latest_media_item = lesson.media_items.order(updated_at: :desc).first

          # Check if latest_media_item exists before processing
          if latest_media_item
            latest_media_item_data = latest_media_item.as_json(include: {
              multiple_questions: {
                include: :answers
              }
            })
            lesson_data['media_items'] = latest_media_item_data

            # Handling multiple_question_ids with check on latest_media_item
            multiple_question_ids = [latest_media_item.id]  # Access ID directly

            test_results = TestResult.where(user_id: current_user.id, multiple_question_id: multiple_question_ids)
            user_answers = UserAnswer.where(user_id: current_user.id, question_id: lesson.text_question_sets.flat_map(&:question_ids))

            lesson_data['test_results'] = test_results.map do |result|
              {
                multiple_question_id: result.multiple_question_id,
                correct_percentage: result.correct_percentage,
                wrong_percentage: result.wrong_percentage
              }
            end

            lesson_data['user_answers_scores'] = user_answers.includes(:answer_feedbacks).map do |answer|
              {
                question_id: answer.question_id,
                score: answer.answer_feedbacks.sum(&:score),
                comments: answer.answer_feedbacks.map(&:comment)
              }
            end
          else
            lesson_data['media_items'] = {}  # Provide default empty hash if no media items
          end

          lesson_data
        end

        render json: response
      end

      # GET /api/v1/lessons/:id
      def show
        lesson = Lesson.includes(media_items: { multiple_questions: :answers }, text_question_sets: :questions).find_by(id: params[:id])

        unless lesson
          render json: { error: 'Lesson not found' }, status: :not_found
          return
        end

        response = lesson.as_json(include: { 
          text_question_sets: {
            include: { 
              questions: {
                only: [:id, :text]
              }
            }
          }
        })

        latest_media_item = lesson.media_items.order(updated_at: :desc).first
        if latest_media_item
          response['media_items'] = latest_media_item.as_json(include: {
            multiple_questions: {
              include: :answers
            }
          })
        else
          response['media_items'] = {}  # Handle case when there is no latest media item
        end

        render json: response
      end

      # POST /api/v1/lessons
      def create
        @lesson = current_user.lessons.build(lesson_params)

        if @lesson.save
          render json: @lesson, status: :created
        else
          render json: @lesson.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/lessons/:id
      def update
        if @lesson.update(lesson_params)
          render json: @lesson
        else
          render json: @lesson.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/lessons/:id
      def destroy
        if @lesson.destroy
          render json: { message: "Lesson and associated records deleted successfully" }, status: :ok
        else
          render json: { error: "Failed to delete lesson and associated records" }, status: :unprocessable_entity
        end
      end

      private

      def authorize_teacher
        unless current_user&.teacher?
          render json: { error: 'Unauthorized. Only teachers can create, update, or destroy lessons.' }, status: :unauthorized
        end
      end

      def set_lesson
        @lesson = Lesson.find_by(id: params[:id])
        render json: { error: 'Lesson not found' }, status: :not_found unless @lesson
      end

      def lesson_params
        params.require(:lesson).permit(:index, :title, :description, :completed, :score)
      end
    end
  end
end