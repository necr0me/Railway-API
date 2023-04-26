module Admin
  class RoutesController < AdminController
    before_action :find_route, except: %i[index create]
    before_action :authorize_route

    def index
      @pagy, @routes = pagy(Route.all, pagy_options)
      render json: { routes: RouteSerializer.new(@routes, serializer_options),
                     pages: @pagy.pages }
    end

    def show
      render json: { route: RouteSerializer.new(@route, { include: [:stations] }),
                     available_stations: StationSerializer.new(Station.where.not(id: @route.stations.pluck(:id))) },
             status: :ok
    end

    def create
      route = Route.create
      if route.persisted?
        render json: { message: "Route was created",
                       route: RouteSerializer.new(route) },
               status: :created
      else
        render json: { message: "Something went wrong",
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
        render json: { message: "Station was successfully added to route",
                       station: StationSerializer.new(result.data) },
               status: :created
      else
        render json: { message: "Something went wrong",
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
        render json: { message: "Station was successfully removed from route",
                       station: StationSerializer.new(result.data) },
               status: :ok
      else
        render json: { message: "Something went wrong",
                       errors: [result.error] },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @route.destroy
        head :no_content
      else
        render json: { message: "Something went wrong",
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

    def pagy_options
      {
        items: params[:page] ? Pagy::DEFAULT[:items] : Route.count,
        page: params[:page] || 1
      }
    end

    def serializer_options
      {
        include: params[:page] ? [] : [:stations]
      }
    end
  end
end

