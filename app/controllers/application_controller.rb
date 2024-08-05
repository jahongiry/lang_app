class ApplicationController < ActionController::API
  before_action :authenticate_request, unless: :signup_or_login_request?

  private

  def authenticate_request
    token = request.headers['Authorization']&.split(' ')&.last
    Rails.logger.info("Token: #{token}") # Add logging

    if token.nil?
      render json: { error: 'Token missing' }, status: :unauthorized
      return
    end

    begin
      secret_key_base = Rails.application.credentials.secret_key_base
      Rails.logger.info("Secret Key: #{secret_key_base}") # Add logging
      decoded_token = JWT.decode(token, secret_key_base, true, { algorithm: 'HS256' })
      Rails.logger.info("Decoded Token: #{decoded_token}") # Add logging
      @current_user = User.find(decoded_token[0]['user_id'])
    rescue JWT::ExpiredSignature
      render json: { error: 'Token has expired' }, status: :unauthorized
    rescue JWT::DecodeError => e
      Rails.logger.error("JWT Decode Error: #{e.message}") # Add logging
      render json: { error: 'Invalid token' }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    rescue => e
      Rails.logger.error("General Error: #{e.message}") # Add logging for other errors
      render json: { error: e.message }, status: :unauthorized
    end
  end

  def signup_or_login_request?
    signup_request? || login_request?
  end

  def signup_request?
    params[:controller] == 'api/v1/users' && params[:action] == 'create'
  end

  def login_request?
    params[:controller] == 'api/v1/sessions' && params[:action] == 'create'
  end

  def current_user
    @current_user
  end
end
