class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # before_action :force_authentication, except: [:index]

  def index
    render :index
  end

  private

    def force_authentication
      if !is_authenticated
        redirect_to sessions_unauthenticated_path
      end
    end

    def is_authenticated
      if session[:current_user_id]
        return true
      else
        return false
      end
    end

    def set_current_user
      if is_authenticated
        @current_user = User.where(id: session[:current_user_id]).first
      else
        @current_user = nil
      end
    end
end
