module Api
  module V1
    class MovieTheatersController < BaseController
      skip_before_action :force_authentication, only: [:create]

      def index
        @movie_theaters = parse_movie_theaters()
      end

      private

        def movie_theater_params
          params.require(:movie_theater)
        end

        def parse_cities
          html = Nokogiri::HTML(open('http://www.cinepolis.com.br/'))

          cities = []

          html.css('select[name=CIDADE] option').each do |option|
            if option.attr('value') != '0'
              city = {
                id: option.attr('value'),
                name: option.text
              }

              cities << city
            end
          end

          return cities
        end

        def parse_movie_theaters
          url = 'http://www.cinepolis.com.br/includes/getCinema.php'

          movie_theaters = []

          parse_cities().each do |city|
            response = HTTParty.post(url, {
              body: {
                cidade: city[:id]
              }
            })

            html = Nokogiri::HTML(response)

            html.css('option').each do |option|
              if option.attr('value') != '0'
                movie_theater = {
                  id: option.attr('value'),
                  name: option.text,
                  city: {
                    id: city[:id],
                    name: city[:name]
                  }
                }

                movie_theaters << movie_theater
              end
            end
          end

          return movie_theaters
        end
        
    end
  end
end