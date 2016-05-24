class StatesParser < BaseParser

  def get_states
    html = Nokogiri::HTML(open("http://www.cinepolis.com.br/"))

    states = []

    html.css('select[name=CIDADE] option').each do |option|
      if option.attr('value') != '0'
        state = {
          uf: option.text.split('-')[1].strip,
          name: State::UFS[option.text.split('-')[1].strip.to_sym],
          url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_state_path(option.text.split('-')[1].strip.downcase, format: :json)}",
          cities: []
        }

        states << state unless states.include?(state)
      end
    end

    html.css('select[name=CIDADE] option').each do |option|
      if option.attr('value') != '0'
        uf = option.text.split('-')[1].strip
        city = option.text.split('-')[0].strip
        
        states.each do |state|
          if state[:uf] == uf
            city = {
              id: option.attr('value'),
              name: city,
              url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_city_path(option.attr('value'), format: :json)}",
              movie_theaters: []
            }

            city[:movie_theaters] << get_movie_theaters(city[:id])

            state[:cities] << city
          end
        end
      end
    end

    return states
  end

  def get_movie_theaters(city_id)
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
          url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_movie_theater_path(option.attr('value'), format: :json)}"
        }

        movie_theaters << movie_theater
      end
    end

    return movie_theaters
  end

end