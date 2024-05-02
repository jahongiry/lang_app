module Api
  module V1
    class LessonsController < ApplicationController
      before_action :authorize_teacher, only: [:create, :update, :destroy]
      before_action :set_lesson, only: [:show, :destroy, :update]

# GET /api/v1/lessons
      def index
        # Fetch all lessons and include associated media_items to avoid N+1 queries
        lessons = Lesson.includes(:media_items).all

        lessons_data = lessons.map do |lesson|
          next unless lesson # Skip iteration if lesson is nil
          {
            id: lesson.id,
            title: lesson.title,
            description: lesson.description,
            media_items: lesson.media_items.map do |media_item|
              next unless media_item # Skip iteration if media_item is nil
              {
                id: media_item.id,
                lesson_id: media_item.lesson_id,
                media_type: media_item.media_type,
                media_link: media_item.media_link.present? ? url_for(media_item.media_link) : nil,
                created_at: media_item.created_at,
                updated_at: media_item.updated_at
              }
            end.compact # Removes nil entries from the media_items array
          }
        end.compact # Removes nil entries from the lessons array

        render json: lessons_data
      end




    # GET /api/v1/lessons/:id
def show
  lesson = Lesson.includes(media_items: {multiple_questions: :answers}, text_question_sets: :questions).find(params[:id])

  response = lesson.as_json(include: { 
    text_question_sets: {
      include: { 
        questions: {
          only: [:id, :text]
        }
      }
    }
  })

  # Include only the latest media item
  latest_media_item = lesson.media_items.order(updated_at: :desc).first
  response['media_items'] = latest_media_item.as_json(include: {
    multiple_questions: {
      include: :answers
    }
  })

  # Test results and scores
  test_results = TestResult.where(user_id: current_user.id, multiple_question_id: [latest_media_item].pluck(:id))
  user_answers = UserAnswer.where(user_id: current_user.id, question_id: lesson.text_question_sets.flat_map(&:question_ids))

  response['test_results'] = test_results.map do |result|
    {
      multiple_question_id: result.multiple_question_id,
      correct_percentage: result.correct_percentage,
      wrong_percentage: result.wrong_percentage
    }
  end

  response['user_answers_scores'] = user_answers.includes(:answer_feedbacks).map do |answer|
    {
      question_id: answer.question_id,
      score: answer.answer_feedbacks.sum(&:score),
      comments: answer.answer_feedbacks.map(&:comment)
    }
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
