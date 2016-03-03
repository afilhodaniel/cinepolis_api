module Api
  module V1
    class MovieTheatersController < BaseController
      skip_before_action :set_resource

      def index
        @movie_theaters = @parser.get_movie_theaters()
      end

      def show
        movie_theater = @parser.get_movie_theater(params[:id])

        unless movie_theater
          @errors = {
            movie_theater: 'Movie theater doesn\'t exists'
          }

          respond_to do |format|
            format.json { render :error }
          end
        else
          @movie_theater = movie_theater
        end
      end

      private

        def movie_theater_params
          params.require(:movie_theater)
        end
        
    end
  end
end