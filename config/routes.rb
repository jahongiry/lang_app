Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users do
        get 'lessons/:lesson_id/details', to: 'users#lesson_details', on: :member
      end

      resources :lessons do
        resources :text_question_sets
        resources :media_items, only: [:index, :show, :create, :update, :destroy] do
          resources :translations, only: [:index, :show, :create, :update, :destroy]
          resources :multiple_questions, only: [:index, :show, :create, :update, :destroy] do
            resources :answers, only: [:index, :show, :create, :update, :destroy]
          end
        end
      end

      resources :questions

      resources :user_answers do
        resource :answer_feedback, only: [:create, :update]
        collection do
          get 'user_scores', to: 'user_answers#user_scores'
        end
      end

      post '/login', to: 'sessions#create'

      # Adding specific routes for creating answers directly under a multiple_question
      namespace :media_items do
        namespace :multiple_questions do
          post '/:multiple_question_id/answers', to: 'answers#create'
        end
      end
    end
  end
end
