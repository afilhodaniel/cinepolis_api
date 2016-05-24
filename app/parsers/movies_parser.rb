class MoviesParser < BaseParser

  def get_movies
    html = Nokogiri::HTML(open('http://www.cinepolis.com.br/'))

    movies = []

    html.css('select[name=cf] option').each_with_index do |option, index|
      if index != 0
        movie = {
          id: option.attr('value'),
          name: option.text,
          url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_movie_path(option.attr('value'), format: :json)}"
        }

        movies << movie
      end
    end

    return movies
  end

  def get_movie(movie_id)
    html = Nokogiri::HTML(open("http://www.cinepolis.com.br/programacao/busca.php?cf=#{movie_id}"))
    htmlTrailer = Nokogiri::HTML(open("http://www.cinepolis.com.br/trailers/trailer_modal.php?cfm=#{movie_id}"))

    if html.css('.linha2 .boxpreto1 .coluna1 img')[0] == nil
      return false
    end


    # Movie general info
    movie = {
      id: movie_id,
      image: html.css('.linha2 .boxpreto1 .coluna1 img')[0].attr('src'),
      trailer: "#{@request.protocol.gsub('//', '')}#{htmlTrailer.css('iframe').first.attr('src')}",
      name: html.css('.titulo h3').text,
      original_name: html.css('.titulo .cinza .esquerda').text.gsub(/[()]/, ''),
      pg: html.css('.titulo span img')[0].attr('title').gsub('Classificação:', '').gsub('ANOS', '').strip,
      sinopse: html.css('.linha2 .boxpreto1 .coluna2 p')[0].text.gsub('[saiba mais]', '').strip,
      cast: html.css('.linha2 .boxpreto1 .coluna2 p')[1].text.gsub(/[\r\n]/, '').gsub(',', ', '),
      director: html.css('.linha2 .boxpreto1 .coluna2 p')[2].text,
      cities: []
    }

    cities = []

    city_flag = ''
    movie_theater_flag = ''

    sessions = []
    movie_theaters = []

    html.css('.tabelahorarios tr').each do |line|
      if line.attr('class') != 'black'
        city_name = line.css('td')[1].text.gsub(' - ', '-').gsub(' -', '-').gsub('- ', '-')
        movie_theater_name = line.css('td')[0].text

        sessions = [] if movie_theater_flag != movie_theater_name
        movie_theaters = [] if city_flag != city_name

        movie_theater_id = line.css('td')[0].css('a').last.attr('href').split('?cc=')[1].split('&cf=')[0]
        subtitled = line.css('td')[3].text.include?('Leg') ? true : false
        dubbed = line.css('td')[3].text.include?('Dub') ? true : false
        macroxe = line.css('.icomacroxe')[0] ? true : false
        vip = line.css('.icovip')[0] ? true : false
        i4dx = line.css('.ico4dx')[0] ? true : false
        i2d = line.css('.ico2d')[0] ? true : false
        i3d = line.css('.ico3d')[0] ? true : false
        imax = line.css('.icoimax')[0] ? true : false
        cocacola4dx = line.css('.ico4dxcoca')[0] ? true : false
        santander = line.css('.icoSantander')[0] ? true : false
        
        hours = []

        if line.css('td')[3].css('.hint--top')[0]
          line.css('td')[3].text.gsub(/[LegDub.-]/, '').strip.split(',').each do |hour|
            hours << hour.sub(line.css('td')[3].css('.hint--top')[0].css('.hleter').text, " #{line.css('td')[3].css('.hint--top')[0].attr('data-hint')}").strip
          end
        else
          line.css('td')[3].text.gsub(/[LegDub.-]/, '').strip.split(',').each do |hour|
            hours << hour.strip
          end
        end

        session = {
          room: line.css('td')[2].text,
          subtitled: subtitled,
          dubbed: dubbed,
          macroxe: macroxe,
          vip: vip,
          '4dx': i4dx,
          '2d': i2d,
          '3d': i3d,
          imax: imax,
          cocacola4dx: cocacola4dx,
          santander: santander,
          hours:  hours
        }

        sessions << session

        movie_theater = {
          id: movie_theater_id,
          name: movie_theater_name,
          url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_movie_theater_path(movie_theater_id.to_i, format: :json)}",
          sessions: sessions
        }

        movie_theaters << movie_theater if movie_theater_flag != movie_theater_name

        city = {
          city: {
            name: city_name.split('-')[0].strip,
            state: {
              uf: city_name.split('-')[1].strip,
              name: State::UFS[city_name.split('-')[1].strip.to_sym],
              url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_state_path(city_name.split('-')[1].strip.downcase, format: :json)}"
            },
            movie_theaters: movie_theaters
          }
        }

        cities << city if city_flag != city_name

        city_flag = city_name
        movie_theater_flag = movie_theater_name
      end
    end

    movie[:cities] = cities

    return movie
  end

end