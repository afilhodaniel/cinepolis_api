module Api
  module V2
    class UsersController < BaseController
      skip_before_action :verify_access_token, only: [:create]

      private

        def user_params
          params.require(:user).permit(:name, :email, :password)
        end
        
    end
  end
end