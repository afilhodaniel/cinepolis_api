class MoviesParserV2 < BaseParser

  def get_movie(movie_id, city_id, movie_theater_name)
    url = "http://www.cinepolis.com.br/programacao/busca.php?cidade=#{city_id}&cf=#{movie_id}"

    response = HTTParty.get(url)

    html = Nokogiri::HTML(response.body)

    movie = parse_movie(movie_id, movie_theater_name, html)

    return movie
  end

  def parse_movie(movie_id = nil, movie_theater_name = nil, html = nil)
    movie = {
      id: movie_id,
      name: html.css('.titulo h3')[0].text,
      image: html.css('.linha2 .borda.boxpreto1.prog .coluna1 a img')[0].attr('src'),
      sinopse: html.css('.linha2 .borda.boxpreto1.prog .coluna2 p')[0].text,
      cast: html.css('.linha2 .borda.boxpreto1.prog .coluna2 p')[1].text,
      director: html.css('.linha2 .borda.boxpreto1.prog .coluna2 p')[2].text,
      programmings: []
    }

    html.css('.conteudo .borda.boxpreto1.prog').each do |html|
      programming = {
        period: '',
        sessions: []
      }

      html.css('.tabelahorarios tr').each_with_index do |html, index|
        if index >=1
          if html.css('td')[0].css('a').last.text == movie_theater_name
            hints = []

            session = {
              room: html.css('td')[2].text,
              subtitled: html.css('td')[3].text.include?('Leg') ? true : false,
              vip: html.css('td')[0].css('.icovip')[0] ? true : false,
              '3d': html.css('td')[0].css('.ico3d')[0] ? true : false,
              macroxe: html.css('td')[0].css('.icomacroxe')[0] ? true : false,
              dubbed: html.css('td')[3].text.include?('Dub') ? true : false,
              hints: [],
              hours: []
            }

            html.css('td')[3].css('.hint--top').each do |html|
              hint = {
                id: html.css('.hleter')[0].text,
                message: html.attr('data-hint')
              }

              hints << hint unless hints.include?(hint)
            end

            html.css('td')[3].text.gsub(/[DubLeg.-]/, '').split(',').each do |hour|
              hints.each do |hint|
                if hour.include?(hint[:id])
                  hour = hour.sub(hint[:id], " (#{hint[:message].capitalize})")
                end
              end

              session[:hours] << hour.strip
            end

            programming[:sessions] << session
          end
        end
      end

      movie[:programmings] << programming
    end

    html.css('.conteudo .tabNavigation.black').each_with_index do |html, index|
      movie[:programmings][index][:period] = html.css('.direita.branco.black').text.split('-')[1].strip
    end

    return movie
  end

end