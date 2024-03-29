module Admin
  class StationsController < AdminController
    before_action :find_station, only: %i[show update destroy]
    before_action :authorize_station

    def index
      @stations = Station.search(params[:station])
      @pagy, @stations = pagy(@stations, page: params[:page] || 1)
      render json: { stations: StationSerializer.new(@stations),
                     pages: @pagy.pages }
    end

    def show
      render json: { station: StationSerializer.new(@station, { include: %i[train_stops] }) },
             status: :ok
    end

    def create
      station = Station.create(station_params)
      if station.persisted?
        render json: { station: StationSerializer.new(station) },
               status: :created
      else
        render json: { message: "Что-то пошло не так",
                       errors: station.errors.to_hash(full_messages: true) },
               status: :unprocessable_entity
      end
    end

    def update
      if @station.update(station_params)
        render json: { station: StationSerializer.new(@station) },
               status: :ok
      else
        render json: { message: "Что-то пошло не так",
                       errors: @station.errors.to_hash(full_messages: true) },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @station.destroy
        head :no_content
      else
        render json: { message: "Что-то пошло не так",
                       errors: @station.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    private

    def station_params
      params.require(:station).permit(:name, :number_of_ways)
    end

    def find_station
      @station = Station.find(params[:id].to_i)
    end

    def authorize_station
      authorize(@station || Station)
    end
  end
end
