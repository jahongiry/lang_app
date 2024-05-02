class ApplicationController < ActionController::API
  before_action :authenticate_request, unless: :signup_or_login_request?

  private

  def authenticate_request
    token = request.headers['Authorization']&.split(' ')&.last
    begin
      decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base)
      @current_user = User.find(decoded_token[0]['user_id'])
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
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