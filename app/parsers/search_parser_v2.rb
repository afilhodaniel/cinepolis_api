class SearchParserV2 < BaseParser

  def get_states
    url = "http://www.cinepolis.com.br/"

    response = HTTParty.get(url)

    html = Nokogiri::HTML(response.body)

    states = parse_states(html)
    states = parse_cities(states, html)

    return states
  end

  def parse_states(html = nil)
    states = []

    html.css('#CIDADE option').each do |option|
      if option.attr('value') != '0'
        state = {
          id: option.text.split('-')[1].strip,
          name: State::UFS[option.text.split('-')[1].strip.to_sym],
          cities: []
        }

        states << state unless states.include?(state)
      end
    end

    return states.sort_by {|state| state[:name]}
  end

  def parse_cities(states = nil, html = nil)
    states.each do |state|
      html.css('#CIDADE option').each do |option|
        if option.attr('value') != '0' and option.text.split('-')[1].strip == state[:id]
          city = {
            id: option.attr('value'),
            name: option.text.split('-')[0].strip
          }

          state[:cities] << city
        end
      end
    end

    states.each do |state|
      state[:cities].sort_by {|city| city[:name]}
    end

    return states
  end

  def parse_movie_theaters(city)
    url = "http://www.cinepolis.com.br/includes/getCinema.php"

    response = HTTParty.post(url, {
      body: {
        cidade: city[:id]
      }
    })

    html = Nokogiri::HTML(response.body)
      puts html


    movie_theaters = []

    html.css('option').each do |option|
      if option.attr('value') != '0'
        movie_theater = {
          id: option.attr('value'),
          name: option.text.strip
        }

        movie_theaters << movie_theater
      end
    end

    city[:movie_theaters] = movie_theaters

    return city
  end

  def parse_movies(movie_theater)
    url = "http://www.cinepolis.com.br/includes/getFilme.php"

    response = HTTParty.post(url, {
      body: {
        type: 1,
        cinema: movie_theater[:id]
      }
    })

    html = Nokogiri::HTML(response.body)

    movies = []

    html.css('option').each do |option|
      if option.attr('value') != '0'
        movie = {
          id: option.attr('value'),
          name: option.text.strip
        }

        movies << movie
      end
    end

    movie_theater[:movies] = movies

    return movie_theater
  end
  
end