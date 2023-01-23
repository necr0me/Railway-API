module Api
  module V1
    class RoutesController < ApplicationController
      before_action :authorize!, except: %i[show]
      before_action :find_route, except: %i[create]

      def show
        render json: { route: @route,
                       stations: @route.stations },
               status: 200
      end

      def create
        route = Route.create
        authorize route
        if route.persisted?
          render json: { message: 'Route was created',
                         route: route },
                 status: 201
        else
          render json: { message: 'Something went wrong',
                         errors: route.errors.full_messages },
                 status: 422
        end
      end

      def add_station
        authorize @route
        result = Routes::StationAdderService.call(route_id: params[:route_id],
                                                 station_id: params[:station_id])
        if result.success?
          render json: { message: 'Station was successfully added to route',
                         station: result.data },
                 status: 201
        else
          render json: { message: 'Something went wrong',
                         errors: result.errors },
                 status: 422
        end
      end

      def remove_station
        authorize @route
        result = Routes::StationRemoverService.call(route_id: params[:route_id],
                                                    station_id: params[:station_id])
        if result.success?
          render json: { message: 'Station was successfully removed from route' },
                 status: 200
        else
          render json: { message: 'Something went wrong',
                         errors: result.errors },
                 status: 422
        end
      end

      # TODO: Add 'if-else' block for handling errors during destroy
      def destroy
        authorize @route
        @route.destroy
        head 204
      end

      private

      def find_route
        @route ||= Route.includes(:stations).find(params[:route_id])
      end
    end
  end
end

