module Api
  module V1
    class CitiesController < BaseController
      skip_before_action :set_resource
      
      def index
        @cities = @parser.get_cities
      end

      def show
        city = @parser.get_city(params[:id])
        
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
        
    end
  end
end