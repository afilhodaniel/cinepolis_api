module Api
  module V1
    class StatesController < BaseController
      skip_before_action :set_resource

      def index
        @states = parse_states().sort_by {|k| k[:uf]}
      end

      def show
        states = parse_states()

        @state = nil

        states.each do |state|
          @state = state if state[:uf].downcase == params[:id].downcase
        end

        if @state
          return @state
        else
          @errors = {
            state: 'State doesn\'t exists'
          }

          respond_to do |format|
            format.json { render :error }
          end
        end
      end

      private

        def state_params
          params.require(:state)
        end

        def parse_states
          html = Nokogiri::HTML(open("http://www.cinepolis.com.br/"))

          states = []

          html.css('select[name=CIDADE] option').each do |option|
            if option.attr('value') != '0'
              state = {
                uf: option.text.split('-')[1].strip,
                name: State::UFS[option.text.split('-')[1].strip.to_sym],
                url: "#{request.protocol}#{request.host}:#{request.port}#{api_v1_state_path(option.text.split('-')[1].strip.downcase, format: :json)}",
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
                    url: "#{request.protocol}#{request.host}:#{request.port}#{api_v1_city_path(option.attr('value'), format: :json)}"
                  }

                  state[:cities] << city
                end
              end
            end
          end

          return states
        end
        
    end
  end
end