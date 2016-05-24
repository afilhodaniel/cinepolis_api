module Api
  module V1
    class UsersController < BaseController

      private

        def user_params
          params.require(:user).permit(:name, :email, :password)
        end
        
    end
  end
end