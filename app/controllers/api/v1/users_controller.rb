module Api
  module V1
    class UsersController < BaseController
      skip_before_action :force_authentication, only: [:create]

      private

        def user_params
          params.require(:user).permit(:avatar, :name, :bio, :username, :email, :password)
        end
        
    end
  end
end