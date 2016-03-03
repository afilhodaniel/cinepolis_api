module Api
  module V1
    class MoviesController < BaseController
      skip_before_action :set_resource

      def index
        @movies = @parser.get_movies
      end

      def show
        movie = @parser.get_movie(params[:id])

        unless movie
          @errors = {
            movie: 'Movie doesn\'t exists'
          }

          respond_to do |format|
            format.json { render :error }
          end
        else
          @movie = movie
        end
      end

      private
      
        def movie_params
          params.require(:movie)
        end

    end
  end
end