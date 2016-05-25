module Api
  module V2
    class UsersController < BaseController

      private

        def user_params
          params.require(:user).permit(:name, :email, :password)
        end
        
    end
  end
end