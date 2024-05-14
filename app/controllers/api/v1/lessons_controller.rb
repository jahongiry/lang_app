module Api
module V1
class LessonsController < ApplicationController
      before_action :authorize_teacher, only: [:create, :update, :destroy, :reset_score]
      before_action :set_lesson, only: [:show, :destroy, :update, :reset_score]


    # POST /api/v1/lessons/:id/reset_score
      def reset_score
        user_id = params[:user_id]

        # Find user lesson
        user_lesson = UserLesson.find_by(user_id: user_id, lesson_id: @lesson.id)

        # Find user answers related to the lesson's text question sets
        user_answers = UserAnswer.joins(question: { text_question_set: :lesson })
                                 .where(lessons: { id: @lesson.id })
                                 .where(user_id: user_id)

        # Find test results related to the lesson's multiple questions
        test_results = TestResult.joins(multiple_question: :media_item)
                                 .where(media_items: { lesson_id: @lesson.id })
                                 .where(user_id: user_id)

        # Begin a transaction to ensure atomicity
        ActiveRecord::Base.transaction do
          # Delete answer feedbacks associated with the user answers
          AnswerFeedback.where(user_answer_id: user_answers.pluck(:id)).destroy_all

          # Delete the user answers
          user_answers.destroy_all

          # Delete the test results
          test_results.destroy_all

          # Reset the user's lesson score and completion status
          if user_lesson
            user_lesson.update(score: 0, completed: false)
          end

          # Commit the transaction
          ActiveRecord::Base.connection.commit_db_transaction
        end

        render json: { message: "User answers, test results, and scores reset successfully" }, status: :ok

      rescue ActiveRecord::RecordNotDestroyed => e
        render json: { error: "Failed to reset user answers, test results, and scores: #{e.message}" }, status: :unprocessable_entity
      end

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
  lesson = Lesson.includes(media_items: { multiple_questions: :answers, translations: {} }, text_question_sets: { questions: {} }).find_by(id: params[:id])

  unless lesson
    render json: { error: 'Lesson not found' }, status: :not_found
    return
  end

  user_lesson = lesson.user_lessons.find_or_create_by(user_id: current_user.id)

  response = {
    id: lesson.id,
    title: lesson.title,
    description: lesson.description,
    score: user_lesson&.score || 0,
    completed: user_lesson&.completed || false
  }

  # Include only the latest media item and its translations
  latest_media_item = lesson.media_items.order(updated_at: :desc).first
  if latest_media_item
    response['media_items'] = latest_media_item.as_json(include: {
      multiple_questions: {
        include: :answers
      },
      translations: {}
    })
  else
    response['media_items'] = {} # Return an empty object if no media items are found
  end

  # Include only the latest text_question_set and its questions
  latest_text_question_set = lesson.text_question_sets.order(updated_at: :desc).first
  if latest_text_question_set
    response['text_question_sets'] = {
      id: latest_text_question_set.id,
      text: latest_text_question_set.text,
      questions: latest_text_question_set.questions.as_json(only: [:id, :text])
    }
  else
    response['text_question_sets'] = {} # Return an empty object if no text question sets are found
  end

  # Load test results and user answers specific to current user
  test_results = TestResult.where(user_id: current_user.id)
  user_answers = UserAnswer.where(user_id: current_user.id)

  response['test_results'] = test_results.map do |result|
    {
      multiple_question_id: result.multiple_question_id,
      correct_percentage: result.correct_percentage,
      wrong_percentage: result.wrong_percentage
    }
  end

  

  answer_feedback_scores = user_answers.includes(:answer_feedbacks).map do |answer|
    {
      question_id: answer.question_id,
      score: answer.answer_feedbacks.sum(&:score),
      comments: answer.answer_feedbacks.map(&:comment)
    }
  end


  # Calculate and append average score if there are scores
  scores = answer_feedback_scores.map { |afs| afs[:score] }
  average_score = scores.sum.to_f / scores.size if scores.any?
  response['user_answers_scores'] = answer_feedback_scores
  response['average_user_answer_score'] = average_score if average_score.present?

  # Calculate the overall score
  test_score = test_results.average(:correct_percentage) || 0
  if test_score > 0 && average_score && average_score > 0
    calculated_score = ((test_score + average_score) / 2.0).round(2)
    user_lesson.update(score: calculated_score)  # Update score
    response[:score] = calculated_score

    # Update 'completed' to true if score is more than 60 and it is not already marked as completed
    if calculated_score > 60 && !user_lesson.completed
      user_lesson.update(completed: true)
      response[:completed] = true
    end
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
ActiveRecord::Base.transaction do # Delete associated media items
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
