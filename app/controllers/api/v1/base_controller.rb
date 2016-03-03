module Api
	module V1
		class BaseController < ApplicationController
			protect_from_forgery with: :null_session

      before_action :set_resource, only: [:show, :update, :destroy]
      before_action :set_parser, only: [:index, :show]

      def index
        resources_name = "@#{resource_name.pluralize}"

        resources = resource_class.where(query_params).page(page_params[:page]).per(page_params[:page_size])

        instance_variable_set(resources_name, resources)

        respond_to do |format|
          format.json { render :index }
        end
      end

      def show
        respond_to do |format|
          format.json { render :show }
        end
      end

      def create
        set_resource(resource_class.new(resource_params))

        if get_resource.save
          respond_to do |format|
            format.json { render :success }
          end
        else
          set_errors

          respond_to do |format|
            format.json { render :error }
          end
        end
      end

      def update
        if get_resource.update(resource_params)
          respond_to do |format|
            format.json { render :success }
          end
        else
          set_errors

          respond_to do |format|
            format.json { render :error }
          end
        end
      end

      def destroy
        if get_resource.destroy
          respond_to do |format|
            format.json { render :success }
          end
        else
          set_errors

          respond_to do |format|
            format.json { render :error }
          end
        end
      end

      private

        def resource_name
          controller_name.singularize
        end

        def resource_class
          resource_name.classify.constantize
        end

        def resource_params
          self.send("#{resource_name}_params")
        end

        def query_params
          {}
        end

        def page_params
          params.permit(:page, :page_size)
        end

        def set_resource(resource = nil)
          resource ||= resource_class.find(query_params[:id])
          instance_variable_set("@#{resource_name}", resource)
        end

        def get_resource
          instance_variable_get("@#{resource_name}")
        end

        def set_errors
          instance_variable_set("@errors", get_resource.errors)
        end

        def set_parser
          instance_variable_set("@parser", "#{controller_name.split('_').map(&:capitalize).join('')}Parser".constantize.new(request))
        end

		end
	end
end