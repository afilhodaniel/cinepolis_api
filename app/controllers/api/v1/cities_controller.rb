module Api
  module V1
    class CitiesController < BaseController
      skip_before_action :set_resource
      
      def index
        @cities = @parser.get_cities
      end

      def show
        city = @parser.get_city(params[:id])
        
        unless city
          @errors = {
            city: 'City doesn\'t exists'
          }

          respond_to do |format|
            format.json { render :error }
          end
        else
          @city = city

          movie_theaters_parser = MovieTheatersParser.new(request)

          @city[:movie_theaters].each do |movie_theater|
            movie_theater[:movies] = movie_theaters_parser.get_movies(movie_theater[:id])
          end
        end
      end

      private

        def city_params
          params.require(:city)
        end
        
    end
  end
end