module Api
  module V1
    class UserAnswersController < ApplicationController
      before_action :set_user_answer, only: [:show, :update, :destroy]

    # GET /api/v1/user_answers/user_scores
      def user_scores
        # Fetch all user answers for the current user along with their feedbacks
        user_answers = UserAnswer.includes(:answer_feedbacks).where(user_id: current_user.id)

        # Extract scores from feedbacks
        scores = user_answers.flat_map { |ua| ua.answer_feedbacks.map(&:score) }

        # Calculate the average score
        average_score = scores.empty? ? 0 : scores.sum.to_f / scores.size

        # Return scores and the average score
        render json: { scores: scores, average_score: average_score }
      end

      # POST /api/v1/user_answers
      def create
        @user_answer = current_user.user_answers.build(user_answer_params)

        if @user_answer.save
          question = Question.find(@user_answer.question_id)
          evaluation = evaluate_english(question, @user_answer)

          # Save feedback and score to the database
          save_feedback_to_database(question, @user_answer, evaluation)

          render json: { user_answer: @user_answer, evaluation: evaluation }, status: :created
        else
          render json: @user_answer.errors, status: :unprocessable_entity
        end
      end

      private

      def evaluate_english(question, user_answer)
        api_key = ENV['GPT_TOKEN']
        open_ai_service = OpenAIService.new(api_key)
        response = open_ai_service.evaluate_english(question.text, user_answer.text)
        Rails.logger.info "OpenAI API response: #{response.inspect}"
        response
      end

      def user_answer_params
        params.require(:user_answer).permit(:text, :question_id)
      end
      
      def save_feedback_to_database(question, user_answer, evaluation)
        user_answer.answer_feedbacks.build(score: evaluation[:score], comment: evaluation[:feedback])
        user_answer.save
      end

      class OpenAIService
        include HTTParty
        base_uri 'https://api.openai.com/v1'

        def initialize(api_key)
          @options = {
            headers: {
              "Content-Type" => "application/json",
              "Authorization" => "Bearer #{api_key}"
            }
          }
        end

        def evaluate_english(question_text, answer_text)
          body = {
            model: "gpt-4",
            messages: [
              { role: "system", content: "Here is a user's answer to a specific question. Please analyze the answer for its relevance and correctness in relation to the question." },
              { role: "system", content: "Question: #{question_text}" },
              { role: "user", content: "#{answer_text}" },
              { role: "system", content: "Is the above answer relevant and correct in the context of the question? Please explain your reasoning." }
            ],
            max_tokens: 250
          }.to_json

          response = self.class.post("/chat/completions", body: body, **@options)
          if response.success?
            evaluate_score(response.parsed_response)
          else
            Rails.logger.error "OpenAI API Error: #{response.code} - #{response.body}"
            { score: 0, feedback: "Error processing the answer." }
          end
        end

        private

        def evaluate_score(ai_response)
          content = ai_response["choices"][0]["message"]["content"]
          score = interpret_content(content)
          { score: score, feedback: content }
        end

        def interpret_content(content)
          if negative_feedback?(content)
            rand(1..40) # Low scores for incorrect relevance or correctness
          elsif positive_feedback?(content)
            70 + rand(31) # High scores for relevant and correct answers
          else
            10 + rand(50) # Mid-range scores for ambiguous or unclear feedback
          end
        end

        def positive_feedback?(content)
          content.include?("correct") || content.include?("excellent") || content.include?("relevant")
        end

        def negative_feedback?(content)
          content.include?("not relevant") || content.include?("incorrect") || content.include?("not correct")
        end
      end
    end
  end
end
