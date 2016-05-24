class MovieTheatersParser < BaseParser

  def get_movie_theaters
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
          city_name = city[:name].split('-')[0].strip
          state_uf = city[:name].split('-')[1].strip

          movie_theater = {
            id: option.attr('value'),
            name: option.text,
            url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_movie_theater_path(option.attr('value'), format: :json)}",
            city: {
              id: city[:id],
              name: city_name,
              url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_city_path(city[:id], format: :json)}",
              state: {
                uf: state_uf,
                name: State::UFS[state_uf.to_sym],
                url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_state_path(state_uf.downcase, format: :json)}"
              }
            }
          }

          movie_theaters << movie_theater
        end
      end
    end

    return movie_theaters
  end

  def get_movie_theater(movie_theater_id)
    html = Nokogiri::HTML(open("http://www.cinepolis.com.br/programacao/cinema.php?cc=#{movie_theater_id}"))

    unless html.css('.titulo .cinza .esquerda')[0].text.split('-')[0]
      return false
    end

    movie_theater = {
      id: movie_theater_id,
      name: html.css('.titulo .amarelo')[0].text,
      city: {
        name: html.css('.titulo .cinza .esquerda')[0].text.split('-')[0].strip,
        state: {
          uf: html.css('.titulo .cinza .esquerda')[0].text.split('-')[1].strip,
          name: State::UFS[html.css('.titulo .cinza .esquerda')[0].text.split('-')[1].strip.to_sym],
          url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_state_path(html.css('.titulo .cinza .esquerda')[0].text.split('-')[1].strip.downcase, format: :json)}"
        }
      },
      weeks: [],
      prices: []
    }

    weeks = []

    html.css('.tabs3 .tabNavigation li').each do |item|
      sessions = []

      week = {
        from: item.css('a')[0].text.split(' à ')[0],
        to: item.css('a')[0].text.split(' à ')[1],
        sessions: []
      }

      legs = html.css("#{item.css('a')[0].attr('href')} .tabelahorarios tfoot tr td[class=ft10]")[0].text.split('-')

      leg_a = legs.size >= 2 ? " - #{legs[1].gsub('B', '').strip}" : nil
      leg_b = legs.size >= 3 ? " - #{legs[2].gsub('C', '').strip}" : nil
      leg_c = legs.size >= 4 ? " - #{legs[3].gsub('D', '').strip}" : nil
      leg_d = legs.size >= 5 ? " - #{legs[4].gsub('E', '').strip}" : nil
      leg_e = legs.size >= 6 ? " - #{legs[5].gsub('F', '').strip}" : nil
      leg_f = legs.size >= 7 ? " - #{legs[6].gsub('G', '').strip}" : nil
      leg_g = legs.size >= 8 ? " - #{legs[7].gsub('H', '').strip}" : nil
      leg_h = legs.size >= 9 ? " - #{legs[8].gsub('I', '').strip}" : nil
      leg_i = legs.size >= 10 ? " - #{legs[9].gsub('J', '').strip}" : nil
      leg_j = legs.size >= 11 ? " - #{legs[10].gsub('L', '').strip}" : nil

      html.css("#{item.css('a')[0].attr('href')} tr").each do |line|
        if line.attr('bgcolor') == '#990000'
          movie_id = line.css('td')[1].css('a').last.attr('href').to_s.split('?cf=')[1].to_s.split('&cc=')[0]
          subtitled = line.css('td')[4].text.include?('Leg') ? true : false
          dubbed = line.css('td')[4].text.include?('Dub') ? true : false
          vip = line.css('.icovip')[0] ? true : false
          macroxe = line.css('.icomacroxe')[0] ? true : false
          i3d = line.css('.ico3d')[0] ? true : false
          i4dx = line.css('.ico4dx')[0] ? true : false
          i2d = line.css('.ico2d')[0] ? true : false
          imax = line.css('.icoimax')[0] ? true : false
          cocacola4dx = line.css('.ico4dxcoca')[0] ? true : false
          santander = line.css('.icoSantander')[0] ? true : false

          hours = []

          line.css('td')[4].text.split(',').each do |option|
            option = option.gsub('Leg', '').gsub('Dub', '').gsub(/[\.-]/, '').strip
            
            option = option.gsub('A', leg_a) if leg_a
            option = option.gsub('B', leg_b) if leg_b
            option = option.gsub('C', leg_c) if leg_c
            option = option.gsub('D', leg_d) if leg_d
            option = option.gsub('E', leg_e) if leg_e
            option = option.gsub('F', leg_f) if leg_f
            option = option.gsub('G', leg_g) if leg_g
            option = option.gsub('H', leg_h) if leg_h
            option = option.gsub('I', leg_i) if leg_i
            option = option.gsub('J', leg_j) if leg_j

            hours << option
          end

          session = {
            room: line.css('td')[0].text,
            movie: {
              name: line.css('td')[1].text,
              url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_movie_path(movie_id.to_i, format: :json)}",
              pg: line.css('td')[2].css('img')[0] ? line.css('td')[2].css('img')[0].attr('title').gsub(' anos', '') : false,
              subtitled: subtitled,
              dubbed: dubbed
            },
            macroxe: macroxe,
            vip: vip,
            '3d': i3d,
            '4dx': i4dx,
            '2d': i2d,
            imax: imax,
            cocacola4dx: cocacola4dx,
            santander: santander,
            hours: hours
          }

          sessions << session
        end
      end

      week[:sessions] = sessions

      weeks << week
    end

    prices = []

    html.css('#abaprc').to_s.split('<br>').each do |price|
      price = price.gsub("<div id=\"abaprc\" class=\"contaba clearfix\">", '')
      price = price.gsub('<i>', '').gsub('</i>', '')
      price = price[0, price.index("<div class=\"linha2\"></div>")] if price.include?("<div class=\"linha2\"></div>")

      prices << price.strip
    end

    movie_theater[:weeks] = weeks
    movie_theater[:prices] = prices
    movie_theater[:movies] = get_movies(movie_theater[:id])

    return movie_theater
  end

  def get_movies(movie_theater_id)
    url = 'http://www.cinepolis.com.br/includes/getFilme.php'

    movies = []

    response = HTTParty.post(url, {
      body: {
        type: 1,
        cinema: movie_theater_id
      }
    })

    html = Nokogiri::HTML(response)

    html.css('option').each do |option|
      if option.attr('value') != '0'
        movie = {
          id: option.attr('value'),
          name: option.text
        }

        movies << movie
      end
    end

    return movies.sort_by {|movie| movie[:name]}
  end

  private 

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

end