class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index
    render :index
  end

  private

    def force_authenticattion
      if !is_authenticated
        redirect_to root_path
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
