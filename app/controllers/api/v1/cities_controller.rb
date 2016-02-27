module Api
  module V1
    class CitiesController < BaseController
      skip_before_action :set_resource
      
      def index
        @cities = parse_cities()
      end

      def show
        city = parse_city(params[:id])

        unless city
          @errors = {
            city: 'City doesn\'t exists'
          }

          respond_to do |format|
            format.json { render :error }
          end
        else
          @city = city
        end
      end

      private

        def city_params
          params.require(:city)
        end

        def parse_cities
          html = Nokogiri::HTML(open('http://www.cinepolis.com.br/'))

          cities = []

          html.css('select[name=CIDADE] option').each do |option|
            if option.attr('value') != '0'
              city = {
                id: option.attr('value'),
                name: option.text.split('-')[0].strip,
                url: "#{request.protocol}#{request.host}:#{request.port}#{api_v1_city_path(option.attr('value'), format: :json)}",
                state: {
                  uf: option.text.split('-')[1].strip,
                  name: State::UFS[option.text.split('-')[1].strip.to_sym],
                  url: "#{request.protocol}#{request.host}:#{request.port}#{api_v1_state_path(option.text.split('-')[1].strip.downcase, format: :json)}"
                },
                movie_theaters: parse_movie_theaters(option.attr('value'))
              }

              cities << city
            end
          end

          return cities
        end

        def parse_city(city_id)
          response = HTTParty.post('http://www.cinepolis.com.br/includes/getCinema.php', {
            body: {
              cidade: city_id
            }
          })

          html = Nokogiri::HTML(response.body)
          cityHtml = Nokogiri::HTML(open("http://www.cinepolis.com.br/"))

          unless cityHtml.css("option[value='#{city_id}']")[0]
            return false
          end

          city = {
            id: city_id,
            name: cityHtml.css("option[value='#{city_id}']")[0].text.split('-')[0].strip,
            url: "#{request.protocol}#{request.host}:#{request.port}#{api_v1_city_path(city_id, format: :json)}",
            state: {
              uf: cityHtml.css("option[value='#{city_id}']")[0].text.split('-')[1].strip,
              name: State::UFS[cityHtml.css("option[value='#{city_id}']")[0].text.split('-')[1].strip.to_sym],
              url: "#{request.protocol}#{request.host}:#{request.port}#{api_v1_state_path(cityHtml.css("option[value='#{city_id}']")[0].text.split('-')[1].strip.downcase, format: :json)}"
            },
            movie_theaters: []
          }

          movie_theaters = []

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

          city[:movie_theaters] = movie_theaters

          return city
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