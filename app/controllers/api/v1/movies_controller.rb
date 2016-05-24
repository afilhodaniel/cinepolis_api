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

          cities = []
          to_delete = []

          if query_params[:movie_theater_id]
            movie[:cities].each do |city|
              city[:city][:movie_theaters].each do |movie_theater|
                if movie_theater[:id] == query_params[:movie_theater_id]
                  cities << city
                else
                  to_delete << movie_theater
                end
              end
            end

            cities.each do |city|
              city[:city][:movie_theaters].each do |movie_theater|
                if to_delete.include?(movie_theater)
                  city[:city][:movie_theaters].delete(movie_theater)
                end
              end
            end

            @movie[:cities] = cities
          end
        end
      end

      private
      
        def movie_params
          params.require(:movie)
        end

        def query_params
          params.permit(:movie_theater_id)
        end

    end
  end
end