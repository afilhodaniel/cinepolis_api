module Api
  module V2
    class MoviesController < BaseController
      skip_before_action :set_resource

      def show
        @movie = @parser.get_movie(params[:id], params[:city_id], params[:movie_theater_name])

        return @movie
      end

      private

        def query_params
          params.permit(:id, :city_id, :movie_theater_name, :access_token)
        end
        
    end
  end
end