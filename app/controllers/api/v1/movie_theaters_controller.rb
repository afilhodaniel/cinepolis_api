module Api
  module V1
    class MovieTheatersController < BaseController
      skip_before_action :set_resource

      def index
        @movie_theaters = parse_movie_theaters()
      end

      def show
        @movie_theater = parse_movie_theater(params[:id])
      end

      private

        def movie_theater_params
          params.require(:movie_theater)
        end

        # For index action
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

        # For index action
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
                  },
                  url: "#{request.protocol}#{request.host}:#{request.port}#{api_v1_movie_theater_path(option.attr('value'), format: :json)}"
                }

                movie_theaters << movie_theater
              end
            end
          end

          return movie_theaters
        end

        # For show action
        def parse_movie_theater(movie_theater_id)
          html = Nokogiri::HTML(open("http://www.cinepolis.com.br/programacao/cinema.php?cc=#{movie_theater_id}"))

          movie_theater = {
            name: html.css('.titulo .amarelo')[0].text,
            city: html.css('.titulo .cinza .esquerda')[0].text,
            weeks: []
          }

          weeks = []

          html.css('.tabs3 .tabNavigation li').each do |item|
            sessions = []

            week = {
              from: item.css('a')[0].text.split(' à ')[0],
              to: item.css('a')[0].text.split(' à ')[1],
              sessions: []
            }

            html.css("#{item.css('a')[0].attr('href')} tr").each do |line|
              if line.attr('bgcolor') == '#990000'
                movie_id = line.css('td')[1].css('a').last.attr('href').to_s.split('?cf=')[1].to_s.split('&cc=')[0]
                subtitled = line.css('td')[4].text.include?('Leg') ? true : false
                dubbed = line.css('td')[4].text.include?('Dub') ? true : false

                hours = []

                line.css('td')[4].text.split(',').each do |option|
                  hours << option.gsub(/[Leg,Dub,-,.,A]/, '').gsub('-', '').gsub(' ', '')
                end


                session = {
                  room: line.css('td')[0].text,
                  movie: {
                    name: line.css('td')[1].text,
                    url: "#{request.protocol}#{request.host}:#{request.port}#{api_v1_movie_path(movie_id.to_i, format: :json)}",
                    pg: line.css('td')[2].css('img')[0] ? line.css('td')[2].css('img')[0].attr('title').gsub(' anos', '') : false,
                    subtitled: subtitled,
                    dubbed: dubbed
                  },
                  hours: hours
                }

                sessions << session
              end
            end

            week[:sessions] = sessions

            weeks << week
          end

          movie_theater[:weeks] = weeks

          return movie_theater
        end
        
    end
  end
end