module Admin
  class RoutesController < AdminController
    before_action :find_route, except: %i[index create]
    before_action :authorize_route

    def index
      @routes = Route.search(params[:route], type: params[:search])
      @pagy, @routes = pagy(@routes, pagy_options)
      render json: { routes: RouteSerializer.new(@routes, serializer_options),
                     pages: @pagy.pages }
    end

    def show
      @available_stations = Station.where.not(id: @route.stations.pluck(:id))
      render json: { route: RouteSerializer.new(@route, { include: [:stations] }),
                     available_stations: StationSerializer.new(@available_stations) },
             status: :ok
    end

    def create
      route = Route.create
      if route.persisted?
        render json: { message: "Маршрут создан",
                       route: RouteSerializer.new(route) },
               status: :created
      else
        render json: { message: "Что-то пошло не так",
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
        render json: { message: "Станция успешно добавлена в маршрут",
                       station: StationSerializer.new(result.data),
                       route: RouteSerializer.new(Route.find(params[:route_id])) },
               status: :created
      else
        render json: { message: "Что-то пошло не так",
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
        render json: { message: "Станция успешно удалена из маршрута",
                       station: StationSerializer.new(result.data),
                       route: RouteSerializer.new(Route.find(params[:route_id])) },
               status: :ok
      else
        render json: { message: "Что-то пошло не так",
                       errors: [result.error] },
               status: :unprocessable_entity
      end
    end

    def update
      if @route.update(route_params)
        render json: { message: "Маршрут успешно обновлен",
                       route: RouteSerializer.new(@route) },
               status: :ok
      else
        render json: { message: "Что-то пошло не так",
                       errors: @route.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @route.destroy
        head :no_content
      else
        render json: { message: "Что-то пошло не так",
                       errors: @route.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    private

    def route_params
      params.require(:route).permit(:standard_travel_time)
    end

    def find_route
      @route = Route.includes(:stations).find(params[:route_id].to_i)
    end

    def authorize_route
      authorize(@route || Route)
    end

    def pagy_options
      {
        items: params[:page] ? Pagy::DEFAULT[:items] : [Route.count, 1].max,
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
