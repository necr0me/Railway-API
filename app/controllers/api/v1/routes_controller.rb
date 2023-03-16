module Api
  module V1
    class RoutesController < ApplicationController
      before_action :authorize!, except: %i[show]
      before_action :find_route, except: %i[create]
      before_action :authorize_route

      def show
        render json: { route: @route,
                       stations: @route.stations },
               status: :ok
      end

      def create
        route = Route.create
        if route.persisted?
          render json: { message: 'Route was created',
                         route: route },
                 status: :created
        else
          render json: { message: 'Something went wrong',
                         errors: route.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def add_station
        result = Routes::StationAdderService.call(
          route_id: params[:route_id],
          station_id: params[:station_id]
        )
        if result.success?
          render json: { message: 'Station was successfully added to route',
                         station: result.data },
                 status: :created
        else
          render json: { message: 'Something went wrong',
                         errors: [result.error] },
                 status: :unprocessable_entity
        end
      end

      def remove_station
        result = Routes::StationRemoverService.call(
          route_id: params[:route_id],
          station_id: params[:station_id]
        )
        if result.success?
          render json: { message: 'Station was successfully removed from route' },
                 status: :ok
        else
          render json: { message: 'Something went wrong',
                         errors: [result.error] },
                 status: :unprocessable_entity
        end
      end

      def destroy
        if @route.destroy
          head :no_content
        else
          render json: { message: 'Something went wrong',
                         errors: @route.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      def find_route
        @route = Route.includes(:stations).find(params[:route_id])
      end

      def authorize_route
        authorize(@route || Route)
      end
    end
  end
end
