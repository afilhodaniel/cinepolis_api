module Api
  module V2
    class UsersController < BaseController
      skip_before_action :verify_access_token, only: [:create]
      skip_before_action :set_parser, only: [:index]

      private

        def user_params
          params.require(:user).permit(:name, :email, :password, :facebook_id, :facebook_access_token)
        end
        
        def query_params
          params.permit(:id, :access_token)
        end

    end
  end
end