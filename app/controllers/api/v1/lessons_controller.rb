module Api
  module V1
    class LessonsController < ApplicationController
      before_action :authorize_teacher, only: [:create, :update, :destroy]
      before_action :set_lesson, only: [:show, :destroy, :update]

      # GET /api/v1/lessons
      def index
        @lessons = Lesson.all
        render json: @lessons
      end

      # GET /api/v1/lessons/:id
        def show
  lesson = Lesson.includes(:media_items, :text_question_sets).find(params[:id])

  # Get the latest media_item (if any)
  latest_media_item = lesson.media_items.order(created_at: :desc).first

  # Get the latest text_question_set (if any)
  latest_text_question_set = lesson.text_question_sets.order(created_at: :desc).first

  # Assemble the response JSON from the lesson attributes
  response = lesson.as_json

  # Format the latest media_item as an object
  if latest_media_item
    response['media_item'] = {
      id: latest_media_item.id,
      media_type: latest_media_item.media_type,
      media_link: latest_media_item.media_link,
      translations: latest_media_item.translations.map { |translation| translation.array_of_objects },
      multiple_questions: latest_media_item.multiple_questions.map do |question|
        {
          id: question.id,
          content: question.content,
          answers: question.answers.map do |answer|
            {
              id: answer.id,
              content: answer.content,
              correct: answer.correct
              # Include other attributes you want from answers
            }
          end
        }
      end
    }
  else
    response['media_item'] = {}
  end

  # Format the latest text_question_set as an object
  if latest_text_question_set
    response['text_question_set'] = {
      id: latest_text_question_set.id,
      text: latest_text_question_set.text,
      questions: latest_text_question_set.questions.map do |question|
        {
          id: question.id,
          text: question.text
          # Include other attributes you want from questions
        }
      end
    }
  else
    response['text_question_set'] = {}
  end

  # Render the modified response JSON
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
  @lesson = Lesson.find_by(id: params[:id])

  if @lesson
    ActiveRecord::Base.transaction do
      # Delete associated media items
      @lesson.media_items.destroy_all

      # Delete associated text question sets
      @lesson.text_question_sets.destroy_all

      # Delete the lesson
      @lesson.destroy

      # Commit the transaction
      ActiveRecord::Base.connection.commit_db_transaction
    end

    render json: { message: "Lesson and associated records deleted successfully" }, status: :ok
  else
    render json: { error: "Lesson not found" }, status: :not_found
  end
rescue ActiveRecord::RecordNotDestroyed => e
  render json: { error: "Failed to delete lesson and associated records: #{e.message}" }, status: :unprocessable_entity
end





      private

      def authorize_teacher
        unless current_user&.teacher?
          render json: { error: 'Unauthorized. Only teachers can create lessons.' }, status: :unauthorized
        end
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_lesson
        @lesson = Lesson.find_by(id: params[:id])
        render json: { error: 'Lesson not found' }, status: :not_found unless @lesson
      end


      # Only allow a trusted parameter "white list" through.
      def lesson_params
        params.require(:lesson).permit(:index, :title, :description, :completed, :score)
      end
    end
  end
end
