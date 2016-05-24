module Api
  module V1
    class StatesController < BaseController
      skip_before_action :set_resource

      def index
        @states = @parser.get_states
      end

      def show
        @state = nil

        @parser.get_states.each do |state|
          @state = state if state[:uf].downcase == params[:id].downcase
        end

        if @state
          @state[:cities].each do |city|
            city_parser = CitiesParser.new(request)

            city[:movie_theaters] = city_parser.get_city(city[:id])[:movie_theaters]
          end

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
        
    end
  end
end