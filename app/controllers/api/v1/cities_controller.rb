module Api
  module V1
    class CitiesController < BaseController
      skip_before_action :force_authentication, only: [:create]

      def index
        @cities = parse_cities()
      end

      private

        def city_params
          params.require(:movie_theater)
        end

        def parse_cities
          html = Nokogiri::HTML(open('http://www.cinepolis.com.br/'))

          cities = []

          html.css('select[name=CIDADE] option').each do |option|
            if option.attr('value') != '0'
              city = {
                id: option.attr('value'),
                name: option.text,
                movie_theaters: parse_movie_theaters(option.attr('value'))
              }

              cities << city
            end
          end

          return cities
        end

        def parse_movie_theaters(city_id)
          url = 'http://www.cinepolis.com.br/includes/getCinema.php'

          movie_theaters = []

          response = HTTParty.post(url, {
            body: {
              cidade: city_id
            }
          })

          html = Nokogiri::HTML(response)

          html.css('option').each do |option|
            if option.attr('value') != '0'
              movie_theater = {
                id: option.attr('value'),
                name: option.text,
                url: "#{request.protocol}#{request.host}:#{request.port}#{api_v1_movie_theater_path(option.attr('value'), format: :json)}"
              }

              movie_theaters << movie_theater
            end
          end

          return movie_theaters
        end
        
    end
  end
end