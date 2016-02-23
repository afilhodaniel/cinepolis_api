module Api
  module V1
    class MoviesController < BaseController
      skip_before_action :force_authentication, only: [:create]

      def index
        @movies = parse_movies()
      end

      private

        def movie_params
          params.require(:movie)
        end

        def parse_movies
          html = Nokogiri::HTML(open('http://www.cinepolis.com.br/'))

          movies = []

          html.css('select[name=cf] option').each_with_index do |option, index|
            if index != 0
              movie = {
                id: option.attr('value'),
                name: option.text
              }

              movies << movie
            end
          end

          return movies
        end
        
    end
  end
end