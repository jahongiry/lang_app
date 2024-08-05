Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users do
        member do
                get 'lessons/:lesson_id/details', to: 'users#lesson_details'
                post 'add_teacher_role', to: 'users#add_teacher_role'
                delete 'remove_teacher_role', to: 'users#remove_teacher_role'
              end
      end

      resources :lessons do
        member do
          post 'reset_score', to: 'lessons#reset_score'
          get 'student_results', to: 'lessons#student_results'
        end
        resources :text_question_sets
        resources :questions
        resources :media_items, only: [:index, :show, :create, :update, :destroy] do
          resources :translations, only: [:index, :show, :create, :update, :destroy]
          resources :multiple_questions, only: [:index, :show, :create, :update, :destroy] do
            resources :answers, only: [:index, :show, :create, :update, :destroy]
            resources :test_results, only: [:index, :show]
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

      post '/answers', to: 'answers#create'
    end
  end
end
