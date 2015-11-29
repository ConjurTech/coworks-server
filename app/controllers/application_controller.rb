class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def test
    render json: { message: 'ok' }
  end

  def not_found
    respond_to do |format|
      format.html { render file: File.join(Rails.root, 'public', '404.html') }
      format.json { render json: { errors: ['Not Found'] }, status: :not_found }
    end
  end
end
