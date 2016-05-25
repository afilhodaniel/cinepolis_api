module Api
  module V2
    class SearchController < BaseController
      skip_before_action :set_resource

      def index
        @states = @parser.get_states

        if params[:state_id]
          @states = @states.select {|state| state[:id] == params[:state_id]}

          if params[:city_id]
            @states.each {|state| state[:cities] = state[:cities].select {|city| city[:id] == params[:city_id]}}
            
            @states.each {|state| state[:cities].each {|city| city = @parser.parse_movie_theaters(city)}}
            
            if params[:movie_theater_id]
              @states.each {|state| state[:cities].each {|city| city[:movie_theaters] = city[:movie_theaters].select{|movie_theater| movie_theater[:id] == params[:movie_theater_id]}}}

              @states.each {|state| state[:cities].each {|city| city[:movie_theaters].each {|movie_theater| movie_theater = @parser.parse_movies(movie_theater)}}}
            end
          end
        end

        return @states
      end

      private

        def query_params
          params.permit(:state_id, :city_id, :movie_theater_id, :movie_id, :access_token)
        end
        
    end
  end
end