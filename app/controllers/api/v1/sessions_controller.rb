module Api
  module V1
    class SessionsController < ApplicationController
      def create
        @user = User.find_by(email: params[:email])

        if @user && @user.valid_password?(params[:password])
          token = generate_token(@user.id)
          render json: { user: @user, token: token }
        else
          render json: { error: 'Invalid email/phone number or password' }, status: :unauthorized
        end
      end

      private

      def generate_token(user_id)
        secret_key_base = Rails.application.credentials.secret_key_base
        JWT.encode({ user_id: user_id }, secret_key_base)
      end
    end
  end
end